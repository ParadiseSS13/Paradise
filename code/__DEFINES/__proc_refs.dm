/// Validates the proc exists on this type (or global unfortunately)
#define PROC_REF(X) (nameof(.proc/##X))
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
#define GLOBAL_PROC_REF(X) (/proc/##X)
#define NAMEOF_STATIC(datum, X) (#X || type::##X)
#define CALL_EXT call_ext
