use byondapi::value::ByondValue;
#[cfg(target_os = "windows")]
use notify_rust::Notification;

#[byondapi::bind]
fn create_toast(_title: ByondValue, _text: ByondValue) -> eyre::Result<ByondValue> {
    #[cfg(target_os = "windows")]
    Notification::new()
        .summary(&_title.get_string()?)
        .body(&_text.get_string()?)
        .show()
        .ok();
    Ok(ByondValue::null())
}
