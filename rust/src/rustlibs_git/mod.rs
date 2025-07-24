use byondapi::value::ByondValue;
use chrono::{TimeZone, Utc};
use gix::{bstr::BStr, open::Error as OpenError, Repository};

#[byondapi::bind]
fn rl_git_commit_date() -> eyre::Result<ByondValue> {
    return Ok(ByondValue::null());
}
