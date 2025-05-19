use byondapi::value::ByondValue;
use uwuifier::uwuify_str_sse;

use crate::logging;

#[byondapi::bind]
fn uwuify_text(value: ByondValue) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let text = value.get_string()?;
    let uwuified = uwuify_str_sse(&text);
    Ok(ByondValue::new_str(uwuified)?)
}
