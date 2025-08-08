#define BURROW_RANGE 5
/datum/ai_controller/basic_controller/goldgrub
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_ORE_IGNORE_TYPES = list(/obj/item/stack/ore/iron, /obj/item/stack/ore/glass),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/burrow_through_ground,
		/datum/ai_planning_subtree/dig_away_from_danger,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores,
		/datum/ai_planning_subtree/mine_walls,
	)
/// Only dig away if humans are around
/datum/ai_planning_subtree/dig_away_from_danger
	/// Does it burrow?
	var/will_burrow = TRUE

/datum/ai_planning_subtree/dig_away_from_danger/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/has_target = controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET)

	// Someone is nearby, its time to escape
	if(will_burrow && has_target && ishuman(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]))
		controller.queue_behavior(/datum/ai_behavior/burrow_away)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/burrow_away
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// How long until the grub burrows
	var/chase_time = 10 SECONDS

/datum/ai_behavior/burrow_away/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/mining/goldgrub/grub = controller.pawn
	grub.addtimer(CALLBACK(grub, PROC_REF(Burrow)), chase_time)
