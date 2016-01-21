// A mob which only moves when it isn't being watched by living beings.

/mob/living/simple_animal/hostile/statue
	name = "statue" // matches the name of the statue with the flesh-to-stone spell
	desc = "An incredibly lifelike marble carving. Its eyes seems to follow you.." // same as an ordinary statue with the added "eye following you" description
	icon = 'icons/obj/statue.dmi'
	icon_state = "angelseen"
	icon_living = "angelseen"
	icon_dead = "angelseen"
	gender = NEUTER
	a_intent = I_HARM

	response_help = "touches"
	response_disarm = "pushes"

	speed = -1
	maxHealth = 1250
	health = 1250

	harm_intent_damage = 35
	melee_damage_lower = 34
	melee_damage_upper = 42
	attacktext = "claws"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = list("statue")
	move_to_delay = 0 // Very fast

	animate_movement = NO_STEPS // Do not animate movement, you jump around as you're a scary statue.

	see_in_dark = 13
	vision_range = 12
	aggro_vision_range = 12
	idle_vision_range = 12

	search_objects = 1 // So that it can see through walls

	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS
	anchored = 1
//	status_flags = GODMODE // Cannot push also
	var/mob/living/creator = null


// No movement while seen code.

/mob/living/simple_animal/hostile/statue/New(loc, var/mob/living/creator)
	..()
	// Give spells
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/flicker_lights(src))
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/blindness(src))
	AddSpell(new /obj/effect/proc_holder/spell/targeted/night_vision(src))

	// Give nightvision
	see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING

	// Set creator
	if(creator)
		src.creator = creator

/mob/living/simple_animal/hostile/statue/Move(var/turf/NewLoc)
	if(can_be_seen(NewLoc))
		icon_state = "angelseen"
		if(client)
			src << "<span class='warning'>You cannot move, there are eyes on you!</span>"
		return 0
	icon_state = "angel"
	return ..()

/mob/living/simple_animal/hostile/statue/Life()
	if(..())
		if(!ckey)
			spawn() //for saftey
				checkTargets()
		. = 1

/mob/living/simple_animal/hostile/statue/proc/checkTargets()
	if(target)
		var/mob/watching = can_be_seen()
		if(watching && watching != target)
			if(get_dist(watching, src) > get_dist(target, src))
				LoseTarget()
				GiveTarget(watching)

/mob/living/simple_animal/hostile/statue/AttackingTarget()
	if(!can_be_seen())
		icon_state = "angelattack"
		..()

/mob/living/simple_animal/hostile/statue/DestroySurroundings()
	if(!can_be_seen())
		..()

/mob/living/simple_animal/hostile/statue/face_atom()
	if(!can_be_seen())
		..()

/mob/living/simple_animal/hostile/statue/UnarmedAttack()
	if(can_be_seen())
		icon_state = "angelseen"
		if(client)
			src << "<span class='warning'>You cannot attack, there are eyes on you!</span>"
		return
	icon_state = "angelattack"
	..()

/mob/living/simple_animal/hostile/statue/proc/can_be_seen(var/turf/destination)
	// Check for darkness
	var/turf/T = get_turf(loc)

	var/light_amount
	var/DLlight_amount

	if(T.dynamic_lighting)
		light_amount = T.get_lumcount()
	else
		light_amount = 5

	if(destination && destination.dynamic_lighting)
		DLlight_amount = destination.get_lumcount()
	else
		DLlight_amount = 5

	if(T && destination)
		//Don't check it twice if our destination is the tile we are on or we can't even get to our destination
		if(T == destination)
			destination = null
		else if(light_amount < 0.1 && DLlight_amount < 0.1) // No one can see us in the darkness, right?
			return null

	//We aren't in darkness, loop for viewers.
	var/list/check_list = list(src)
	if(destination)
		check_list += destination

	//This loop will, at most, loop twice.
	for(var/atom/check in check_list)
		for(var/mob/living/M in viewers(world.view + 1, check) - src)
			if(M.client && CanAttack(M))
				if(M.blinded || (M.sdisabilities & BLIND))
					return null

				//calculates if any mobs are actually facing the statue
				var/xdif = M.x - src.x
				var/ydif = M.y - src.y

				if(abs(xdif) < abs(ydif)) //mob is either above or below src
					if(ydif < 0 && M.dir == NORTH) //mob is below src and looking up
						return M
					if(ydif > 0 && M.dir == SOUTH) //mob is above src and looking down
						return M

				else if(abs(xdif) > abs(ydif)) //mob is either left or right of src
					if(xdif < 0 && M.dir == EAST) //mob is to the left of src and looking right
						return M
					if(xdif > 0 && M.dir == WEST) //mob is to the right of src and looking left
						return M

				else if(xdif == 0 && ydif == 0) //mob is on the same tile as src
					return M



//Cannot talk
/mob/living/simple_animal/hostile/statue/say()
	return 0

/mob/living/simple_animal/hostile/statue/death(gibbed)
	if(!gibbed) //The looping ends here.
		dust()
		return
	return ..()

//Stop attacking clientless mobs

/mob/living/simple_animal/hostile/statue/CanAttack(var/atom/the_target)
	if(mind && mind.key && !ckey)
		return 0
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(!L.client && !L.ckey)
			return 0
	return ..()

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

/obj/effect/proc_holder/spell/aoe_turf/flicker_lights/cast(list/targets)
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
	range = 8

/obj/effect/proc_holder/spell/aoe_turf/blindness/cast(list/targets)
	for(var/mob/living/L in living_mob_list)
		var/turf/T = get_turf(L.loc)
		if(T && T in targets)
			L.eye_blind = max(L.eye_blind, 4)
			if(issilicon(L))
				L.Weaken(4)
	return

//Toggle Night Vision
/obj/effect/proc_holder/spell/targeted/night_vision
	name = "Toggle Nightvision \[ON\]"
	desc = "Toggle your nightvision mode."

	charge_max = 10
	clothes_req = 0

	message = "<span class='notice'>You toggle your night vision!</span>"
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/night_vision/cast(list/targets)

	for(var/mob/living/target in targets)
		if(target.see_invisible == SEE_INVISIBLE_LIVING)
			target.see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
			name = "Toggle Nightvision \[ON\]"
		else
			target.see_invisible = SEE_INVISIBLE_LIVING
			name = "Toggle Nightvision \[OFF\]"
	return