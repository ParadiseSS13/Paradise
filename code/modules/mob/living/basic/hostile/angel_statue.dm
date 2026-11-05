#define BB_STATUE_SPELL_COOLDOWN "BB_STATUE_SPELL_COOLDOWN"
#define BB_STATUE_FLICKER_LIGHTS_ACTION "BB_STATUE_FLICKER_LIGHTS_ACTION"
#define BB_STATUE_BLINDNESS_ACTION "BB_STATUE_BLINDNESS_ACTION"
#define BB_STATUE_NIGHT_VISION_ACTION "BB_STATUE_NIGHT_VISION_ACTION"

/datum/ai_controller/basic_controller/statue
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	max_target_distance = 15
	planning_subtrees = list(
		/datum/ai_planning_subtree/targeted_mob_ability/statue_cast_darkness_spells,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_light_fixtures,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
	)

/datum/ai_planning_subtree/targeted_mob_ability/statue_cast_darkness_spells
	#warn this might need to be increased but testing is required
	var/darkness_spellcasting_delay = 2 SECONDS
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/statue_spell

/datum/ai_planning_subtree/targeted_mob_ability/statue_cast_darkness_spells/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	// Always try to cast flicker_lights or blindness to create darkness
	var/mob/living/basic/hostile/statue/pawn = controller.pawn
	if(!pawn)
		return

	// Only cast if we're being watched (can't move/attack)
	var/being_watched = pawn.can_be_seen(null)
	if(!being_watched)
		return // Not being watched, can move/attack normally
	// Being watched - prioritize flicker_lights and blindness
	var/list/ability_keys = list(BB_STATUE_FLICKER_LIGHTS_ACTION, BB_STATUE_BLINDNESS_ACTION)
	var/ability_key = pick_n_take(ability_keys)
	var/datum/action/cooldown/mob_cooldown/selected_action = controller.blackboard[ability_key]
	while(selected_action && !selected_action.IsAvailable())
		if(!length(ability_keys))
			return
		ability_key = pick_n_take(ability_keys)
		selected_action = controller.blackboard[ability_key]

	if(selected_action)
		controller.set_blackboard_key(BB_STATUE_SPELL_COOLDOWN, world.time + darkness_spellcasting_delay)
		return ..()

	// No spells available, but we're being watched
	if(pawn && istype(pawn, /mob/living/basic/hostile/statue) && pawn.can_be_seen(null))
		controller.set_blackboard_key(BB_STATUE_SPELL_COOLDOWN, world.time + 1 SECONDS)
	return

/datum/ai_behavior/targeted_mob_ability/statue_spell
	/datum/ai_behavior/targeted_mob_ability/statue_spell/perform(seconds_per_tick, datum/ai_controller/controller, ability_key, target_key)
		. = ..()
		var/datum/action/cooldown/ability = controller.blackboard[ability_key]
		var/mob/living/target = controller.blackboard[target_key]
		if(QDELETED(ability) || QDELETED(target))
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

		var/result = ability.Trigger(target = target)
		if(result)
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/mob/living/basic/hostile/statue
	name = "statue" // matches the name of the statue with the flesh-to-stone spell
	desc = "An incredibly lifelike marble carving. Its eyes seems to follow you.." // same as an ordinary statue with the added "eye following you" description
	icon = 'icons/obj/statue.dmi'
	icon_state = "angel"
	icon_living = "angel"
	icon_dead = "angel"
	a_intent = INTENT_HARM
	mob_biotypes = MOB_HUMANOID
	ai_controller = /datum/ai_controller/basic_controller/statue

	speed = -1
	maxHealth = 50000
	health = 50000
	healable = FALSE

	harm_intent_damage = 35
	obj_damage = 100
	melee_damage_lower = 34
	melee_damage_upper = 42
	attack_verb_simple = "scratches"
	attack_verb_continuous = "scratches"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	unsuitable_atmos_damage = 0

	faction = list("statue")
	// move_to_delay = 0 // Very fast

	animate_movement = NO_STEPS // Do not animate movement, you jump around as you're a scary statue.

	see_in_dark = 8

	// search_objects = 1 // So that it can see through walls
	#warn XRAY HAX BAN HE

	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS
	move_force = MOVE_FORCE_EXTREMELY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	pull_force = MOVE_FORCE_EXTREMELY_STRONG
	status_flags = GODMODE // Cannot push also

	var/cannot_be_seen = TRUE
	var/mob/living/creator = null

	var/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/statue/flicker_lights = BB_STATUE_FLICKER_LIGHTS_ACTION,
		/datum/action/cooldown/mob_cooldown/statue/blindness = BB_STATUE_BLINDNESS_ACTION,
		/datum/action/cooldown/mob_cooldown/statue/night_vision = BB_STATUE_NIGHT_VISION_ACTION,
	)

/mob/living/basic/hostile/statue/proc/can_be_seen(turf/destination)
	if(!cannot_be_seen)
		return null
	// Check for darkness
	var/turf/T = get_turf(loc)
	var/turf/D = destination
	if(!D)
		D = T
	// if both our current and destination turfs are dark, no one can see us
	if(T.get_lumcount() * 10 < 1 && D.get_lumcount() * 10 < 1)
		return null

	// We aren't in darkness, loop for viewers.
	var/list/check_list = list(src)
	if(destination)
		check_list += destination

	// This loop will, at most, loop twice.
	for(var/atom/check in check_list)
		for(var/mob/living/M in viewers(world.view + 1, check) - src)
			if(M.client && !is_ai(M)) // AI cannot use their infinite view to stop us.
				if(M.has_vision())
					return M
		for(var/obj/mecha/M in view(world.view + 1, check)) //assuming if you can see them they can see you
			if(M.occupant && M.occupant.client)
				if(M.occupant.has_vision())
					return M.occupant
	return null

/mob/living/basic/hostile/statue/Initialize(mapload, mob/living/creator)
	. = ..()
	grant_actions_by_list(innate_actions)

	// Set creator
	if(creator)
		src.creator = creator

/mob/living/basic/hostile/statue/Destroy()
	creator = null
	return ..()

/mob/living/basic/hostile/statue/melee_attack(atom/target, list/modifiers)
	if(can_be_seen(null))
		return FALSE
	return ..()

/mob/living/basic/hostile/statue/Move(turf/NewLoc)
	if(can_be_seen(NewLoc))
		if(client)
			to_chat(src, SPAN_WARNING("You cannot move, there are eyes on you!"))
		return 0
	return ..()

/mob/living/basic/hostile/statue/face_atom()
	if(!can_be_seen(get_turf(loc)))
		return ..()
