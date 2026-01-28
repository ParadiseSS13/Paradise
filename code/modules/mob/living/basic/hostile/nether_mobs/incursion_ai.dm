/// Prowls around when not attacking people
/datum/ai_controller/basic_controller/incursion
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 6
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	interesting_dist = AI_SIMPLE_INTERESTING_DIST
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl,
	)

/datum/ai_controller/basic_controller/incursion/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl,
	)

/datum/ai_controller/basic_controller/incursion/juggernaut
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/attack_obstacle_in_path/walls,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl/walls,
	)

/datum/ai_controller/basic_controller/incursion/ranged_distance
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 6,
		BB_AGGRO_RANGE = 6,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/ranged_skirmish/avoid_friendly,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl,
	)

/datum/ai_controller/basic_controller/incursion/flesh_spider
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 6,
		BB_VENT_SEARCH_RANGE = 6,
	)
	ai_movement = /datum/ai_movement/jps

	ai_traits = AI_FLAG_PAUSE_DURING_DO_AFTER

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl,
		/datum/ai_planning_subtree/ventcrawl_find_target,
		/datum/ai_planning_subtree/ventcrawl,
	)

/datum/ai_controller/basic_controller/incursion/reanimator
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 4,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_AGGRO_RANGE = 6
	)

	ai_traits = AI_FLAG_PAUSE_DURING_DO_AFTER

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/conjure_skulls,
		/datum/ai_planning_subtree/find_and_hunt_target/corpses/human/reanimator,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl,
	)

/datum/ai_planning_subtree/find_and_hunt_target/corpses/human/reanimator
	hunt_range = 6

/// Run the conjure skulls action
/datum/ai_planning_subtree/conjure_skulls
	/// Key where the summoning action is stored
	var/action_key = BB_REANIMATOR_SKULL_ACTION
	/// Key where the target is stored
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/conjure_skulls/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(action_key) || !controller.blackboard_key_exists(target_key))
		return
	var/datum/action/cooldown/mob_cooldown/summon_skulls/skull_action = controller.blackboard[action_key]
	if(skull_action.IsAvailable())
		controller.queue_behavior(/datum/ai_behavior/conjure_skulls, action_key, target_key)
		return SUBTREE_RETURN_FINISH_PLANNING

/// Nyeh heh heh!
/datum/ai_behavior/conjure_skulls
	action_cooldown = 20 SECONDS // We don't want them doing this too quickly
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/conjure_skulls/perform(seconds_per_tick, datum/ai_controller/controller, action_key, target_key)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/summon_skulls/skull_action = controller.blackboard[action_key]
	var/result = skull_action.Trigger()
	if(result)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/datum/ai_behavior/return_to_portal
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/return_to_portal/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	var/list/possible_turfs = get_adjacent_open_turfs(target)
	shuffle_inplace(possible_turfs)
	for(var/turf/possible_turf as anything in possible_turfs)
		if(!possible_turf.is_blocked_turf())
			set_movement_target(controller, possible_turf)
			return TRUE
	return FALSE

/datum/ai_behavior/return_to_portal/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
