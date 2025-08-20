/datum/ai_controller/basic_controller/hivebot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/hive_communicate,
	)

/datum/ai_controller/basic_controller/hivebot/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/hivebot,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/hive_communicate,
	)

/datum/ai_controller/basic_controller/hivebot/ranged/rapid
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/hivebot_rapid,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/hive_communicate,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/hivebot_rapid
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/hivebot_rapid

/datum/ai_planning_subtree/basic_ranged_attack_subtree/hivebot
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/hivebot

/datum/ai_planning_subtree/hive_communicate
	/// chance to go and relay message
	var/relay_chance = 10

/datum/ai_planning_subtree/hive_communicate/select_behaviors(datum/ai_controller/controller, seconds_per_tick)

	if(!SPT_PROB(relay_chance, seconds_per_tick))
		return

	for(var/mob/living/listener in hearers(11, controller.pawn))
		if(listener.client && listener.stat != DEAD)
			if(controller.blackboard_key_exists(BB_HIVE_PARTNER))
				controller.queue_behavior(/datum/ai_behavior/relay_message, BB_HIVE_PARTNER)
				return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/find_and_set/hive_partner, BB_HIVE_PARTNER, /mob/living/basic/hivebot)

/datum/ai_behavior/find_and_set/hive_partner

/datum/ai_behavior/find_and_set/hive_partner/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/living_pawn = controller.pawn
	var/list/hive_partners = list()
	for(var/mob/living/target in oview(10, living_pawn))
		if(!istype(target, locate_path))
			continue
		if(target.stat == DEAD)
			continue
		hive_partners += target

	if(length(hive_partners))
		return pick(hive_partners)

/// behavior that allow us to go communicate with other hivebots
/datum/ai_behavior/relay_message
	/// length of the message we will relay
	var/length_of_message = 4
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT| AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/relay_message/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]
	// It stopped existing
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/relay_message/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/message_relayed = ""
	for(var/i in 1 to length_of_message)
		message_relayed += prob(50) ? "1" : "0"
	living_pawn.say(message_relayed)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/relay_message/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/basic_ranged_attack/hivebot
	action_cooldown = 3 SECONDS
	avoid_friendly_fire = TRUE

/datum/ai_behavior/basic_ranged_attack/hivebot_rapid
	action_cooldown = 1 SECONDS
	avoid_friendly_fire = TRUE

/datum/ai_controller/basic_controller/beacon
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = null
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/warpbots,
		/datum/ai_planning_subtree/hive_communicate,
	)

/datum/ai_planning_subtree/warpbots
	/// chance to summon hivebots
	var/warp_chance = 2

/datum/ai_planning_subtree/warpbots/select_behaviors(datum/ai_controller/controller, seconds_per_tick)

	if(!SPT_PROB(warp_chance, seconds_per_tick))
		return

	if(controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		var/mob/living/basic/hivebot/tele/beacon = controller.pawn
		beacon.warpbots()
		return SUBTREE_RETURN_FINISH_PLANNING
