/datum/ai_controller/basic_controller/minebot/abandoned_minebot_ranged
	blackboard = list(
		BB_BASIC_MOB_CURRENT_TARGET = null,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/always_check_factions,
		BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION = null,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 4,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 6,
		BB_AUTOMATED_MINING = TRUE,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_TARGET_MINERAL_TURF = null,
		BB_BLACKLIST_MINERAL_TURFS = list(),
		BB_PREVIOUS_UNREACHABLE_WALL = null,
		BB_MINEBOT_GIBTONITE_RUN = null
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/flee_target/minebot_gibtonite,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/abandoned_minebot,
		/datum/ai_planning_subtree/simple_find_target/not_while_observed,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/abandoned_minebot,
		/datum/ai_planning_subtree/minebot_mining
	)

/// store ores in our body
/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/abandoned_minebot
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/consume_ores/minebot
	hunt_chance = 100
	hunt_range = 4

/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/abandoned_minebot/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	// if we're not mining, don't pick up ores
	if(!controller.blackboard[BB_AUTOMATED_MINING])
		return

	return ..()

/datum/ai_planning_subtree/basic_ranged_attack_subtree/abandoned_minebot
	operational_datums = null
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/minebot

/datum/ai_planning_subtree/basic_ranged_attack_subtree/abandoned_minebot/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.a_intent != INTENT_HARM)
		return
	controller.queue_behavior(ranged_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_TARGET_MINIMUM_STAT, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	return SUBTREE_RETURN_FINISH_PLANNING
