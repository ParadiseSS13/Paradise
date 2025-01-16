use crate::milla::model::*;
use std::sync::{atomic::AtomicUsize, Mutex, OnceLock};

/// The buffers that contain the atmos model.
/// OnceLock means we only ever set this once, and it's read-only after that.
/// (The RwLocks inside it are what let us modify the model anyway.)
pub(crate) static BUFFERS: OnceLock<Buffers> = OnceLock::new();

/// The current set of interesting tiles.
/// We only write this once per tick, and only read it on user input.
pub(crate) static INTERESTING_TILES: Mutex<Vec<InterestingTile>> = Mutex::new(Vec::new());

/// The current set of tiles BYOND wants the pressure of.
/// Written to via BYOND call.
/// Read from and cleared via BYOND call.
pub(crate) static TRACKED_PRESSURE_TILES: Mutex<Vec<(i32, i32, usize)>> = Mutex::new(Vec::new());

/// How long the last tick took, in milliseconds.
pub(crate) static TICK_TIME: AtomicUsize = AtomicUsize::new(0);
