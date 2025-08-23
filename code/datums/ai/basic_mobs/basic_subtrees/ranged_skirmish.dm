/// Fire a ranged attack without interrupting movement.
/datum/ai_planning_subtree/ranged_skirmish
	operational_datums = list(/datum/component/ranged_attacks)
	/// Blackboard key holding target atom
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// What AI behaviour do we actually run?
	var/attack_behavior = /datum/ai_behavior/ranged_skirmish
	/// If target is further away than this we don't fire
	var/max_range = 9
	/// If target is closer than this we don't fire
	var/min_range = 2

/datum/ai_planning_subtree/ranged_skirmish/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(!controller.blackboard_key_exists(target_key))
		return
	controller.queue_behavior(attack_behavior, target_key, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, max_range, min_range)

/// How often will we try to perform our ranged attack?
/datum/ai_behavior/ranged_skirmish
	action_cooldown = 0.5 SECONDS
	/// Do we care about shooting friends?
	var/avoid_friendly_fire = FALSE

/datum/ai_behavior/ranged_skirmish/setup(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key, max_range, min_range)
	. = ..()
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	return !QDELETED(target)

/datum/ai_behavior/ranged_skirmish/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key, max_range, min_range)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(!targeting_strategy.can_attack(controller.pawn, target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/hiding_target = targeting_strategy.find_hidden_mobs(controller.pawn, target)
	controller.set_blackboard_key(hiding_location_key, hiding_target)

	target = hiding_target || target

	var/distance = get_dist(controller.pawn, target)
	if(distance > max_range || distance < min_range)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(avoid_friendly_fire && check_friendly_in_path(controller.pawn, target, targeting_strategy))
		return AI_BEHAVIOR_DELAY

	if(avoid_friendly_fire && check_friendly_in_path(controller.pawn, target, targeting_strategy))
		return AI_BEHAVIOR_DELAY

	controller.ai_interact(target = target, intent = INTENT_HARM)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/ranged_skirmish/proc/check_friendly_in_path(mob/living/source, atom/target, datum/targeting_strategy/targeting_strategy)
	var/list/turfs_list = calculate_trajectory(source, target)
	for(var/turf/possible_turf as anything in turfs_list)

		for(var/mob/living/potential_friend in possible_turf)
			if(!targeting_strategy.can_attack(source, potential_friend))
				return TRUE

	return FALSE

/datum/ai_behavior/ranged_skirmish/proc/calculate_trajectory(mob/living/source, atom/target)
	var/list/turf_list = get_line(source, target)
	var/list_length = length(turf_list) - 1
	for(var/i in 1 to list_length)
		var/turf/current_turf = turf_list[i]
		var/turf/next_turf = turf_list[i + 1]
		var/direction_to_turf = get_dir(current_turf, next_turf)
		if(!IS_DIR_DIAGONAL(direction_to_turf))
			continue

		for(var/cardinal_direction in GLOB.cardinal)
			if(cardinal_direction & direction_to_turf)
				turf_list += get_step(current_turf, cardinal_direction)

	turf_list -= get_turf(source)
	turf_list -= get_turf(target)

	return turf_list

/datum/ai_planning_subtree/ranged_skirmish/no_minimum
	min_range = 0

/datum/ai_planning_subtree/ranged_skirmish/avoid_friendly
	attack_behavior = /datum/ai_behavior/ranged_skirmish/avoid_friendly

/datum/ai_behavior/ranged_skirmish/avoid_friendly
	avoid_friendly_fire = TRUE
