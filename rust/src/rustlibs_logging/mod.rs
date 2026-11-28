//! Log files.
//!
//! log_write() only takes the time and puts the text on a queue. A thread of its own writes the queue out every few ms.
//! Before, every line was written to the drive on the game's own thread, so a slow or full drive held up the whole server.

use byondapi::value::ByondValue;
use chrono::{DateTime, Utc};
use eyre::{eyre, Context};
use std::{
    collections::hash_map::{Entry, HashMap},
    ffi::OsString,
    fs::{self, File, OpenOptions},
    io::{BufWriter, Write},
    path::{Path, PathBuf},
    sync::{mpsc, Condvar, Mutex, MutexGuard, OnceLock},
    thread,
    time::Duration,
};

/// How often the writer picks up the queue. Waking it for every line costs the game more than queueing the line.
const POLL: Duration = Duration::from_millis(10);
/// If the drive stops, lines past this much waiting text are dropped instead of running the server out of memory.
const MAX_QUEUED_BYTES: usize = 64 * 1024 * 1024;
/// How long log_close_all() waits for the queue to be written.
const CLOSE_WAIT: Duration = Duration::from_secs(10);

enum Message {
    Line {
        path: OsString,
        text: String,
        time: DateTime<Utc>,
    },
    CloseAll(mpsc::Sender<()>),
}

#[derive(Default)]
struct Waiting {
    messages: Vec<Message>,
    bytes: usize,
    dropped: usize,
    /// What went wrong on the writer's side, handed to the game by the next log_write()
    failed: usize,
    last_error: String,
}

struct Queue {
    waiting: Mutex<Waiting>,
    wake: Condvar,
}

static QUEUE: OnceLock<Queue> = OnceLock::new();

fn queue() -> eyre::Result<&'static Queue> {
    static WRITER: OnceLock<Result<(), String>> = OnceLock::new();
    let queue = QUEUE.get_or_init(|| Queue {
        waiting: Mutex::new(Waiting::default()),
        wake: Condvar::new(),
    });
    match WRITER.get_or_init(|| {
        // The writer thread runs in the library
        crate::library::keep_loaded();
        thread::Builder::new()
            .name("rustlibs log writer".into())
            .spawn(writer)
            .map(|_| ())
            .map_err(|e| e.to_string())
    }) {
        Ok(()) => Ok(queue),
        Err(e) => Err(eyre!("Couldn't start the log writer: {e}")),
    }
}

fn lock(queue: &Queue) -> MutexGuard<'_, Waiting> {
    queue.waiting.lock().unwrap_or_else(|e| e.into_inner())
}

#[byondapi::bind]
fn log_write(path: ByondValue, data: ByondValue) -> eyre::Result<ByondValue> {
    let time = Utc::now();
    let path = path.get_string()?;
    // Byond will happily send over invalid bytes from unpurged text macros, which Rust does not like
    // This circumvents ByondValue::get_string() to strip utf-8 before it can cause a panic
    let text = data
        .get_cstring()
        .map(|cstring| cstring.to_string_lossy().into_owned())
        .wrap_err(format!("UTF-8 decode error: {:#?}", data))?;
    queue_line(full_path(path), text, time)?;
    Ok(ByondValue::null())
}

/// BYOND moves the working folder around for a moment while it copies or makes files, and the writer can run right then.
/// So the path is made full here on the game's thread, against the world's folder.
fn full_path(path: String) -> OsString {
    static BASE: OnceLock<Option<PathBuf>> = OnceLock::new();
    match BASE.get_or_init(|| std::env::current_dir().ok()) {
        Some(base) => base.join(path).into_os_string(),
        None => path.into(),
    }
}

/// Waits for everything queued to be written, then closes every file
#[byondapi::bind]
fn log_close_all() -> eyre::Result<ByondValue> {
    close_all()?;
    Ok(ByondValue::null())
}

fn queue_line(path: OsString, text: String, time: DateTime<Utc>) -> eyre::Result<()> {
    let queue = queue()?;
    let mut waiting = lock(queue);
    let problem = take_problems(&mut waiting);
    if waiting.bytes + text.len() > MAX_QUEUED_BYTES {
        waiting.dropped += 1;
    } else {
        waiting.bytes += text.len();
        waiting.messages.push(Message::Line { path, text, time });
    }
    drop(waiting);
    match problem {
        Some(problem) => Err(eyre!(problem)),
        None => Ok(()),
    }
}

fn take_problems(waiting: &mut Waiting) -> Option<String> {
    let mut problems = Vec::new();
    if waiting.failed > 0 {
        problems.push(format!(
            "{} log writes failed, the last one: {}",
            waiting.failed, waiting.last_error
        ));
        waiting.failed = 0;
    }
    if waiting.dropped > 0 {
        problems.push(format!(
            "{} log lines dropped, the drive is too far behind",
            waiting.dropped
        ));
        waiting.dropped = 0;
    }
    if problems.is_empty() {
        return None;
    }
    Some(problems.join("; "))
}

fn close_all() -> eyre::Result<()> {
    let queue = queue()?;
    let (done, wait) = mpsc::channel();
    lock(queue).messages.push(Message::CloseAll(done));
    queue.wake.notify_one();
    // If the drive is that far gone, carry on: the writer still gets to it if the drive comes back
    let _ = wait.recv_timeout(CLOSE_WAIT);
    Ok(())
}

fn writer() {
    let Some(queue) = QUEUE.get() else {
        return;
    };
    let mut files: HashMap<OsString, BufWriter<File>> = HashMap::new();
    // Swapped with the queue each time, so neither side has to grow a new one
    let mut taken: Vec<Message> = Vec::new();
    loop {
        {
            let mut waiting = lock(queue);
            if waiting.messages.is_empty() {
                waiting = queue
                    .wake
                    .wait_timeout(waiting, POLL)
                    .unwrap_or_else(|e| e.into_inner())
                    .0;
            }
            std::mem::swap(&mut waiting.messages, &mut taken);
            waiting.bytes = 0;
        }
        let mut errors = Vec::new();
        for message in taken.drain(..) {
            match message {
                Message::Line { path, text, time } => {
                    if let Err(e) = write_line(&mut files, path, &text, time) {
                        errors.push(e);
                    }
                }
                Message::CloseAll(done) => {
                    flush_all(&mut files, &mut errors);
                    files.clear();
                    report(queue, &mut errors);
                    let _ = done.send(());
                }
            }
        }
        flush_all(&mut files, &mut errors);
        report(queue, &mut errors);
    }
}

/// Leaves the errors for the next log_write() to hand to the game
fn report(queue: &Queue, errors: &mut Vec<eyre::Report>) {
    let Some(last) = errors.last() else {
        return;
    };
    let mut waiting = lock(queue);
    waiting.failed += errors.len();
    waiting.last_error = format!("{last:#}");
    errors.clear();
}

fn write_line(
    files: &mut HashMap<OsString, BufWriter<File>>,
    path: OsString,
    text: &str,
    time: DateTime<Utc>,
) -> eyre::Result<()> {
    let file = match files.entry(path) {
        Entry::Occupied(e) => e.into_mut(),
        Entry::Vacant(e) => {
            let file =
                open(Path::new(e.key())).wrap_err(format!("{}", Path::new(e.key()).display()))?;
            e.insert(BufWriter::with_capacity(64 * 1024, file))
        }
    };
    let stamp = time.format("%FT%T");
    for line in text.split('\n') {
        writeln!(file, "[{stamp}] {line}")?;
    }
    Ok(())
}

fn flush_all(files: &mut HashMap<OsString, BufWriter<File>>, errors: &mut Vec<eyre::Report>) {
    for (path, file) in files.iter_mut() {
        if let Err(e) = file.flush() {
            errors.push(eyre!("{}: {e}", Path::new(path).display()));
        }
    }
}

fn open(path: &Path) -> eyre::Result<File> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    Ok(OpenOptions::new().append(true).create(true).open(path)?)
}
