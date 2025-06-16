/// Find a target, walk at target, attack intervening obstacles
/datum/ai_controller/basic_controller/simple/simple_hostile_obstacles
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Find a target, walk towards it AND shoot it
/datum/ai_controller/basic_controller/simple/simple_skirmisher
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/simple/simple_skirmisher/demon_incursion
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl,
	)

/// Find a target, walk at target, attack intervening obstacles
/datum/ai_controller/basic_controller/simple/simple_hostile_obstacles/demonic_incursion
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl,
	)

/datum/ai_planning_subtree/attack_obstacle_in_path/prowl
	attack_behaviour = /datum/ai_behavior/attack_obstructions/avoid_breaches
	target_key = BB_PROWL_TARGET
