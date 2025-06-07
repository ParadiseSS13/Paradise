/// Finds a specific atom type to hunt.
/datum/ai_behavior/find_hunt_target
	/// is this only meant to search for turf types?
	var/search_turf_types = FALSE

/datum/ai_behavior/find_hunt_target/perform(seconds_per_tick, datum/ai_controller/controller, hunting_target_key, types_to_hunt, hunt_range)
	var/mob/living/living_mob = controller.pawn
	var/list/interesting_objects = search_turf_types ? RANGE_TURFS(hunt_range, living_mob) : oview(hunt_range, living_mob)
	for(var/atom/possible_dinner as anything in typecache_filter_list(interesting_objects, types_to_hunt))
		if(!valid_dinner(living_mob, possible_dinner, hunt_range, controller, seconds_per_tick))
			continue
		controller.set_blackboard_key(hunting_target_key, possible_dinner)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/find_hunt_target/proc/valid_dinner(mob/living/source, atom/dinner, radius, datum/ai_controller/controller, seconds_per_tick)
	if(isliving(dinner))
		var/mob/living/living_target = dinner
		if(living_target.stat == DEAD)
			return FALSE

	return can_see(source, dinner, radius)

/datum/ai_behavior/find_hunt_target/hunt_ores

/datum/ai_behavior/find_hunt_target/hunt_ores/valid_dinner(mob/living/basic/source, obj/item/stack/ore/target, radius, datum/ai_controller/controller)
	var/list/forbidden_ore = controller.blackboard[BB_ORE_IGNORE_TYPES]

	if(is_type_in_list(target, forbidden_ore))
		return FALSE

	if(!isturf(target.loc))
		return FALSE

	var/obj/item/pet_target = controller.blackboard[BB_CURRENT_PET_TARGET]
	if(target == pet_target) // we are currently fetching this ore for master, dont eat it!
		return FALSE

	return can_see(source, target, radius)
