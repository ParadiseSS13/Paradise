/**
 * Extremely simple AI, this isn't a very smart boy
 * Only notable quirk is that it uses JPS movement, simple avoidance would fail to realise it can path through blobs
 */
/datum/ai_controller/basic_controller/blobbernaut
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)

	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/**
 * As blob zombie but will prioritise attacking corpses to zombify them
 */
/datum/ai_controller/basic_controller/blob_spore
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)

	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/corpses/human/blob,
		/datum/ai_planning_subtree/travel_to_point/and_clear_target,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/find_and_hunt_target/corpses/human/blob

/datum/ai_planning_subtree/find_and_hunt_target/corpses/human/blob/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/blob/blobspore/spore = controller.pawn
	if(spore.is_zombie)
		return
	return ..()
