use byondapi::value::ByondValue;
use chrono::{DateTime, TimeZone, Utc};
use git2::Repository;

#[byondapi::bind]
fn git_revparse(rev: ByondValue) -> eyre::Result<ByondValue> {
    let rev_str: String = rev.get_string()?;
    if let Some(rev_id) = internal_git_revparse(rev_str) {
        return Ok(ByondValue::new_str(rev_id)?);
    }
    Ok(ByondValue::null())
}

fn internal_git_revparse(rev_str: String) -> Option<String> {
    let repo = Repository::open(".").ok()?;
    let rev = repo.revparse_single(rev_str.as_str()).ok()?;
    Some(rev.id().to_string())
}

#[byondapi::bind]
fn git_commit_date(rev: ByondValue, ts_format: ByondValue) -> eyre::Result<ByondValue> {
    let rev_str: String = rev.get_string()?;
    let ts_format_str: String = ts_format.get_string()?;

    if let Some(datetime) = internal_get_commit_date(rev_str) {
        return Ok(ByondValue::new_str(datetime.format(&ts_format_str).to_string())?);
    }
    Ok(ByondValue::null())
}

fn internal_get_commit_date(rev_str: String) -> Option<DateTime<Utc>> {
    let repo = Repository::open(".").ok()?;
    let rev = repo.revparse_single(rev_str.as_str()).ok()?;
    let commit = rev.as_commit()?;
    let commit_time = commit.time();
    Utc.timestamp_opt(commit_time.seconds(), 0).latest()
}
