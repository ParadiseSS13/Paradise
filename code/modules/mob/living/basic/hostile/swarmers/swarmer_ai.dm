/// Attacks people it can see, disintegrates things based on priority.
/datum/ai_controller/basic_controller/swarmer
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 4
	)
	ai_movement = /datum/ai_movement/jps
	movement_delay = 1 SECONDS
	idle_behavior = /datum/idle_behavior/idle_random_walk

	ai_traits = AI_FLAG_PAUSE_DURING_DO_AFTER

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path/avoid_breaches,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
//		/datum/ai_planning_subtree/create_swarmer,
//		/datum/ai_planning_subtree/create_trap,
//		/datum/ai_planning_subtree/create_barricade,
		/datum/ai_planning_subtree/attack_obstacle_in_path/avoid_breaches/swarmer_hunting,
		/datum/ai_planning_subtree/find_and_hunt_target/corpses/swarmer,
		/datum/ai_planning_subtree/find_and_hunt_target/swarmer_objects,
		/datum/ai_planning_subtree/find_and_hunt_target/swarmer_objects/walls,
	)

/// Attacks people it can see, disintegrates things based on priority.
/datum/ai_controller/basic_controller/swarmer/lesser
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path/avoid_breaches,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
//		/datum/ai_planning_subtree/create_trap,
//		/datum/ai_planning_subtree/create_barricade,
		/datum/ai_planning_subtree/attack_obstacle_in_path/avoid_breaches/swarmer_hunting,
		/datum/ai_planning_subtree/find_and_hunt_target/corpses/swarmer,
		/datum/ai_planning_subtree/find_and_hunt_target/swarmer_objects,
		/datum/ai_planning_subtree/find_and_hunt_target/swarmer_objects/walls,
	)

/datum/ai_planning_subtree/find_and_hunt_target/corpses/swarmer
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/swarmer
	hunt_range = 4

/datum/ai_planning_subtree/find_and_hunt_target/swarmer_objects
	finding_behavior = /datum/ai_behavior/find_hunt_target/swarmer_objects
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/swarmer
	hunt_targets = list(/obj/item, /obj/structure, /obj/machinery, /turf/simulated/wall)
	hunt_range = 4

/datum/ai_planning_subtree/attack_obstacle_in_path/avoid_breaches/swarmer_hunting
	target_key = BB_CURRENT_HUNTING_TARGET

/datum/ai_behavior/hunt_target/interact_with_target/swarmer
	always_reset_target = TRUE
	hunt_cooldown = 0.3 SECONDS

/datum/ai_behavior/find_hunt_target/swarmer_objects

/datum/ai_behavior/find_hunt_target/swarmer_objects/valid_dinner(mob/living/source, atom/dinner, radius)
	if(is_type_in_list(dinner, GLOB.swarmer_blacklist))
		return FALSE
	if(isitem(dinner) && !isturf(dinner.loc))
		return FALSE
	for(var/turf/T in range(1, dinner))
		var/area/A = get_area(T)
		if(isspaceturf(T) || istype(A, /area/shuttle) || istype(A, /area/space) || istype(A, /area/station/engineering/engine/supermatter))
			return FALSE
	return TRUE

