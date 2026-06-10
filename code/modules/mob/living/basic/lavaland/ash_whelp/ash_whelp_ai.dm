/// We won't use fire breath unless we have had the same target forthis long
#define MIN_TIME_TO_BREATH_WEAPON 2 SECONDS

/datum/ai_controller/basic_controller/ash_whelp
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_AGGRO_RANGE = 5,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/generic_resist,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/ash_whelp,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/ash_whelp,
		/datum/ai_planning_subtree/sculpt_statues,
		/datum/ai_planning_subtree/find_and_hunt_target/corpses/ash_whelp,
		/datum/ai_planning_subtree/burn_trees,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl/lavaland,
	)

/// Cancel melee attacks when we have our breath weapon
/datum/ai_planning_subtree/basic_melee_attack_subtree/ash_whelp
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/ash_whelp

/// Cancel melee attacks when we have our breath weapon
/datum/ai_behavior/basic_melee_attack/ash_whelp

/datum/ai_behavior/basic_melee_attack/ash_whelp/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/datum/action/cooldown/breath_weapon = controller.blackboard[BB_TARGETED_ACTION]
	if(breath_weapon?.IsAvailable())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	return ..()

/// Find other tasty dragons
/datum/ai_planning_subtree/find_and_hunt_target/corpses/ash_whelp
	target_key = BB_TARGET_CANNIBAL
	finding_behavior = /datum/ai_behavior/find_hunt_target/corpses/dragon_corpse
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/dragon_cannibalise
	hunt_targets = list(/mob/living/basic/mining/ash_whelp)
	hunt_range = 10

/datum/ai_behavior/find_hunt_target/corpses/dragon_corpse

/datum/ai_behavior/find_hunt_target/corpses/dragon_corpse/valid_dinner(mob/living/source, mob/living/dinner, radius)
	if(dinner.pulledby) // someone already got him before us
		return FALSE
	return ..()

/// Eat other dragons
/datum/ai_behavior/hunt_target/interact_with_target/dragon_cannibalise
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/hunt_target/interact_with_target/dragon_cannibalise/perform(seconds_per_tick, datum/ai_controller/controller, target_key, attack_key)
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.stat != DEAD || target.pulledby) // we were too slow
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()

/datum/ai_behavior/cannibalize/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/// Subtree to find icy rocks and create sculptures out of them
/datum/ai_planning_subtree/sculpt_statues

/datum/ai_planning_subtree/sculpt_statues/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_TARGET_ROCK))
		controller.queue_behavior(/datum/ai_behavior/sculpt_statue, BB_TARGET_ROCK)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/find_and_set, BB_TARGET_ROCK, /obj/structure/flora/ash/rock)

/datum/ai_behavior/sculpt_statue
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 5 MINUTES

/datum/ai_behavior/sculpt_statue/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/sculpt_statue/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	if(!controller.ai_interact(target = target_key, intent = INTENT_HELP))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/sculpt_statue/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)


/// Select appropriate ability based on range
/datum/ai_planning_subtree/targeted_mob_ability/ash_whelp
	operational_datums = list(/datum/component/ai_target_timer)

/datum/ai_planning_subtree/targeted_mob_ability/ash_whelp/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[target_key]
	if(isnull(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/time_on_target = controller.blackboard[BB_BASIC_MOB_HAS_TARGET_TIME] || 0
	if(time_on_target < MIN_TIME_TO_BREATH_WEAPON)
		return // We need to spend some time acquiring our target first

	var/dist_to_target = get_dist(controller.pawn, target)
	var/datum/action/cooldown/mob_cooldown/fire_breath/short_range_ability = controller.blackboard[BB_WHELP_WIDESPREAD_FIRE]
	if(isnull(short_range_ability) || dist_to_target > short_range_ability.fire_range)
		ability_key = BB_WHELP_STRAIGHTLINE_FIRE
		return ..()

	ability_key = BB_WHELP_WIDESPREAD_FIRE
	return ..()

/// subtree to look fortrees and burn them with our flamethrower
/datum/ai_planning_subtree/burn_trees

/datum/ai_planning_subtree/burn_trees/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/using_action = controller.blackboard[BB_WHELP_STRAIGHTLINE_FIRE]
	if(!using_action?.IsAvailable())
		return

	if(controller.blackboard_key_exists(BB_TARGET_TREE))
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_clear_target/burn_trees, BB_WHELP_STRAIGHTLINE_FIRE, BB_TARGET_TREE)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/set_target_tree, BB_TARGET_TREE)

/datum/ai_behavior/set_target_tree

/datum/ai_behavior/set_target_tree/perform(seconds_per_tick, datum/ai_controller/controller, tree_key)
	. = ..()
	var/mob/living_pawn = controller.pawn
	var/list/possible_trees = list()

	for(var/obj/structure/flora/tree/possible_tree in oview(9, living_pawn))
		possible_trees += possible_tree

	if(!length(possible_trees))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(tree_key, pick(possible_trees))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/targeted_mob_ability/and_clear_target/burn_trees
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	required_distance = 2
	action_cooldown = 2 MINUTES

/datum/ai_behavior/targeted_mob_ability/and_clear_target/burn_trees/setup(datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	var/obj/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

#undef MIN_TIME_TO_BREATH_WEAPON
