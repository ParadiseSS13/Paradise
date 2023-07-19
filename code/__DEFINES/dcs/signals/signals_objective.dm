// /datum/objective signals
///from datum/objective/proc/find_target()
#define COMSIG_OBJECTIVE_TARGET_FOUND "objective_target_found"
///from datum/objective/is_invalid_target()
#define COMSIG_OBJECTIVE_CHECK_VALID_TARGET "objective_check_valid_target"
	#define OBJECTIVE_VALID_TARGET		(1<<0)
	#define OBJECTIVE_INVALID_TARGET	(1<<1)
