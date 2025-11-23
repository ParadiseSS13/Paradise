/datum/ai_behavior/return_home
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// minimum time till next rest
	var/minimum_time = 2 MINUTES
	/// maximum time till next rest
	var/maximum_time = 4 MINUTES

/datum/ai_behavior/return_home/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	var/list/possible_turfs = get_adjacent_open_turfs(target)
	shuffle_inplace(possible_turfs)
	for(var/turf/possible_turf as anything in possible_turfs)
		if(!possible_turf.is_blocked_turf())
			set_movement_target(controller, possible_turf)
			return TRUE
	return FALSE

/datum/ai_behavior/return_home/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/return_home/incursion_portal
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/return_home/incursion_portal/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	return AI_BEHAVIOR_SUCCEEDED
