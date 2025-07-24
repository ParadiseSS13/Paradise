use byondapi::value::ByondValue;
use chrono::{TimeZone, Utc};
use gix::{bstr::BStr, open::Error as OpenError, Repository};

// The methods in this file have the rl prefix for rustlibs as gix likes to make its own dll exports
// That makes things reallyyyyyyyyy messy

thread_local! {
    static REPOSITORY: Result<Repository, OpenError> = gix::open(".");
}

#[byondapi::bind]
fn rl_git_commit_date(rev: ByondValue, ts_format: ByondValue) -> eyre::Result<ByondValue> {
    let rev_str: String = rev.get_string()?;
    let rev_bytes: &BStr = BStr::new(&rev_str);

    let ts_format_str: String = ts_format.get_string()?;

    let repo_check_result = REPOSITORY.with(|repo| -> Option<String> {
        let repo_ref = repo.as_ref().ok()?;
        let rev = repo_ref.rev_parse_single(rev_bytes).ok()?;
        let object = rev.object().ok()?;
        let commit = object.try_into_commit().ok()?;
        let commit_time = commit.time().ok()?;
        let datetime = Utc.timestamp_opt(commit_time.seconds, 0).latest()?;
        Some(datetime.format(&ts_format_str).to_string())
    });

    match repo_check_result {
        Some(res) => {
            return Ok(ByondValue::new_str(res)?);
        }
        None => {
            return Ok(ByondValue::null());
        }
    }
}
