/// Prowls around when not attacking people
/datum/ai_controller/basic_controller/incursion
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	interesting_dist = AI_SIMPLE_INTERESTING_DIST
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl,
	)

/datum/ai_controller/basic_controller/incursion/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate,
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
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/attack_obstacle_in_path/walls,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl/walls,
	)

/datum/ai_controller/basic_controller/incursion/ranged_distance
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 6
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/ranged_skirmish/avoid_friendly,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl,
	)
