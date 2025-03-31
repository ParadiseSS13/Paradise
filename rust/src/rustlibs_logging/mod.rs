use byondapi::value::ByondValue;
use chrono::Utc;
use eyre::Context;
use std::{
    cell::RefCell,
    collections::hash_map::{Entry, HashMap},
    ffi::OsString,
    fs,
    fs::{File, OpenOptions},
    io::Write,
    path::Path,
};

thread_local! {
    static FILE_MAP: RefCell<HashMap<OsString, File>> = RefCell::new(HashMap::new());
}

#[byondapi::bind]
fn log_write(path: ByondValue, data: ByondValue) -> eyre::Result<ByondValue> {
    FILE_MAP.with(|cell| -> eyre::Result<ByondValue> {
        let mut map = cell.borrow_mut();
        let path = path.get_string()?;
        let path = Path::new(&path as &str);
        let file = match map.entry(path.into()) {
            Entry::Occupied(e) => e.into_mut(),
            Entry::Vacant(e) => e.insert(open(path)?),
        };
        // Byond will happily send over invalid bytes from unpurged text macros, which Rust does not like
        // This circumvents ByondValue::get_string() to strip utf-8 before it can cause a panic
        let data = data
            .get_cstring()
            .map(|cstring| cstring.to_string_lossy().into_owned())
            .wrap_err(format!("UTF-8 decode error: {:#?}", data))?;
        let iter = data.split('\n');

        for line in iter {
            writeln!(file, "[{}] {}", Utc::now().format("%FT%T"), line)?;
        }

        Ok(ByondValue::null())
    })
}

#[byondapi::bind]
fn log_close_all() -> eyre::Result<ByondValue> {
    FILE_MAP.with(|cell| {
        let mut map = cell.borrow_mut();
        map.clear();
    });
    Ok(ByondValue::null())
}

fn open(path: &Path) -> eyre::Result<File> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    Ok(OpenOptions::new().append(true).create(true).open(path)?)
}
