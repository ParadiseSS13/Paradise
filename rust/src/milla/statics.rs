use crate::milla::constants::*;
use crate::milla::model::*;
use std::collections::HashMap;
use std::sync::{atomic::AtomicBool, atomic::AtomicUsize, Mutex, OnceLock};

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

/// The tiles BYOND is holding a copy of, by Z level. When one of them changes BYOND gets told,
/// and from then on it isn't holding a copy any more.
pub(crate) static REMEMBERED_TILES: Mutex<Vec<TileSet>> = Mutex::new(Vec::new());

/// The scrubbers on each Z level, in tile order. A level's tick has its own list to itself while
/// it's running.
pub(crate) static SCRUBBERS: [Mutex<Vec<Scrubber>>; MAX_Z_LEVELS as usize] =
    [const { Mutex::new(Vec::new()) }; MAX_Z_LEVELS as usize];

/// The last scrubber id handed out.
pub(crate) static LAST_SCRUBBER_ID: AtomicUsize = AtomicUsize::new(0);

/// Scrubbers BYOND asked to have removed while a tick had hold of them. They go the next time
/// BYOND collects.
pub(crate) static SCRUBBERS_TO_REMOVE: Mutex<Vec<u32>> = Mutex::new(Vec::new());

/// Set from when a tick is started until the frame it works out has become the current one.
/// Nothing can be written in that time.
pub(crate) static TICK_UNFINISHED: AtomicBool = AtomicBool::new(false);

/// Does BYOND make a finished tick the current frame itself, when it asks what changed?
/// If not, the tick thread does it as soon as it's done.
pub(crate) static BYOND_FINISHES_TICKS: AtomicBool = AtomicBool::new(false);

/// The interesting tiles of a tick that's been worked out but isn't the current frame yet.
pub(crate) static FINISHED_INTERESTING_TILES: Mutex<Option<Vec<InterestingTile>>> =
    Mutex::new(None);

/// The tiles whose air has changed since BYOND last asked, by Z level.
pub(crate) static CHANGED_TILES: Mutex<Vec<TileSet>> = Mutex::new(Vec::new());

/// The tripwires BYOND has set, by Z level, then by tile index.
pub(crate) static TRIPWIRES: Mutex<Vec<HashMap<usize, Tripwire>>> = Mutex::new(Vec::new());

/// The tiles whose tripwires went off as the current frame came in, as (x, y, z) from zero.
pub(crate) static TRIPPED_TILES: Mutex<Vec<(i32, i32, i32)>> = Mutex::new(Vec::new());
