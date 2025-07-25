use byondapi::value::ByondValue;
use chrono::{DateTime, TimeZone, Utc};
use gix::{bstr::BStr, open::Error as OpenError, Repository};

// The methods in this file have the rl prefix for rustlibs as gix likes to make its own dll exports
// That makes things reallyyyyyyyyy messy

#[byondapi::bind]
fn rl_git_revparse(rev: ByondValue) -> eyre::Result<ByondValue> {
    let rev_str: String = rev.get_string()?;
    let rev_bytes = BStr::new(&rev_str);

    let repo = gix::open(".")?;
    if let Ok(revision) = repo.rev_parse_single(rev_bytes) {
        return Ok(ByondValue::new_str(revision.to_string())?);
    }
    Ok(ByondValue::null())
}

#[byondapi::bind]
fn rl_git_commit_date(rev: ByondValue, ts_format: ByondValue) -> eyre::Result<ByondValue> {
    let rev_str: String = rev.get_string()?;
    let ts_format_str: String = ts_format.get_string()?;

    let repo = gix::open(".")?;
    if let Some(datetime) = internal_rl_get_commit_date(&repo, rev_str) {
        return Ok(ByondValue::new_str(datetime.format(&ts_format_str).to_string())?);
    }
    Ok(ByondValue::null())
}

fn internal_rl_get_commit_date(repo: &Repository, rev_str: String) -> Option<DateTime<Utc>> {
    let rev_bytes: &BStr = BStr::new(&rev_str);
    let rev = repo.rev_parse_single(rev_bytes).ok()?;
    let object = rev.object().ok()?;
    let commit = object.try_into_commit().ok()?;
    let commit_time = commit.time().ok()?;
    Utc.timestamp_opt(commit_time.seconds, 0).latest()
}
