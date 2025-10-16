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
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/create_swarmer,
		/datum/ai_planning_subtree/create_trap,
		/datum/ai_planning_subtree/create_barricade,
		/datum/ai_planning_subtree/find_and_hunt_target/corpses,
		/datum/ai_planning_subtree/find_and_hunt_target/machines,
		/datum/ai_planning_subtree/find_and_hunt_target/walls,
	)

/// Attacks people it can see, disintegrates things based on priority.
/datum/ai_controller/basic_controller/swarmer/lesser
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/create_trap,
		/datum/ai_planning_subtree/create_barricade,
		/datum/ai_planning_subtree/find_and_hunt_target/corpses,
		/datum/ai_planning_subtree/find_and_hunt_target/machines,
		/datum/ai_planning_subtree/find_and_hunt_target/walls,
	)
