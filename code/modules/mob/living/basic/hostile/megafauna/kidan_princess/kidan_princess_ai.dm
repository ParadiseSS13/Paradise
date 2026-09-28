/datum/ai_controller/basic_controller/kidan_princess
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/kidan_warrior,
		BB_AGGRO_RANGE = 9,
		BB_SEARCH_RANGE = 10,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/corpses/human,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/kidan_princess_spellcasting,
		/datum/ai_planning_subtree/attack_obstacle_in_path/walls,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
	ai_movement = /datum/ai_movement/jps
	interesting_dist = AI_MEGAFAUNA_INTERESTING_DIST
	max_target_distance = 15

/datum/ai_planning_subtree/targeted_mob_ability/kidan_princess_spellcasting
	ability_key = BB_KIDAN_PRINCESS_CHARGE_ACTION
	/// Minimum time between any spells
	var/kidan_princess_global_spellcasting_delay = 6 SECONDS

/datum/ai_planning_subtree/targeted_mob_ability/kidan_princess_spellcasting/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_KIDAN_PRINCESS_SPELL_COOLDOWN] >= world.time)
		return
	var/list/ability_keys = list(BB_KIDAN_PRINCESS_CHARGE_ACTION, BB_KIDAN_PRINCESS_SUMMON_MOBS_ACTION, BB_KIDAN_PRINCESS_RUSH_ACTION, BB_KIDAN_PRINCESS_STOMP_ACTION)
	ability_key = pick_n_take(ability_keys)
	var/datum/action/cooldown/mob_cooldown/selected_action = controller.blackboard[ability_key]
	while(selected_action && !selected_action.IsAvailable())
		if(!ability_keys.len) // All spells are on cooldown
			return
		ability_key = pick_n_take(ability_keys)
		selected_action = controller.blackboard[ability_key]
	if(ability_key == BB_KIDAN_PRINCESS_RUSH_ACTION)
		controller.set_blackboard_key(BB_KIDAN_PRINCESS_SPELL_COOLDOWN, world.time + 16 SECONDS)
	else
		controller.set_blackboard_key(BB_KIDAN_PRINCESS_SPELL_COOLDOWN, world.time + kidan_princess_global_spellcasting_delay)
	return ..()
