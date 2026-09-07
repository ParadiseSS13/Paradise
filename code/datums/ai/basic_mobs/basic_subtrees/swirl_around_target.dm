/datum/ai_planning_subtree/swirl_around_target
	/// Variable to store target in
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/swirl_around_target/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/swirl_around_target, target_key)
