/datum/ai_behavior/find_hunt_target/prowl
	search_turf_types = TRUE

/datum/ai_behavior/find_hunt_target/prowl/perform(seconds_per_tick, datum/ai_controller/controller, hunting_target_key, types_to_hunt, hunt_range)
	var/mob/living/living_mob = controller.pawn
	var/list/interesting_objects = search_turf_types ? RANGE_TURFS(hunt_range, living_mob) : oview(hunt_range, living_mob)
	shuffle_inplace(interesting_objects)
	for(var/atom/possible_dinner as anything in typecache_filter_list(interesting_objects, types_to_hunt))
		if(!valid_dinner(living_mob, possible_dinner, hunt_range, controller, seconds_per_tick))
			continue
		controller.set_blackboard_key(hunting_target_key, possible_dinner)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/hunt_target/prowl
	always_reset_target = TRUE
	behavior_flags = parent_type::behavior_flags | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/hunt_target/prowl/target_caught(mob/living/hunter, atom/hunted)
	return // We're just going there

/datum/ai_planning_subtree/find_and_hunt_target/prowl
	target_key = BB_PROWL_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target/prowl
	hunting_behavior = /datum/ai_behavior/hunt_target/prowl
	hunt_targets = list(/turf/simulated/floor/plasteel)
	hunt_range = 8
	hunt_chance = 50

/datum/ai_planning_subtree/find_and_hunt_target/prowl/lavaland
	hunt_targets = list(/turf/simulated/floor/plating/asteroid)
	hunt_chance = 15
