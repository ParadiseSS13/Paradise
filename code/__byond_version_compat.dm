// This file contains defines allowing targeting byond versions newer than the supported
//TODO: REMOVE THE 514 STUFF WHEN DREAMCHECKER AND DM LANG SERVER GET THEIR ACT TOGETHER
// So we want to have compile time guarantees these procs exist on local type, unfortunately 515 killed the .proc/procname syntax so we have to use nameof()
#if DM_VERSION < 515
#define PROC_REF(X) (.proc/##X)
#define TYPE_PROC_REF(TYPE, X) (##TYPE.proc/##X)
#define GLOBAL_PROC_REF(X) (.proc/##X)
#define NAMEOF_STATIC(datum, X) (#X || ##datum.##X)
#define CALL_EXT call
#else
/// Validates the proc exists on this type (or global unfortunately)
#define PROC_REF(X) (nameof(.proc/##X))
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
#define GLOBAL_PROC_REF(X) (/proc/##X)
#define NAMEOF_STATIC(datum, X) (#X || type::##X)
#define CALL_EXT call_ext
#endif

/// Use this for every proc passed in as second argument in regex.Replace. regex.Replace does not allow calling procs by name but as of 515 using proc refs will always call the top level proc instead of overrides
#define REGEX_REPLACE_HANDLER SHOULD_NOT_OVERRIDE(TRUE)
