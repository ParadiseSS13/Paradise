/// Attack something which is already adjacent to us, without ending planning
/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/opportunistic
	end_planning = FALSE
	/// Who to hit
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// Our targeting strategy
	var/targeting_key = BB_TARGETING_STRATEGY

/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target) || !controller.pawn.Adjacent(target))
		return
	controller.queue_behavior(melee_attack_behavior, target_key, targeting_key, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

/// Attack something which is already adjacent to us without moving
/datum/ai_behavior/basic_melee_attack/opportunistic
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/basic_melee_attack/opportunistic/setup(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	if(!controller.blackboard_key_exists(targeting_strategy_key))
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")
	return controller.blackboard_key_exists(target_key)

/datum/ai_behavior/basic_melee_attack/opportunistic/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/atom/movable/atom_pawn = controller.pawn
	if(!atom_pawn.can_reach(controller.blackboard[target_key]))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	. = ..()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic/from_flee_key
	target_key = BB_BASIC_MOB_FLEE_TARGET
	targeting_key = BB_FLEE_TARGETING_STRATEGY
