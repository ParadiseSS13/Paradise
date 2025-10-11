/// Attacks people it can see, spins webs if it can't see anything to attack.
/datum/ai_controller/basic_controller/giant_spider
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	movement_delay = 1 SECONDS
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED | AI_FLAG_PAUSE_DURING_DO_AFTER

	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_unwebbed_turf,
		/datum/ai_planning_subtree/spin_web,
	)

/datum/ai_controller/basic_controller/giant_spider/nurse
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/lay_eggs,
		/datum/ai_planning_subtree/find_unwrapped_target,
		/datum/ai_planning_subtree/find_unwebbed_turf,
		/datum/ai_planning_subtree/wrap_target,
		/datum/ai_planning_subtree/spin_web,
	)

/datum/ai_controller/basic_controller/giant_spider/changeling
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends/changeling_spiders,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target/cling_spider,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/cling_spider_follow,
	)

/// Used by Araneus, who only attacks those who attack first. He is house-trained and will not web up the HoS office.
/datum/ai_controller/basic_controller/giant_spider/retaliate
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/targeting_strategy/basic/not_friends/changeling_spiders

/datum/targeting_strategy/basic/not_friends/changeling_spiders/can_attack(mob/living/living_mob, atom/target, vision_range)
	if(living_mob?.ai_controller?.blackboard[BB_CHANGELING_SPIDER_ORDER] && (living_mob?.ai_controller?.blackboard[BB_CHANGELING_SPIDER_ORDER] == FOLLOW_RETALIATE || living_mob?.ai_controller?.blackboard[BB_CHANGELING_SPIDER_ORDER] == IDLE_RETALIATE))
		return FALSE
	return ..()

/datum/ai_planning_subtree/random_speech/insect
	speech_chance = 2
	sound = list('sound/creatures/chitter.ogg')
	emote_hear = list("chitters.")

/// Search for a nearby location to put webs on
/datum/ai_planning_subtree/find_unwebbed_turf

/datum/ai_planning_subtree/find_unwebbed_turf/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/find_unwebbed_turf)

/// Find an unwebbed nearby turf and store it
/datum/ai_behavior/find_unwebbed_turf
	action_cooldown = 5 SECONDS
	/// Where do we store the target data
	var/target_key = BB_SPIDER_WEB_TARGET
	/// How far do we look for unwebbed turfs?
	var/scan_range = 3

/datum/ai_behavior/find_unwebbed_turf/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/spider = controller.pawn
	var/atom/current_target = controller.blackboard[target_key]
	if(current_target && !(locate(/obj/structure/spider/stickyweb) in current_target))
		// Already got a target
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.clear_blackboard_key(target_key)
	var/turf/our_turf = get_turf(spider)
	if(is_valid_web_turf(our_turf, spider))
		controller.set_blackboard_key(target_key, our_turf)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	var/list/turfs_by_range = list()
	for(var/i in 1 to scan_range)
		turfs_by_range["[i]"] = list()
	for(var/turf/turf_in_view in oview(scan_range, our_turf))
		if(!is_valid_web_turf(turf_in_view, spider))
			continue
		turfs_by_range["[get_dist(our_turf, turf_in_view)]"] += turf_in_view

	var/list/final_turfs
	for(var/list/turf_list as anything in turfs_by_range)
		if(length(turfs_by_range[turf_list]))
			final_turfs = turfs_by_range[turf_list]
			break
	if(!length(final_turfs))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(target_key, pick(final_turfs))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/find_unwebbed_turf/proc/is_valid_web_turf(turf/target_turf, mob/living/spider)
	if(locate(/obj/structure/spider/stickyweb) in target_turf)
		return FALSE
	if(HAS_TRAIT(target_turf, TRAIT_SPINNING_WEB_TURF))
		return FALSE
	return !target_turf.is_blocked_turf(source_atom = spider)

/// Run the spin web behaviour if we have an ability to use for it
/datum/ai_planning_subtree/spin_web
	/// Key where the web spinning action is stored
	var/action_key = BB_SPIDER_WEB_ACTION
	/// Key where the target turf is stored
	var/target_key = BB_SPIDER_WEB_TARGET

/datum/ai_planning_subtree/spin_web/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(action_key) && controller.blackboard_key_exists(target_key))
		controller.queue_behavior(/datum/ai_behavior/spin_web, action_key, target_key)
		return SUBTREE_RETURN_FINISH_PLANNING

/// Move to an unwebbed nearby turf and web it up
/datum/ai_behavior/spin_web
	action_cooldown = 10 SECONDS // We don't want them doing this too quickly
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/spin_web/setup(datum/ai_controller/controller, action_key, target_key)
	var/datum/action/innate/web_giant_spider/web_action = controller.blackboard[action_key]
	var/turf/target_turf = controller.blackboard[target_key]
	if(!web_action || !target_turf)
		return FALSE

	set_movement_target(controller, target_turf)
	return ..()

/datum/ai_behavior/spin_web/perform(seconds_per_tick, datum/ai_controller/controller, action_key, target_key)
	var/datum/action/innate/web_giant_spider/web_action = controller.blackboard[action_key]
	if(web_action?.Trigger())
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/spin_web/finish_action(datum/ai_controller/controller, succeeded, action_key, target_key)
	controller.clear_blackboard_key(target_key)
	return ..()

/// Search for a nearby location to put webs on
/datum/ai_planning_subtree/find_unwrapped_target

/datum/ai_planning_subtree/find_unwrapped_target/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/find_unwrapped_target)

/// Find an unwrapped target and store it
/datum/ai_behavior/find_unwrapped_target
	action_cooldown = 5 SECONDS
	/// Where do we store the target data
	var/target_key = BB_SPIDER_WRAP_TARGET
	/// How far do we look for unwebbed items?
	var/scan_range = 3

/datum/ai_behavior/find_unwrapped_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/spider = controller.pawn
	var/atom/current_target = controller.blackboard[target_key]
	if(current_target)
		// Already got a target
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	// Prioritize food
	var/list/food = list()
	var/list/can_see = view(scan_range, spider)
	for(var/mob/living/C in can_see)
		if(C.stat && !istype(C, /mob/living/basic/giant_spider) && !C.anchored)
			food += C
	if(length(food))
		controller.set_blackboard_key(target_key, pick(food))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	var/list/objects = list()
	for(var/obj/O in can_see)
		if(O.anchored)
			continue
		if(istype(O, /obj/structure/spider))
			continue // Don't web up spider structures or spiderlings
		if(isitem(O) || isstructure(O) || ismachinery(O))
			objects += O
	if(length(objects))
		controller.set_blackboard_key(target_key, pick(objects))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Run the wrap behaviour if we have an ability to use for it
/datum/ai_planning_subtree/wrap_target
	/// Key where the web spinning action is stored
	var/action_key = BB_SPIDER_WRAP_ACTION
	/// Key where the target is stored
	var/target_key = BB_SPIDER_WRAP_TARGET

/datum/ai_planning_subtree/wrap_target/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(action_key) && controller.blackboard_key_exists(target_key))
		controller.queue_behavior(/datum/ai_behavior/wrap_target, action_key, target_key)
		return SUBTREE_RETURN_FINISH_PLANNING

/// Move to an unwrapped item and wrap it
/datum/ai_behavior/wrap_target
	action_cooldown = 15 SECONDS // We don't want them doing this too quickly
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/wrap_target/setup(datum/ai_controller/controller, action_key, target_key)
	var/datum/action/innate/wrap_giant_spider/wrap_action = controller.blackboard[action_key]
	var/atom/target = controller.blackboard[target_key]
	var/turf/target_turf = get_turf(target)
	if(!wrap_action || !target_turf)
		return FALSE

	set_movement_target(controller, target_turf)
	return ..()

/datum/ai_behavior/wrap_target/perform(seconds_per_tick, datum/ai_controller/controller, action_key, target_key)
	var/datum/action/innate/wrap_giant_spider/wrap_action = controller.blackboard[action_key]
	if(wrap_action?.Trigger())
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/wrap_target/finish_action(datum/ai_controller/controller, succeeded, action_key, target_key)
	controller.clear_blackboard_key(target_key)
	return ..()

/// Run the egg laying behavior
/datum/ai_planning_subtree/lay_eggs
	/// Key where the egg laying action is stored
	var/action_key = BB_SPIDER_EGG_LAYING_ACTION

/datum/ai_planning_subtree/lay_eggs/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/giant_spider/nurse/spider = controller.pawn
	if(controller.blackboard_key_exists(action_key) && spider.fed > 0)
		controller.queue_behavior(/datum/ai_behavior/lay_eggs, action_key)
		return SUBTREE_RETURN_FINISH_PLANNING

/// Attempt to lay eggs if we're fed
/datum/ai_behavior/lay_eggs
	action_cooldown = 2 MINUTES
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/lay_eggs/setup(datum/ai_controller/controller, action_key)
	var/datum/action/innate/lay_eggs_giant_spider/egg_action = controller.blackboard[action_key]
	if(!egg_action)
		return FALSE
	return ..()

/datum/ai_behavior/lay_eggs/perform(seconds_per_tick, datum/ai_controller/controller, action_key)
	var/datum/action/innate/lay_eggs_giant_spider/egg_action = controller.blackboard[action_key]
	if(egg_action?.Trigger())
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Spider only attacks when it has the valid order.
/datum/ai_planning_subtree/simple_find_target/cling_spider

/datum/ai_planning_subtree/simple_find_target/cling_spider/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_CHANGELING_SPIDER_ORDER] == FOLLOW_RETALIATE || controller.blackboard[BB_CHANGELING_SPIDER_ORDER] == IDLE_RETALIATE)
		return
	return ..()

/// Spider follows who created it
/datum/ai_planning_subtree/cling_spider_follow
	/// Key where the owner is stored
	var/target_key = BB_CURRENT_PET_TARGET

/datum/ai_planning_subtree/cling_spider_follow/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(target_key) && controller.blackboard[BB_CHANGELING_SPIDER_ORDER] < IDLE_AGGRESSIVE)
		controller.queue_behavior(/datum/ai_behavior/cling_spider_follow, target_key)
		return SUBTREE_RETURN_FINISH_PLANNING

/// Attempt to follow the owner
/datum/ai_behavior/cling_spider_follow
	required_distance = 0
	behavior_flags =  AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/cling_spider_follow/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/cling_spider_follow/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_DELAY
