/// Turns spacemandmm map object to string.
pub fn map_to_string(map: &dmmtools::dmm::Map) -> eyre::Result<String> {
    let mut v = vec![];
    map.to_writer(&mut v)?;
    let s = String::from_utf8(v)?;
    Ok(s)
}
