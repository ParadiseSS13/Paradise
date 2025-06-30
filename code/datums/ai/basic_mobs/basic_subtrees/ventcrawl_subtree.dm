/datum/ai_planning_subtree/ventcrawl

/datum/ai_planning_subtree/ventcrawl/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	// we're in a pipe
	if(istype(controller.pawn.loc, /obj/machinery/atmospherics))
		// we have an exit vent to go to
		if(controller.blackboard_key_exists(BB_VENTCRAWL_EXIT))
			var/obj/machinery/atmospherics/A = controller.blackboard[BB_VENTCRAWL_EXIT]
			if(!A.can_crawl_through())
				controller.set_blackboard_key(BB_VENTCRAWL_ENTRANCE, null)
				controller.set_blackboard_key(BB_VENTCRAWL_EXIT, null)
				return .() // call this proc again
			// lets go there!
			controller.queue_behavior(/datum/ai_behavior/travel_towards/ventcrawling, BB_VENTCRAWL_EXIT)
			return SUBTREE_RETURN_FINISH_PLANNING
		// We dont have an exit vent, but we have a target. Let's find an exit vent near it.
		if(controller.blackboard_key_exists(BB_VENTCRAWL_FINAL_TARGET))
			controller.queue_behavior(/datum/ai_behavior/find_and_set/ventcrawl, BB_VENTCRAWL_EXIT, null, controller.blackboard[BB_VENT_SEARCH_RANGE])
			return
		// we dont have an set exit vent nor a final target... let's just get out of the pipe.
		controller.queue_behavior(/datum/ai_behavior/find_and_set/pipenet_vent, BB_VENTCRAWL_EXIT, null, controller.blackboard[BB_VENT_SEARCH_RANGE])
		return

	if(!controller.blackboard_key_exists(BB_VENTCRAWL_FINAL_TARGET))
		return

	// we have a target and we're nearby
	if(controller.blackboard_key_exists(BB_VENT_SEARCH_RANGE) && get_dist(controller.pawn, controller.blackboard[BB_VENTCRAWL_FINAL_TARGET]) <= controller.blackboard[BB_VENT_SEARCH_RANGE])
		// sometimes mobs can get stuck here if they're behind a wall... dunno how to fix this.
		controller.set_blackboard_key(BB_VENTCRAWL_ENTRANCE, null)
		controller.set_blackboard_key(BB_VENTCRAWL_EXIT, null)
		controller.queue_behavior(/datum/ai_behavior/travel_towards/stop_on_arrival, BB_VENTCRAWL_FINAL_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	// we're far-away, lets try to find a ventcrawl path
	if(!controller.blackboard_key_exists(BB_VENTCRAWL_EXIT))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/ventcrawl, BB_VENTCRAWL_EXIT, null, controller.blackboard[BB_VENT_SEARCH_RANGE], FALSE)
		return
	// we found a path, lets take it!
	controller.queue_behavior(/datum/ai_behavior/interact_with_vent, BB_VENTCRAWL_ENTRANCE)
	return SUBTREE_RETURN_FINISH_PLANNING

/**
 * This proc assumes that all ventcrawling creatures are omniscient.
 */
/datum/ai_behavior/find_and_set/ventcrawl/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	// we're inside a vent already, lets look for another way
	if(istype(controller.pawn.loc, /obj/machinery/atmospherics))
		var/obj/machinery/atmospherics/A = controller.pawn.loc
		var/datum/pipeline/P = A.returnPipenet()
		var/list/datum/pipeline/connected_pipelines = P.get_connected_pipelines()
		for(var/turf/T in spiral_range_turfs(search_range, controller.blackboard[BB_VENTCRAWL_FINAL_TARGET])) // get the nearest vents to the target first
			for(var/obj/machinery/atmospherics/exit in T)
				if(!is_type_in_list(exit, GLOB.ventcrawl_machinery))
					continue
				if(!exit.can_crawl_through())
					continue
				if(exit.returnPipenet() in connected_pipelines)
					return exit
		return

	// else, lets do a search for vents we have access to
	var/mob/M = controller.pawn
	var/datum/can_pass_info/pass_info = new(M, M.get_access())

	var/list/obj/machinery/atmospherics/entrance_vents = nearby_vents(get_turf(controller.pawn), FALSE, search_range, pass_info)
	if(!length(entrance_vents))
		return

	var/list/obj/machinery/atmospherics/exit_vents = nearby_vents(get_turf(controller.blackboard[BB_VENTCRAWL_FINAL_TARGET]), TRUE, search_range, pass_info)
	if(!length(exit_vents))
		return

	// try to find ones that share a pipeline first
	for(var/obj/machinery/atmospherics/exit in exit_vents)
		var/datum/pipeline/exit_pipeline = exit.returnPipenet()
		for(var/obj/machinery/atmospherics/entrance in entrance_vents)
			if(exit_pipeline == entrance.returnPipenet()) // It will probably be quicker if theyre on the same pipenet
				controller.set_blackboard_key(BB_VENTCRAWL_ENTRANCE, entrance)
				return exit

	// fuck it, search all possible paths
	for(var/obj/machinery/atmospherics/exit in exit_vents)
		var/datum/pipeline/exit_pipeline = exit.returnPipenet()
		var/list/obj/machinery/atmospherics/vents = exit_pipeline.get_ventcrawls()
		for(var/obj/machinery/atmospherics/entrance in (entrance_vents & vents))
			if(entrance != exit) // They're connected and not the same vent
				controller.set_blackboard_key(BB_VENTCRAWL_ENTRANCE, entrance)
				return exit

/**
 * Find something interesting nearby that we have access to.
 */
/datum/ai_behavior/find_and_set/ventcrawl/proc/nearby_vents(initial_location, reversed, max_dist, pass_info)
	// to search
	var/list/open_set = list(initial_location)
	// already searched
	var/list/closed_set = list()
	// the vents to return
	var/list/obj/machinery/atmospherics/vents = list()

	while(length(open_set))
		var/turf/current = popleft(open_set)
		closed_set |= current
		for(var/obj/machinery/atmospherics/atmos in current)
			if(is_type_in_list(atmos, GLOB.ventcrawl_machinery) && atmos.can_crawl_through())
				vents |= atmos

		for(var/dir in GLOB.cardinal)
			var/turf/next = get_step(current, dir)
			if((next in closed_set) || (get_dist(initial_location, next) > max_dist))
				continue
			// some accesses are directionally sensitive, like one-way airlocks
			if(reversed)
				if(current.density || next.LinkBlockedWithAccess(current, pass_info))
					continue
			else
				if(next.density || current.LinkBlockedWithAccess(next, pass_info))
					continue
			open_set |= next

	return vents

/datum/ai_behavior/find_and_set/pipenet_vent/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	// presume that all ventcrawling creatures are omniscient, at least about vents :)
	if(!istype(controller.pawn.loc, /obj/machinery/atmospherics))
		return
	var/obj/machinery/atmospherics/atmos_loc = controller.pawn.loc
	var/datum/pipeline/P = atmos_loc.returnPipenet()
	if(!P)
		return

	var/obj/machinery/atmospherics/closest
	var/closest_dist = INFINITY
	for(var/obj/machinery/atmospherics/vent in P.other_atmosmch)
		var/vent_dist = get_dist(atmos_loc, vent)
		if(vent_dist <= closest_dist)
			closest = vent
			closest_dist = vent_dist

	return closest

/datum/ai_behavior/interact_with_vent
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 1 SECONDS

/datum/ai_behavior/interact_with_vent/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/interact_with_vent/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/obj/machinery/atmospherics/vent = controller.blackboard[target_key]
	var/mob/living/L = controller.pawn
	if(!istype(L))
		stack_trace("Something got a non-living pawn to try ventcrawling. How peculiar.")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(controller.blackboard[BB_VENTCRAWL_IS_ENTERING] == TRUE)
		return AI_BEHAVIOR_DELAY
	controller.set_blackboard_key(BB_VENTCRAWL_IS_ENTERING, TRUE)
	L.handle_ventcrawl(vent)
	controller.set_blackboard_key(BB_VENTCRAWL_IS_ENTERING, FALSE)
	if(controller.pawn.loc != vent)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
