// This file contains all the defines related to the spacemanDMM linter (dreamchecker). When running under normal conditions, BYOND will ignore all these
// Read https://github.com/SpaceManiac/SpacemanDMM/tree/master/crates/dreamchecker for more info.
#ifdef SPACEMAN_DMM
	#define RETURN_TYPE(X) set SpacemanDMM_return_type = X
	#define SHOULD_CALL_PARENT(X) set SpacemanDMM_should_call_parent = X
	#define UNLINT(X) SpacemanDMM_unlint(X)
	#define SHOULD_NOT_OVERRIDE(X) set SpacemanDMM_should_not_override = X
	#define SHOULD_NOT_SLEEP(X) set SpacemanDMM_should_not_sleep = X
	/// A "pure" proc does not make any external changes, or to its output.
	#define SHOULD_BE_PURE(X) set SpacemanDMM_should_be_pure = X
	/// Private procs can only be called by things of exactly the same type. This also prevents overriding of the proc.
	#define PRIVATE_PROC(X) set SpacemanDMM_private_proc = X
	/// Protected procs can only be call by things of the same type or subtypes
	#define PROTECTED_PROC(X) set SpacemanDMM_protected_proc = X
	/// Redefinable procs permit multiple declarations of themselves.
	#define CAN_BE_REDEFINED(X) set SpacemanDMM_can_be_redefined = X
	/// Final vars forbid overriding their value by types that inherit it.
	#define VAR_FINAL var/SpacemanDMM_final
	/// Private vars can only be called by things of exactly the same type
	#define VAR_PRIVATE var/SpacemanDMM_private
	/// Protected vars can only be call by things of the same type or subtypes
	#define VAR_PROTECTED var/SpacemanDMM_protected
#else
	#define RETURN_TYPE(X)
	#define SHOULD_CALL_PARENT(X)
	#define UNLINT(X) X
	#define SHOULD_NOT_OVERRIDE(X)
	#define SHOULD_NOT_SLEEP(X)
	#define SHOULD_BE_PURE(X)
	#define PRIVATE_PROC(X)
	#define PROTECTED_PROC(X)
	#define CAN_BE_REDEFINED(X)
	#define VAR_FINAL var
	#define VAR_PRIVATE var
	#define VAR_PROTECTED var
#endif
