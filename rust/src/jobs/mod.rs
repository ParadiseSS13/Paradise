//! Job system
use flume::{Receiver, TryRecvError};
use std::{
    cell::RefCell,
    collections::hash_map::{Entry, HashMap},
    thread,
};

struct Job {
    rx: Receiver<String>,
    handle: thread::JoinHandle<()>,
}

pub const NO_RESULTS_YET: &str = "NO RESULTS YET";
pub const NO_SUCH_JOB: &str = "NO SUCH JOB";
pub const JOB_PANICKED: &str = "JOB PANICKED";

#[derive(Default)]
struct Jobs {
    map: HashMap<usize, Job>,
    next_job: usize,
}

impl Jobs {
    fn start<F: FnOnce() -> String + Send + 'static>(&mut self, f: F) -> usize {
        let (tx, rx) = flume::unbounded();
        let handle = thread::spawn(move || {
            let _ = tx.send(f());
        });
        let id = self.next_job;
        self.next_job += 1;
        self.map.insert(id.clone(), Job { rx, handle });
        id
    }

    fn check(&mut self, id: &usize) -> Option<Result<String, TryRecvError>> {
        let entry = match self.map.entry(id.to_owned()) {
            Entry::Occupied(occupied) => occupied,
            Entry::Vacant(_) => return None,
        };
        let result = entry.get().rx.try_recv();
        let _ = entry.remove().handle.join();
        Some(result)
    }
}

thread_local! {
    static JOBS: RefCell<Jobs> = RefCell::default();
}

pub fn start<F: FnOnce() -> String + Send + 'static>(f: F) -> usize {
    JOBS.with(|jobs| jobs.borrow_mut().start(f))
}

pub fn check(id: &usize) -> Option<Result<String, TryRecvError>> {
    JOBS.with(|jobs| jobs.borrow_mut().check(id))
}
