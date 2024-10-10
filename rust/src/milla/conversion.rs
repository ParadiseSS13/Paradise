use byondapi::prelude::*;
use byondapi::Error;
use eyre::Result;

/// Turns a BYOND number into an Option<f32>.
/// The option will be None if the number was null or NaN.
pub(crate) fn byond_to_option_f32(value: ByondValue) -> Result<Option<f32>, Error> {
    if value.is_null() {
        Ok(None)
    } else {
        Ok(f32_to_option_f32(value.get_number()?))
    }
}

/// Turns a BYOND number into an Option<f32>, clamping it to the specified bounds.
// The option will be None if the number was null or NaN.
pub(crate) fn bounded_byond_to_option_f32(
    value: ByondValue,
    min_value: f32,
    max_value: f32,
) -> Result<Option<f32>, Error> {
    if value.is_null() {
        Ok(None)
    } else {
        Ok(f32_to_option_f32(
            value.get_number()?.max(min_value).min(max_value),
        ))
    }
}

/// Wraps an f32 into an Option<f32> by converting NaN into None.
pub(crate) fn f32_to_option_f32(value: f32) -> Option<f32> {
    if value.is_nan() {
        None
    } else {
        Some(value)
    }
}
