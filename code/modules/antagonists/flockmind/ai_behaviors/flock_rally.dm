/datum/ai_behavior/flock/rally
	name = "rallying"
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 0

/datum/ai_behavior/flock/rally/setup(datum/ai_controller/controller, turf/destination)
	. = ..()
	controller.set_blackboard_key(BB_PATH_MAX_LENGTH, 200)
	controller.set_movement_target(controller, destination)

/datum/ai_behavior/flock/rally/perform(seconds_per_tick, datum/ai_controller/controller, turf/destination)
	..()
	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/rally/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
