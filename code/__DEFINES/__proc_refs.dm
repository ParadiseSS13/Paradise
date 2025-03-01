/// Validates the proc exists on this type
#define PROC_REF(X) (nameof(.proc/##X))
/// Validates the proc exists on the specified type
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
/// Validates the proc exists on global
#define GLOBAL_PROC_REF(X) (/proc/##X)

#define NAMEOF_STATIC(datum, X) (#X || type::##X)
#define CALL_EXT call_ext
