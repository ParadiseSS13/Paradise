use byondapi::value::ByondValue;
use uuid::Uuid;

#[byondapi::bind]
fn misc_new_uuid() -> eyre::Result<ByondValue> {
    let uuid: String = Uuid::new_v4().to_string();
    Ok(ByondValue::new_str(uuid)?)
}
