// This file contains defines allowing targeting byond versions newer than the supported

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
