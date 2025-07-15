/**
 * Finds an item near themselves, sets a blackboard key as it. Very useful for AIs that need to use machines or something.
 * If you want to do something more complicated than find a single atom, change the search_tactic() proc
 * cool tip: search_tactic() can set lists
 */
/datum/ai_behavior/find_and_set
	action_cooldown = 2 SECONDS

/datum/ai_behavior/find_and_set/perform(seconds_per_tick, datum/ai_controller/controller, set_key, locate_path, search_range)
	if(controller.blackboard_key_exists(set_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(QDELETED(controller.pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	var/find_this_thing = search_tactic(controller, locate_path, search_range)
	if(isnull(find_this_thing))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(set_key, find_this_thing)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/find_and_set/proc/search_tactic(datum/ai_controller/controller, locate_path, search_range = 3)
	return locate(locate_path) in oview(search_range, controller.pawn)

/**
 * Variant of find and set that takes a list of things to find.
 */
/datum/ai_behavior/find_and_set/in_list

/datum/ai_behavior/find_and_set/in_list/search_tactic(datum/ai_controller/controller, locate_paths, search_range)
	var/list/found = typecache_filter_list(oview(search_range, controller.pawn), locate_paths)
	if(length(found))
		return pick(found)

/datum/ai_behavior/find_and_set/in_list/turf_types

/datum/ai_behavior/find_and_set/in_list/turf_types/search_tactic(datum/ai_controller/controller, locate_paths, search_range)
	var/list/found = RANGE_TURFS(search_range, controller.pawn)
	shuffle_inplace(found)
	for(var/turf/possible_turf as anything in found)
		if(!is_type_in_typecache(possible_turf, locate_paths))
			continue
		if(can_see(controller.pawn, possible_turf, search_range))
			return possible_turf
	return null
