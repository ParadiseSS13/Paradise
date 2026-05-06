/datum/ai_behavior/flock/rally
	name = "rallying"
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 0

/datum/ai_behavior/flock/rally/setup(datum/ai_controller/controller, turf/destination)
	. = ..()
	controller.set_blackboard_key(BB_PATH_MAX_LENGTH, 200)
	controller.set_move_target(destination)

/datum/ai_behavior/flock/rally/perform(delta_time, datum/ai_controller/controller, turf/destination)
	..()
	return BEHAVIOR_PERFORM_SUCCESS

/datum/ai_behavior/flock/rally/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
