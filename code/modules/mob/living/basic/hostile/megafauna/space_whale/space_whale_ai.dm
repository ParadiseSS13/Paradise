/datum/ai_controller/basic_controller/space_whale
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
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/find_and_hunt_target/fish,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/whale_offensive_spellcasting,
		/datum/ai_planning_subtree/attack_obstacle_in_path/walls,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl/walls,
	)

/datum/ai_planning_subtree/targeted_mob_ability/whale_offensive_spellcasting
	ability_key = BB_WHALE_CHARGE_ACTION
	/// Minimum time between any spells
	var/whale_global_spellcasting_delay = 5 SECONDS

/datum/ai_planning_subtree/targeted_mob_ability/whale_offensive_spellcasting/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_WHALE_SPELL_COOLDOWN] >= world.time)
		return
	var/list/ability_keys = list(BB_WHALE_CHARGE_ACTION)
	ability_key = pick_n_take(ability_keys)
	var/datum/action/cooldown/mob_cooldown/selected_action = controller.blackboard[ability_key]
	while(selected_action && !selected_action.IsAvailable())
		if(!ability_keys.len) // All spells are on cooldown
			return
		ability_key = pick_n_take(ability_keys)
		selected_action = controller.blackboard[ability_key]
	controller.set_blackboard_key(BB_WHALE_SPELL_COOLDOWN, world.time + whale_global_spellcasting_delay)
	return ..()
