/datum/ai_planning_subtree/ventcrawl

/datum/ai_planning_subtree/ventcrawl/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_VENTCRAWL_FINAL_TARGET])
		return

	if(controller.blackboard_key_exists(BB_VENT_SEARCH_RANGE) && get_dist(controller.pawn, controller.blackboard[BB_VENTCRAWL_FINAL_TARGET]) <= controller.blackboard[BB_VENT_SEARCH_RANGE])
		controller.queue_behavior(/datum/ai_behavior/travel_towards, BB_VENTCRAWL_FINAL_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!controller.blackboard_key_exists(BB_VENTCRAWL_EXIT))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/in_list/ventcrawl, BB_VENTCRAWL_EXIT, null, controller.blackboard[BB_VENT_SEARCH_RANGE])
		return
	controller.queue_behavior(/datum/ai_behavior/interact_with_target/start_ventcrawl, BB_VENTCRAWL_ENTRANCE)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/find_and_set/in_list/ventcrawl/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	// presume that all ventcrawling creatures are omniscient, at least about vents :)
	var/list/obj/machinery/atmospherics/entrance_vents = list()
	for(var/turf/T in spiral_range_turfs(search_range, controller.pawn))
		for(var/obj/machinery/atmospherics/atmos in T)
			if(is_type_in_list(atmos, GLOB.ventcrawl_machinery))
				entrance_vents |= atmos

	if(!length(entrance_vents))
		return

	var/list/obj/machinery/atmospherics/exit_vents = list()
	for(var/turf/T in spiral_range_turfs(search_range, controller.blackboard[BB_VENTCRAWL_FINAL_TARGET]))
		for(var/obj/machinery/atmospherics/atmos in T)
			if(is_type_in_list(atmos, GLOB.ventcrawl_machinery))
				exit_vents |= atmos

	if(!length(exit_vents))
		return

	for(var/obj/machinery/atmospherics/exit in exit_vents)
		var/datum/pipeline/exit_pipeline = exit.returnPipenet()
		var/list/obj/machinery/atmospherics/vents = exit_pipeline.get_ventcrawls()
		for(var/obj/machinery/atmospherics/entrance in (entrance_vents & vents))
			if(entrance != exit)
				controller.set_blackboard_key(BB_VENTCRAWL_ENTRANCE, entrance)
				return exit

/datum/ai_behavior/interact_with_target/start_ventcrawl

/datum/ai_behavior/interact_with_target/start_ventcrawl/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	if(. & AI_BEHAVIOR_FAILED)
		return
	var/obj/machinery/atmospherics/vent = controller.blackboard[target_key]
	var/mob/living/L = controller.pawn
	if(!istype(L))
		stack_trace("Something got a non-living pawn to try ventcrawling. How peculiar.")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	L.handle_ventcrawl(vent)
	if(controller.pawn.loc != vent)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.queue_behavior(/datum/ai_behavior/travel_towards/ventcrawling, BB_VENTCRAWL_EXIT)

