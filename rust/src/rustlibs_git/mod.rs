use byondapi::value::ByondValue;
use chrono::{TimeZone, Utc};
use gix::{bstr::BStr, open::Error as OpenError, Repository};

// The methods in this file have the rl prefix for rustlibs as gix likes to make its own dll exports
// That makes things reallyyyyyyyyy messy

thread_local! {
    static REPOSITORY: Result<Repository, OpenError> = gix::open(".");
}

#[byondapi::bind]
fn rl_git_revparse(rev: ByondValue) -> eyre::Result<ByondValue> {
    let rev_str: String = rev.get_string()?;
    let rev_bytes = BStr::new(&rev_str);

    let repo_check_result = REPOSITORY.with(|repo| -> Option<String> {
        let repo_ref = repo.as_ref().ok()?;
        let object = repo_ref.rev_parse_single(rev_bytes).ok()?;
        Some(object.to_string())
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
