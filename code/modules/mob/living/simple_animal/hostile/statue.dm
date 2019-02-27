// A mob which only moves when it isn't being watched by living beings.

/mob/living/simple_animal/hostile/statue
	name = "statue" // matches the name of the statue with the flesh-to-stone spell
	desc = "An incredibly lifelike marble carving. Its eyes seems to follow you.." // same as an ordinary statue with the added "eye following you" description
	icon = 'icons/obj/statue.dmi'
	icon_state = "angel"
	icon_living = "angel"
	icon_dead = "angel"
	gender = NEUTER
	a_intent = INTENT_HARM

	response_help = "touches"
	response_disarm = "pushes"

	speed = -1
	maxHealth = 50000
	health = 50000
	healable = 0

	harm_intent_damage = 35
	obj_damage = 100
	melee_damage_lower = 34
	melee_damage_upper = 42
	attacktext = "claws"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list("statue")
	move_to_delay = 0 // Very fast

	animate_movement = NO_STEPS // Do not animate movement, you jump around as you're a scary statue.

	see_in_dark = 13
	vision_range = 12
	aggro_vision_range = 12
	idle_vision_range = 12

	search_objects = 1 // So that it can see through walls

	see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS
	move_force = MOVE_FORCE_EXTREMELY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	pull_force = MOVE_FORCE_EXTREMELY_STRONG
	status_flags = GODMODE // Cannot push also

	var/cannot_be_seen = 1
	var/mob/living/creator = null


// No movement while seen code.

/mob/living/simple_animal/hostile/statue/New(loc, var/mob/living/creator)
	..()
	// Give spells
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/flicker_lights(null))
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/blindness(null))
	AddSpell(new /obj/effect/proc_holder/spell/targeted/night_vision(null))

	// Set creator
	if(creator)
		src.creator = creator

/mob/living/simple_animal/hostile/statue/Move(turf/NewLoc)
	if(can_be_seen(NewLoc))
		if(client)
			to_chat(src, "<span class='warning'>You cannot move, there are eyes on you!</span>")
		return 0
	return ..()

/mob/living/simple_animal/hostile/statue/handle_automated_action()
	if(!..())
		return
	if(target) // If we have a target and we're AI controlled
		var/mob/watching = can_be_seen()
		// If they're not our target
		if(watching && watching != target)
			// This one is closer.
			if(get_dist(watching, src) > get_dist(target, src))
				LoseTarget()
				GiveTarget(watching)

/mob/living/simple_animal/hostile/statue/AttackingTarget()
	if(can_be_seen(get_turf(loc)))
		if(client)
			to_chat(src, "<span class='warning'>You cannot attack, there are eyes on you!</span>")
			return
	else
		..()

/mob/living/simple_animal/hostile/statue/DestroySurroundings()
	if(!can_be_seen(get_turf(loc)))
		..()

/mob/living/simple_animal/hostile/statue/face_atom()
	if(!can_be_seen(get_turf(loc)))
		..()

/mob/living/simple_animal/hostile/statue/proc/can_be_seen(turf/destination)
	if(!cannot_be_seen)
		return null
	// Check for darkness
	var/turf/T = get_turf(loc)
	if(T && destination && T.lighting_overlay)
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
			if(M.client && CanAttack(M) && !M.has_unlimited_silicon_privilege)
				if(M.has_vision())
					return M
		for(var/obj/mecha/M in view(world.view + 1, check)) //assuming if you can see them they can see you
			if(M.occupant && M.occupant.client)
				if(M.occupant.has_vision())
					return M.occupant
	return null

// Cannot talk

/mob/living/simple_animal/hostile/statue/say()
	return 0

// Turn to dust when gibbed

/mob/living/simple_animal/hostile/statue/gib()
	dust()


// Stop attacking clientless mobs

/mob/living/simple_animal/hostile/statue/CanAttack(atom/the_target)
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(!L.client && !L.ckey)
			return 0
	return ..()

// Don't attack your creator if there is one

/mob/living/simple_animal/hostile/statue/ListTargets()
	. = ..()
	return . - creator

// Statue powers

// Flicker lights
/obj/effect/proc_holder/spell/aoe_turf/flicker_lights
	name = "Flicker Lights"
	desc = "You will trigger a large amount of lights around you to flicker."

	charge_max = 300
	clothes_req = 0
	range = 14

/obj/effect/proc_holder/spell/aoe_turf/flicker_lights/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		for(var/obj/machinery/light/L in T)
			L.flicker()
	return

//Blind AOE
/obj/effect/proc_holder/spell/aoe_turf/blindness
	name = "Blindness"
	desc = "Your prey will be momentarily blind for you to advance on them."

	message = "<span class='notice'>You glare your eyes.</span>"
	charge_max = 600
	clothes_req = 0
	range = 10

/obj/effect/proc_holder/spell/aoe_turf/blindness/cast(list/targets, mob/user = usr)
	for(var/mob/living/L in GLOB.living_mob_list)
		if(L == user)
			continue
		var/turf/T = get_turf(L.loc)
		if(T && T in targets)
			L.EyeBlind(4)
	return

/mob/living/simple_animal/hostile/statue/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		grant_death_vision()
		return

//Toggle Night Vision
/obj/effect/proc_holder/spell/targeted/night_vision
	name = "Toggle Nightvision"
	desc = "Toggle your nightvision mode."

	charge_max = 10
	clothes_req = 0

	message = "<span class='notice'>You toggle your night vision!</span>"
	range = -1
	include_user = 1
	var/non_night_vision = SEE_INVISIBLE_LIVING
	var/night_vision = SEE_INVISIBLE_OBSERVER_NOLIGHTING

/obj/effect/proc_holder/spell/targeted/night_vision/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(target.see_invisible == non_night_vision)
			target.see_invisible = night_vision
		else
			target.see_invisible = non_night_vision

/mob/living/simple_animal/hostile/statue/sentience_act()
	faction -= "neutral"

/mob/living/simple_animal/hostile/statue/restrained()
	. = ..()
	if(can_be_seen(loc))
		return 1
