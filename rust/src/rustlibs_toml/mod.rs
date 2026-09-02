use byondapi::value::ByondValue;

#[byondapi::bind]
fn toml_file_to_json(path: ByondValue) -> eyre::Result<ByondValue> {
    let path: String = path.get_string()?;
    Ok(serde_json::to_string(&match toml_file_to_json_impl(&path) {
        Ok(value) => serde_json::json!({
            "success": true, "content": value
        }),
        Err(error) => serde_json::json!({
            "success": false, "content": error.to_string()
        }),
    })?
    .try_into()?)
}

fn toml_file_to_json_impl(path: &str) -> eyre::Result<String> {
    Ok(serde_json::to_string(&toml::from_str::<toml::Value>(
        &std::fs::read_to_string(path)?,
    )?)?)
}

#[byondapi::bind]
fn toml_encode(value: ByondValue) -> eyre::Result<ByondValue> {
    let path: String = value.get_string()?;
    Ok(serde_json::to_string(&match toml_encode_impl(&path) {
        Ok(value) => serde_json::json!({
            "success": true, "content": value
        }),
        Err(error) => serde_json::json!({
            "success": false, "content": error.to_string()
        }),
    })?
    .try_into()?)
}

fn toml_encode_impl(value: &str) -> eyre::Result<String> {
    Ok(toml::to_string_pretty(
        &serde_json::from_str::<toml::Value>(value)?,
    )?)
}
