use byondapi::value::ByondValue;
use chrono::{TimeZone, Utc};
use gix::{bstr::BStr, open::Error as OpenError, Repository};

// The methods in this file have the rl prefix for rustlibs as gix likes to make its own dll exports
// That makes things reallyyyyyyyyy messy

thread_local! {
    static REPOSITORY: Result<Repository, OpenError> = gix::open(".");
}
