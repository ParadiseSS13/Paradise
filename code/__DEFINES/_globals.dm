//See controllers/globals.dm
#define GLOBAL_MANAGED(X, InitValue)\
/datum/controller/global_vars/proc/InitGlobal##X(){\
	##X = ##InitValue;\
	gvars_datum_init_order += #X;\
}
#define GLOBAL_UNMANAGED(X) /datum/controller/global_vars/proc/InitGlobal##X() { return; }

#ifndef TESTING
#define GLOBAL_PROTECT(X)\
/datum/controller/global_vars/InitGlobal##X(){\
	..();\
	gvars_datum_protected_varlist[#X] = TRUE;\
}
#else
#define GLOBAL_PROTECT(X)
#endif

/// Standard BYOND global, seriously do not use without an earthshakingly good reason
#define GLOBAL_REAL_VAR(X) var/global/##X

/// Standard typed BYOND global, seriously do not use without an earthshakingly good reason
#define GLOBAL_REAL(X, Typepath) var/global##Typepath/##X

/// Defines a global var on the controller, do not use
#define GLOBAL_RAW(X) /datum/controller/global_vars/var/global##X

/// Create an untyped global with an initializer expression
#define GLOBAL_VAR_INIT(X, InitValue) GLOBAL_RAW(/##X); GLOBAL_MANAGED(X, InitValue)

/// Create a global const var, do not use
#define GLOBAL_VAR_CONST(X, InitValue) GLOBAL_RAW(/const/##X) = InitValue; GLOBAL_UNMANAGED(X)

/// Create a list global with an initializer expression
#define GLOBAL_LIST_INIT(X, InitValue) GLOBAL_RAW(/list/##X); GLOBAL_MANAGED(X, InitValue)

/// Create a list global that is initialized as an empty list
#define GLOBAL_LIST_EMPTY(X) GLOBAL_LIST_INIT(X, list())

/// Create a typed list global with an initializer expression
#define GLOBAL_LIST_INIT_TYPED(X, Typepath, InitValue) GLOBAL_RAW(/list##Typepath/X); GLOBAL_MANAGED(X, InitValue)

/// Create a typed list global that is initialized as an empty list
#define GLOBAL_LIST_EMPTY_TYPED(X, Typepath) GLOBAL_LIST_INIT_TYPED(X, Typepath, list())

/// Create a typed global with an initializer expression
#define GLOBAL_DATUM_INIT(X, Typepath, InitValue) GLOBAL_RAW(Typepath/##X); GLOBAL_MANAGED(X, InitValue)

/// Create an untyped null global
#define GLOBAL_VAR(X) GLOBAL_RAW(/##X); GLOBAL_UNMANAGED(X)

/// Create a null global list
#define GLOBAL_LIST(X) GLOBAL_RAW(/list/##X); GLOBAL_UNMANAGED(X)

/// Create a typed null global
#define GLOBAL_DATUM(X, Typepath) GLOBAL_RAW(Typepath/##X); GLOBAL_UNMANAGED(X)
