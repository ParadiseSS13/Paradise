/datum/ai_planning_subtree/goap
	var/list/possible_behaviors = list()

/datum/ai_planning_subtree/goap/setup(datum/ai_controller/controller, ...)
	. = ..()
	controller.set_blackboard_key(BB_PLANNER_BEHAVIORS, list())
	for(var/behavior_type in possible_behaviors)
		var/datum/ai_behavior/behavior = GET_AI_BEHAVIOR(behavior_type)
		if(isnull(behavior))
			stack_trace("Bad AI behavior: [behavior_type]")
			continue
		controller.set_blackboard_key_assoc(BB_PLANNER_BEHAVIORS, behavior, 0)

/datum/ai_planning_subtree/goap/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/list/behavior_cache = controller.blackboard[BB_PLANNER_BEHAVIORS]
	var/datum/ai_behavior/candidate = behavior_cache[1]
	var/score_to_beat = behavior_cache[candidate]

	for(var/behavior in behavior_cache)
		var/behavior_score = behavior_cache[behavior]
		if(behavior_score == AI_GOAP_SKIP_BEHAVIOR)
			continue

		// Filter out lower scoring behaviors
		if(score_to_beat > behavior_score)
			continue

		// If there's a tie, pick either.
		if((behavior_score == score_to_beat) && prob(50))
			continue

		candidate = behavior
		score_to_beat = behavior_cache[candidate]

	if(candidate)
		controller.queue_behavior(candidate.type)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/goap/process_behavior_selection(datum/ai_controller/controller, seconds_per_tick)
	for(var/datum/ai_behavior/behavior in controller.blackboard[BB_PLANNER_BEHAVIORS])
		if(behavior.goap_precondition(controller))
			controller.set_blackboard_key_assoc(BB_PLANNER_BEHAVIORS, behavior, behavior.goap_weight * behavior.goap_score(controller))
		else
			controller.set_blackboard_key_assoc(BB_PLANNER_BEHAVIORS, behavior, AI_GOAP_SKIP_BEHAVIOR)

	return ..()
