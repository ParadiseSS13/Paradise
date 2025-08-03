/datum/ai_planning_subtree/ventcrawl_find_target

/datum/ai_planning_subtree/ventcrawl_find_target/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	// We have a target already
	if(controller.blackboard_key_exists(BB_VENTCRAWL_FINAL_TARGET))
		return
	// We don't have a search range
	var/vision_range
	if(!controller.blackboard_key_exists(BB_VENT_SEARCH_RANGE))
		vision_range = 10
	else
		vision_range = controller.blackboard[BB_VENT_SEARCH_RANGE]
	// Find a target
	controller.queue_behavior(/datum/ai_behavior/find_ventcrawl_target, BB_VENTCRAWL_FINAL_TARGET, vision_range)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/find_ventcrawl_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 45 SECONDS

/datum/ai_behavior/find_ventcrawl_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key, range)
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(range, controller.pawn))
		if(!v.welded)
			var/datum/pipeline/P = v.returnPipenet()
			if(!P)
				continue
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in P.other_atmosmch)
				if(temp_vent.welded) // no point considering a vent we can't even use
					continue
				vents |= temp_vent
	if(!length(vents))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
	var/list/potential_targets = list()
	for(var/turf/current_target_turf in view(range, exit_vent))
		if(!isfloorturf(current_target_turf))
			continue
		if(current_target_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = controller.pawn))
			continue
		potential_targets |= current_target_turf
	if(!length(potential_targets))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(BB_VENTCRAWL_FINAL_TARGET, pick(potential_targets))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
