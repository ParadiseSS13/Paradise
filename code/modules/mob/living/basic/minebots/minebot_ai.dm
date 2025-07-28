/datum/ai_controller/basic_controller/minebot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/always_check_factions,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_MINIMUM_SHOOTING_DISTANCE = 3,
		BB_MINEBOT_PLANT_MINES = TRUE,
		BB_MINEBOT_REPAIR_DRONE = TRUE,
		BB_MINEBOT_AUTO_DEFEND = TRUE,
		BB_BLACKLIST_MINERAL_TURFS = list(),
		BB_AUTOMATED_MINING = FALSE,
		BB_OWNER_SELF_HARM_RESPONSES = list(
			"Please stop hurting yourself.",
			"There is no need to do that.",
			"Your actions are illogical.",
			"Please make better choices.",
			"Remember, you have beaten your worst days before.",
		),
		BB_OWNER_FRIENDLY_FIRE_APOLOGIES = list(
			"Sorry.",
			"My fault.",
			"Oops.",
		),
	)

	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/befriend_miners,
		/datum/ai_planning_subtree/minebot_maintain_distance,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/minebot,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/minebot,
		/datum/ai_planning_subtree/minebot_mining,
		/datum/ai_planning_subtree/flee_target/minebot_gibtonite,
		/datum/ai_planning_subtree/locate_dead_humans,
	)
	ai_traits = AI_FLAG_PAUSE_DURING_DO_AFTER

/datum/ai_planning_subtree/befriend_miners/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_MINER_FRIEND))
		return
	controller.queue_behavior(/datum/ai_behavior/befriend_target, BB_MINER_FRIEND)

/// Find dead humans and report their location on the radio
/datum/ai_planning_subtree/locate_dead_humans/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_NEARBY_DEAD_MINER))
		controller.queue_behavior(/datum/ai_behavior/send_sos_message, BB_NEARBY_DEAD_MINER)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/find_and_set/unconscious_human, BB_NEARBY_DEAD_MINER, /mob/living/carbon/human)

/datum/ai_behavior/find_and_set/unconscious_human/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	// For now, we only look for friends, and we only befriend the person
	// who created us, so we're not screaming on comms about every single
	// dead player that we find
	if(!controller.blackboard_key_exists(BB_FRIENDS_LIST))
		return null
	for(var/mob/living/carbon/human/target in oview(search_range, controller.pawn))
		if(!(target in controller.blackboard[BB_FRIENDS_LIST]))
			continue
		if(target.stat >= UNCONSCIOUS && target.mind)
			return target
	return null

/datum/ai_behavior/send_sos_message
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 2 MINUTES

/datum/ai_behavior/send_sos_message/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/carbon/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn
	if(QDELETED(target) || is_station_level(target.z))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/turf/target_turf = get_turf(target)
	var/obj/item/radio/radio = locate(/obj/item/radio) in living_pawn.contents
	if(!radio)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/message = message_to_multilingual("Miner in need of help at coordinates: [target_turf.x], [target_turf.y], [target_turf.z]!")
	radio.talk_into(living_pawn, message, "Supply")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/send_sos_message/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/// operational datums is null because we dont use a ranged component, we use a gun in our contents
/datum/ai_planning_subtree/basic_ranged_attack_subtree/minebot
	operational_datums = null
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/minebot

/datum/ai_planning_subtree/basic_ranged_attack_subtree/minebot/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.a_intent != INTENT_HARM)
		return
	controller.queue_behavior(ranged_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/minebot_maintain_distance/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return
	var/mob/living/living_pawn = controller.pawn
	if(get_dist(living_pawn, target) <= controller.blackboard[BB_MINIMUM_SHOOTING_DISTANCE])
		controller.queue_behavior(/datum/ai_behavior/run_away_from_target/run_and_shoot, BB_BASIC_MOB_CURRENT_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/basic_ranged_attack/minebot
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	avoid_friendly_fire = TRUE
	/// if our target is closer than this distance, finish action
	var/minimum_distance = 3

/datum/ai_behavior/basic_ranged_attack/minebot/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	minimum_distance = controller.blackboard[BB_MINIMUM_SHOOTING_DISTANCE] ?  controller.blackboard[BB_MINIMUM_SHOOTING_DISTANCE] : initial(minimum_distance)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/living_pawn = controller.pawn
	if(get_dist(living_pawn, target) <= minimum_distance)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// mine walls if we are on automated mining mode
/datum/ai_planning_subtree/minebot_mining/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_AUTOMATED_MINING])
		return
	if(controller.blackboard_key_exists(BB_MINEBOT_GIBTONITE_RUN))
		return
	if(controller.blackboard_key_exists(BB_TARGET_MINERAL_TURF))
		controller.queue_behavior(/datum/ai_behavior/minebot_mine_turf, BB_TARGET_MINERAL_TURF)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/find_mineral_wall/minebot, BB_TARGET_MINERAL_TURF)

/datum/ai_behavior/find_mineral_wall/minebot

/datum/ai_behavior/find_mineral_wall/minebot/check_if_mineable(datum/ai_controller/controller, turf/target_wall)
	var/list/forbidden_turfs = controller.blackboard[BB_BLACKLIST_MINERAL_TURFS]
	var/turf/previous_unreachable_wall = controller.blackboard[BB_PREVIOUS_UNREACHABLE_WALL]
	if(is_type_in_list(target_wall, forbidden_turfs) || target_wall == previous_unreachable_wall)
		return FALSE
	controller.clear_blackboard_key(BB_PREVIOUS_UNREACHABLE_WALL)
	return ..()

/datum/ai_behavior/minebot_mine_turf
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	required_distance = 2
	action_cooldown = 3 SECONDS

/datum/ai_behavior/minebot_mine_turf/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/minebot_mine_turf/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/living_pawn = controller.pawn
	var/turf/target = controller.blackboard[target_key]

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(check_obstacles_in_path(controller, target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/old_intent = living_pawn.a_intent
	if(living_pawn.a_intent != INTENT_HARM)
		living_pawn.a_intent = INTENT_HARM

	living_pawn.face_atom(target)

	var/turf/simulated/mineral/mineral_target = target
	if(istype(mineral_target) && istype(mineral_target.ore, /datum/ore/gibtonite))
		// Duplicate signals can occur when a minebot previously tried to mine a
		// turf and failed (e.g. something else was hit by the kpa projectile)
		RegisterSignal(mineral_target, COMSIG_MINE_EXPOSE_GIBTONITE, PROC_REF(on_mine_expose_gibtonite), override = TRUE)

	living_pawn.RangedAttack(target)
	living_pawn.a_intent = old_intent

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/minebot_mine_turf/proc/on_mine_expose_gibtonite(datum/source, mob/living/instigator)
	SIGNAL_HANDLER // COMSIG_MINE_EXPOSE_GIBTONITE

	UnregisterSignal(source, COMSIG_MINE_EXPOSE_GIBTONITE)
	instigator.emote("me", EMOTE_VISIBLE, "yelps!")
	instigator.ai_controller.set_blackboard_key(BB_MINEBOT_GIBTONITE_RUN, source)

/datum/ai_behavior/minebot_mine_turf/proc/check_obstacles_in_path(datum/ai_controller/controller, turf/target)
	var/mob/living/source = controller.pawn
	var/list/turfs_in_path = get_line(source, target) - target
	for(var/turf/turf as anything in turfs_in_path)
		if(turf.is_blocked_turf(exclude_mobs = TRUE))
			controller.set_blackboard_key(BB_PREVIOUS_UNREACHABLE_WALL, target)
			return TRUE
		for(var/mob/living/potential_friend in turf)
			if(source == potential_friend)
				continue
			if(controller.blackboard_key_exists(BB_FRIENDS_LIST) && (potential_friend in controller.blackboard[BB_FRIENDS_LIST]))
				return TRUE
			if(source.faction_check_mob(potential_friend))
				return TRUE
	return FALSE

/datum/ai_behavior/minebot_mine_turf/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/// store ores in our body
/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/minebot
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/consume_ores/minebot
	hunt_chance = 100
	hunt_range = 4

/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/minebot/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	// If we're not on automated mining mode, don't pick up ore
	// This is so we don't constantly pick up ore we were just told to drop
	// while in another mode
	if(!controller.blackboard[BB_AUTOMATED_MINING])
		return

	return ..()

/datum/ai_planning_subtree/flee_target/minebot_gibtonite
	target_key = BB_MINEBOT_GIBTONITE_RUN

/// pet commands
/datum/pet_command/free/minebot

/datum/pet_command/free/minebot/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_AUTOMATED_MINING, FALSE)
	return ..()

/datum/pet_command/automate_mining
	command_name = "Automate mining"
	command_desc = "Make your minebot automatically mine!"
	speech_commands = list("mine")

/datum/pet_command/automate_mining/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to start mining!"

/datum/pet_command/automate_mining/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_AUTOMATED_MINING, TRUE)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/pet_command/minebot_ability
	command_name = "Minebot ability"
	command_desc = "Make your minebot use one of its abilities."
	/// the ability we will use
	var/ability_key

/datum/pet_command/minebot_ability/execute_action(datum/ai_controller/controller)
	var/datum/action/ability = controller.blackboard[ability_key]
	if(!ability?.IsAvailable())
		return
	controller.queue_behavior(/datum/ai_behavior/use_mob_ability, ability_key)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/minebot_ability/light
	command_name = "Toggle lights"
	command_desc = "Make your minebot toggle its lights."
	speech_commands = list("light")
	ability_key = BB_MINEBOT_LIGHT_ABILITY

/datum/pet_command/minebot_ability/light/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to toggle its lights!"

/datum/pet_command/minebot_ability/dump
	command_name = "Dump ore"
	command_desc = "Make your minebot dump all its ore!"
	speech_commands = list("dump", "ore")
	ability_key = BB_MINEBOT_DUMP_ABILITY

/datum/pet_command/minebot_ability/dump/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to dump its ore!"

/datum/pet_command/attack/minebot
	attack_behaviour = /datum/ai_behavior/basic_ranged_attack/minebot

/datum/pet_command/attack/minebot/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_AUTOMATED_MINING, FALSE)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.a_intent != INTENT_HARM)
		living_pawn.a_intent = INTENT_HARM
	return ..()

/datum/pet_command/idle/minebot

/datum/pet_command/idle/minebot/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_AUTOMATED_MINING, FALSE)
	return ..()

/datum/pet_command/protect_owner/minebot

/datum/pet_command/protect_owner/minebot/set_command_target(mob/living/parent, atom/target)
	if(!parent.ai_controller.blackboard[BB_MINEBOT_AUTO_DEFEND])
		return FALSE
	if(!parent.ai_controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET) && !QDELETED(target)) //we are already dealing with something,
		parent.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
	return TRUE

/datum/pet_command/protect_owner/minebot/execute_action(datum/ai_controller/controller)
	if(controller.blackboard[BB_MINEBOT_AUTO_DEFEND])
		var/mob/living/living_pawn = controller.pawn
		living_pawn.a_intent = INTENT_HARM
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
