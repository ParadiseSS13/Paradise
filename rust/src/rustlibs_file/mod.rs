use byondapi::value::ByondValue;
use std::{
    fs::File,
    io::{BufReader, BufWriter, Read, Write},
};

#[byondapi::bind]
fn file_read(path: ByondValue) -> eyre::Result<ByondValue> {
    read(&path.get_string()?)
}

fn read(path: &str) -> eyre::Result<ByondValue> {
    let file = File::open(path)?;
    let metadata = file.metadata()?;
    let mut file = BufReader::new(file);

    let mut content = String::with_capacity(metadata.len() as usize);
    file.read_to_string(&mut content)?;
    let content = content.replace('\r', "");

    Ok(content.try_into()?)
}

#[byondapi::bind]
fn file_write(data: ByondValue, path: ByondValue) -> eyre::Result<ByondValue> {
    let data: String = data.get_string()?;
    let path: String = path.get_string()?;
    write(&data, &path)
}

fn write(data: &str, path: &str) -> eyre::Result<ByondValue> {
    let path: &std::path::Path = path.as_ref();
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)?;
    }

    let mut file = BufWriter::new(File::create(path)?);
    let written = file.write(data.as_bytes())? as f32;

    file.flush()?;
    file.into_inner()
        .map_err(|e| std::io::Error::new(e.error().kind(), e.error().to_string()))?
        .sync_all()?;

    Ok(written.into())
}
