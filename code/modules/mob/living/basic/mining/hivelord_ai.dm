/// Keep away and launch skulls at every opportunity
/datum/ai_controller/basic_controller/hivelord
	movement_delay = 1.5 SECONDS
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_AGGRO_RANGE = 5,
		BB_BASIC_MOB_FLEE_DISTANCE = 3,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/summon_brood,
		/datum/ai_planning_subtree/flee_target/legion,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl/lavaland,
	)

/// With evil speech
/datum/ai_controller/basic_controller/hivelord/legion
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/legion,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/summon_brood,
		/datum/ai_planning_subtree/flee_target/legion,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl/lavaland,
	)

/datum/ai_controller/basic_controller/hivelord/legion/advanced
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = DEAD,
		BB_AGGRO_RANGE = 5,
		BB_BASIC_MOB_FLEE_DISTANCE = 3,
	)

/// Chase and attack whatever we are targeting
/datum/ai_controller/basic_controller/hivelord_brood
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_AGGRO_RANGE = 10,
	)
	ai_movement = /datum/ai_movement/jps // Not gonna get stuck on walls now, are ya?
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Same as hivelords, but go after corpses too
/datum/ai_controller/basic_controller/hivelord_brood/advanced_legion
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = DEAD,
		BB_AGGRO_RANGE = 10,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/corpses/human,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Big Legion
/datum/ai_controller/basic_controller/big_legion
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = DEAD,
		BB_AGGRO_RANGE = 5,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/legion,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl/lavaland,
	)

/// Don't run away from friendlies
/datum/ai_planning_subtree/flee_target/legion

/datum/ai_planning_subtree/flee_target/legion/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.faction_check_mob(controller.pawn))
		return // Only flee if we have a hostile target
	return ..()

/// Make spooky sounds, if we have a corpse inside then impersonate them
/datum/ai_planning_subtree/random_speech/legion
	speech_chance = 1
	speak = list("Come...", "Legion...", "Why...?")
	emote_hear = list("groans.", "wails.", "whimpers.")
	emote_see = list("twitches.", "shudders.")

/datum/ai_planning_subtree/random_speech/legion/speak(datum/ai_controller/controller)
	var/mob/living/carbon/human/victim = controller.blackboard[BB_LEGION_CORPSE]
	if(QDELETED(victim) || prob(30))
		return ..()

	if(victim.mind && victim.mind.miming) // mimes cant talk
		return

	var/list/remembered_speech = controller.blackboard[BB_LEGION_RECENT_LINES] || list()

	if(length(remembered_speech) && prob(50)) // Don't spam the radio
		controller.queue_behavior(/datum/ai_behavior/perform_speech, pick(remembered_speech))
		return

/// Create brood
/datum/ai_planning_subtree/summon_brood
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/summon_brood/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]
	if(!target)
		// Only summon if we have a hostile target
		return
	controller.queue_behavior(/datum/ai_behavior/summon_brood)

/datum/ai_behavior/summon_brood
	action_cooldown = 3 SECONDS
	behavior_flags = AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 0

/datum/ai_behavior/summon_brood/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/mining/hivelord/summoner = controller.pawn
	var/mob/living/basic/mining/hivelordbrood/A = new summoner.brood_type(summoner.loc)
	A.admin_spawned = summoner.admin_spawned
	A.faction = summoner.faction.Copy()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
