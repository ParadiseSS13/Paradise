/datum/ai_controller/basic_controller/bluespace_horror
	movement_delay = 1 SECONDS
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_AGGRO_RANGE = 7,
	)
	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	interesting_dist = AI_MEGAFAUNA_INTERESTING_DIST
	max_target_distance = 15
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/corpses/human,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/horror_offensive_spellcasting,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path/walls,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl/walls,
	)

/datum/ai_planning_subtree/targeted_mob_ability/horror_offensive_spellcasting
	ability_key = BB_HORROR_FIREBALL_FAN_ACTION
	/// Minimum time between any spells
	var/horror_global_spellcasting_delay = 2 SECONDS

/datum/ai_planning_subtree/targeted_mob_ability/horror_offensive_spellcasting/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_HORROR_SPELL_COOLDOWN] >= world.time)
		return
	var/list/ability_keys = list(BB_HORROR_FIREBALL_FAN_ACTION, BB_HORROR_LIFESTEAL_BOLT_ACTION, BB_HORROR_MAGIC_MISSILE_ACTION, BB_HORROR_CHARGE_ACTION, BB_HORROR_SUMMON_MOBS_ACTION)
	ability_key = pick_n_take(ability_keys)
	var/datum/action/cooldown/mob_cooldown/selected_action = controller.blackboard[ability_key]
	while(selected_action && !selected_action.IsAvailable())
		if(!ability_keys.len) // All spells are on cooldown
			return
		ability_key = pick_n_take(ability_keys)
		selected_action = controller.blackboard[ability_key]
	controller.set_blackboard_key(BB_HORROR_SPELL_COOLDOWN, world.time + horror_global_spellcasting_delay)
	return ..()

/// Dodge!
/datum/ai_behavior/horror_blink_dodge
	action_cooldown = 6 SECONDS
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/horror_blink_dodge/perform(seconds_per_tick, datum/ai_controller/controller, action_key)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/bluespace_horror/blink/blink_action = controller.blackboard[action_key]
	var/result = blink_action.Trigger()
	if(result)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/// Bring them down!
/datum/ai_behavior/omega_fireball_fan
	action_cooldown = 10 MINUTES
	required_distance = 0

/datum/ai_behavior/omega_fireball_fan/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	. = ..()
	var/mob/living/basic/megafauna/bluespace_horror/user = controller.pawn
	user.say("I WILL NOT BE BANISHED SO EASILY!")
	spawn(1 SECONDS)
		var/turf/start_turf = get_step(user, pick(GLOB.alldirs))
		var/counter = rand(1, 16)
		playsound(get_turf(user), 'sound/magic/invoke_general.ogg', 200, TRUE)
		for(var/i in 1 to 80)
			counter++
			if(counter > 16)
				counter = 1
			var/obj/projectile/proj = pick(/obj/projectile/magic/lifesteal_bolt, /obj/projectile/magic/fireball, /obj/projectile/magic/magic_missile/lesser, /obj/projectile/magic/bluespace_shards)
			user.shoot_projectile(start_turf, proj, counter * 22.5)
			playsound(get_turf(user), 'sound/magic/staff_chaos.ogg', 50, TRUE)
			sleep(1)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
