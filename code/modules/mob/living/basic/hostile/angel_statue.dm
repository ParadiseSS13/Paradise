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
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_light_fixtures,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/cause_darkness,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
	)

/datum/ai_planning_subtree/targeted_mob_ability/cause_darkness
	#warn this might need to be increased but testing is required
	var/darkness_spellcasting_delay = 5 SECONDS

/datum/ai_planning_subtree/targeted_mob_ability/cause_darkness/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_STATUE_SPELL_COOLDOWN] >= world.time)
		return
	var/list/ability_keys = list(BB_STATUE_FLICKER_LIGHTS_ACTION, BB_STATUE_BLINDNESS_ACTION, BB_STATUE_NIGHT_VISION_ACTION)
	var/ability_key = pick_n_take(ability_keys)
	var/datum/action/cooldown/mob_cooldown/selected_action = controller.blackboard[ability_key]
	while(selected_action && !selected_action.IsAvailable())
		if(!ability_keys.len)
			return
		ability_key = pick_n_take(ability_keys)
		selected_action = controller.blackboard[ability_key]
		controller.set_blackboard_key(BB_STATUE_SPELL_COOLDOWN, world.time + darkness_spellcasting_delay)
	return ..()

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

/mob/living/basic/hostile/statue/proc/can_be_seen(turf/destination)
	if(!cannot_be_seen)
		return null
	// Check for darkness
	var/turf/T = get_turf(loc)
	if(T && destination && T.lighting_object)
		if(T.get_lumcount() * 10 < 1 && destination.get_lumcount() * 10 < 1) // No one can see us in the darkness, right?
			return null
		if(T == destination)
			destination = null

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
	// Give spells
	AddSpell(new /datum/spell/aoe/flicker_lights(null))
	AddSpell(new /datum/spell/aoe/blindness(null))
	AddSpell(new /datum/spell/night_vision(null))

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
