//! Job system
use flume::{Receiver, TryRecvError};
use std::{
    cell::RefCell,
    collections::hash_map::{Entry, HashMap},
    thread,
};

type Output = String;
type JobID = usize;

struct Job {
    rx: Receiver<Output>,
    handle: thread::JoinHandle<()>,
}

pub const NO_RESULTS_YET: &str = "NO RESULTS YET";
pub const NO_SUCH_JOB: &str = "NO SUCH JOB";
pub const JOB_PANICKED: &str = "JOB PANICKED";

#[derive(Default)]
struct Jobs {
    map: HashMap<JobID, Job>,
    next_job: usize,
}

impl Jobs {
    fn start<F: FnOnce() -> Output + Send + 'static>(&mut self, f: F) -> usize {
        let (tx, rx) = flume::unbounded();
        let handle = thread::spawn(move || {
            let _ = tx.send(f());
        });
        let id = self.next_job;
        self.next_job += 1;
        self.map.insert(id.clone(), Job { rx, handle });
        id
    }

    fn check(&mut self, id: &usize) -> Option<Result<Output, TryRecvError>> {
        let entry = match self.map.entry(id.to_owned()) {
            Entry::Occupied(occupied) => occupied,
            Entry::Vacant(_) => return None,
        };
        let result = match entry.get().rx.try_recv() {
            Ok(result) => Ok(result),
            Err(TryRecvError::Empty) => return Some(Err(TryRecvError::Empty)),
            Err(TryRecvError::Disconnected) => Err(TryRecvError::Disconnected),
        };
        let _ = entry.remove().handle.join();
        Some(result)
    }
}

thread_local! {
    static JOBS: RefCell<Jobs> = RefCell::default();
}

pub fn start<F: FnOnce() -> Output + Send + 'static>(f: F) -> usize {
    JOBS.with(|jobs| jobs.borrow_mut().start(f))
}

pub fn check(id: &usize) -> Option<Result<Output, TryRecvError>> {
    JOBS.with(|jobs| jobs.borrow_mut().check(id))
}
