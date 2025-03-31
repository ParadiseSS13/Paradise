use byondapi::value::ByondValue;
use chrono::Utc;
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
        let data = data.get_string()?;
        let mut iter = data.split('\n');
        if let Some(line) = iter.next() {
            writeln!(file, "[{}] {}", Utc::now().format("%FT%T"), line)?;
        }
        for line in iter {
            writeln!(file, " - {line}")?;
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
