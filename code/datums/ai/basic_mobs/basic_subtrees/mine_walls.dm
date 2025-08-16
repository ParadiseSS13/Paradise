/datum/ai_behavior/find_mineral_wall

/datum/ai_behavior/find_mineral_wall/perform(seconds_per_tick, datum/ai_controller/controller, found_wall_key)
	var/mob/living_pawn = controller.pawn

	for(var/turf/simulated/mineral/potential_wall in oview(9, living_pawn))
		if(!check_if_mineable(controller, potential_wall)) // check if its surrounded by walls
			continue
		controller.set_blackboard_key(found_wall_key, potential_wall) // closest wall first!
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Check to see if we can get to and mine the turf the mineral is in
/datum/ai_behavior/find_mineral_wall/proc/check_if_mineable(datum/ai_controller/controller, turf/target_wall)
	var/mob/living/source = controller.pawn
	var/direction_to_turf = get_dir(target_wall, source)
	if(!IS_DIR_DIAGONAL(direction_to_turf))
		return TRUE
	var/list/directions_to_check = list()
	for(var/direction_check in GLOB.cardinal)
		if(direction_check & direction_to_turf)
			directions_to_check += direction_check

	for(var/direction in directions_to_check)
		var/turf/test_turf = get_step(target_wall, direction)
		if(isnull(test_turf))
			continue
		if(!test_turf.is_blocked_turf(source_atom = source))
			return TRUE
	return FALSE


/datum/ai_planning_subtree/mine_walls
	var/find_wall_behavior = /datum/ai_behavior/find_mineral_wall

/datum/ai_planning_subtree/mine_walls/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_TARGET_MINERAL_WALL))
		controller.queue_behavior(/datum/ai_behavior/interact_with_target/mine_wall, BB_TARGET_MINERAL_WALL)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(find_wall_behavior, BB_TARGET_MINERAL_WALL)

/datum/ai_behavior/interact_with_target/mine_wall
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 15 SECONDS

/datum/ai_behavior/interact_with_target/mine_wall/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/living_pawn = controller.pawn
	var/turf/simulated/mineral/target = controller.blackboard[target_key]
	if(!controller.ai_interact(target = target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(istype(target) && istype(target.ore, /datum/ore/gibtonite))
		living_pawn.manual_emote("sighs...") // accept whats about to happen to us

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
