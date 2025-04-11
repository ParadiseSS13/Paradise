use byondapi::value::ByondValue;
use serde_json::Value;
use std::cmp;

const VALID_JSON_MAX_RECURSION_DEPTH: usize = 8;

#[byondapi::bind]
fn json_is_valid(text: ByondValue) -> eyre::Result<ByondValue> {
    let value = match serde_json::from_str::<Value>(&text.get_string()?) {
        Ok(value) => value,
        Err(_) => return Ok("false".try_into()?),
    };

    Ok(get_recursion_level(&value).is_ok().to_string().try_into()?)
}

/// Gets the recursion level of the given value
/// If it is above `VALID_JSON_MAX_RECURSION_DEPTH`, returns Err(())
fn get_recursion_level(value: &Value) -> Result<usize, ()> {
    let values: Vec<&Value> = match value {
        Value::Array(array) => array.iter().collect(),

        Value::Object(map) => map.values().collect(),

        _ => return Ok(0),
    };

    let mut max_recursion_level = 0;

    for value in values {
        max_recursion_level = cmp::max(max_recursion_level, get_recursion_level(value)?);
    }

    max_recursion_level += 1;

    if max_recursion_level >= VALID_JSON_MAX_RECURSION_DEPTH {
        Err(())
    } else {
        Ok(max_recursion_level)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_recursion_level() {
        assert_eq!(
            get_recursion_level(&serde_json::from_str("[]").unwrap()),
            Ok(1)
        );
        assert_eq!(
            get_recursion_level(&serde_json::from_str("[[]]").unwrap()),
            Ok(2)
        );
        assert_eq!(
            get_recursion_level(&serde_json::from_str("[[[]]]").unwrap()),
            Ok(3)
        );
    }

    #[test]
    fn test_get_recursion_level_max_depth() {
        assert_eq!(
            get_recursion_level(
                &serde_json::from_str(&format!(
                    "{}{}",
                    "[".repeat(VALID_JSON_MAX_RECURSION_DEPTH),
                    "]".repeat(VALID_JSON_MAX_RECURSION_DEPTH)
                ))
                .unwrap()
            ),
            Err(())
        );
    }
}
