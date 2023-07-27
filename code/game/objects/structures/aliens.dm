/* Alien shit!
 * Contains:
 *		structure/alien
 *		Resin
 *		Weeds
 *		Egg
 */

#define WEED_NORTH_EDGING "north"
#define WEED_SOUTH_EDGING "south"
#define WEED_EAST_EDGING "east"
#define WEED_WEST_EDGING "west"

#define ALIEN_RESIN_BURN_MOD 2
#define ALIEN_RESIN_BRUTE_MOD 0.25

/obj/structure/alien
	icon = 'icons/mob/alien.dmi'
	max_integrity = 100

/obj/structure/alien/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee")
		switch(damage_type)
			if(BRUTE)
				damage_amount *= ALIEN_RESIN_BRUTE_MOD
			if(BURN)
				damage_amount *= ALIEN_RESIN_BURN_MOD
	. = ..()

/obj/structure/alien/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/alien/has_prints()
	return FALSE

/*
 * Resin
 */
/obj/structure/alien/resin
	name = "resin"
	desc = "Looks like some kind of thick resin."
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi'
	icon_state = "resin"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	canSmoothWith = list(/obj/structure/alien/resin)
	max_integrity = 200
	smooth = SMOOTH_TRUE
	var/resintype = null

/obj/structure/alien/resin/Initialize()
	air_update_turf(1)
	..()

/obj/structure/alien/resin/Destroy()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/creatures/alien/xeno_resin_break.ogg', 80, TRUE)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/alien/resin/Move()
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/alien/resin/CanAtmosPass()
	return !density

/obj/structure/alien/resin/wall
	name = "resin wall"
	desc = "Thick resin solidified into a wall."
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi'
	icon_state = "wall0"	//same as resin, but consistency ho!
	resintype = "wall"
	canSmoothWith = list(/obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane)

/obj/structure/alien/resin/wall/BlockSuperconductivity()
	return 1

/obj/structure/alien/resin/wall/shadowling //For chrysalis
	name = "chrysalis wall"
	desc = "Some sort of purple substance in an egglike shape. It pulses and throbs from within and seems impenetrable."
	max_integrity = INFINITY

/obj/structure/alien/resin/membrane
	name = "resin membrane"
	desc = "Resin just thin enough to let light pass through."
	icon = 'icons/obj/smooth_structures/alien/resin_membrane.dmi'
	icon_state = "membrane0"
	opacity = 0
	max_integrity = 160
	resintype = "membrane"
	canSmoothWith = list(/obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane)

/obj/structure/alien/resin/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density

/obj/structure/alien/resin/attack_alien(mob/living/carbon/alien/humanoid/A)
	var/damage = 0
	switch(A.caste)
		if("d") //drone breaks wall in 2 hits
			damage = max_integrity/2/ALIEN_RESIN_BRUTE_MOD
		if("q") //queen breaks wall in 1 hit
			damage = max_integrity/ALIEN_RESIN_BRUTE_MOD
		else
			return ..()
	if(attack_generic(A, damage, BRUTE, "melee", 0, 100))
		playsound(loc, 'sound/effects/attackblob.ogg', 50, TRUE)


#define RESIN_DOOR_CLOSED 0
#define RESIN_DOOR_OPENED 1


/obj/structure/alien/resin/door
	name = "resin door"
	desc = "Thick resin solidified into a weird looking door."
	icon = 'icons/obj/smooth_structures/alien/resin_door.dmi'
	icon_state = "resin_door_closed"
	max_integrity = 160
	resintype = "door"
	canSmoothWith = null
	smooth = SMOOTH_FALSE
	var/state = RESIN_DOOR_CLOSED
	var/operating = FALSE
	var/autoclose = TRUE
	var/autoclose_delay = 10 SECONDS


/obj/structure/alien/resin/door/Initialize()
	. = ..()
	update_freelook_sight()


/obj/structure/alien/resin/door/Destroy()
	density = FALSE
	update_freelook_sight()
	return ..()


/obj/structure/alien/resin/door/update_icon()
	switch(state)
		if(RESIN_DOOR_CLOSED)
			icon_state = "resin_door_closed"
		if(RESIN_DOOR_OPENED)
			icon_state = "resin_door_opened"


/obj/structure/alien/resin/door/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(user.a_intent == INTENT_HARM)
		return ..()

	try_switch_state(user)


/obj/structure/alien/resin/door/attack_hand(mob/living/user)
	if(!isalien(user))
		to_chat(user, span_notice("You can't find a way to manipulate with this door."))
		return FALSE

	return ..()


/obj/structure/alien/resin/door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		switch_state()


/obj/structure/alien/resin/door/attack_tk(mob/user)
	return


/obj/structure/alien/resin/door/Bumped(atom/movable/moving_atom)
	..()

	if(operating)
		return

	if(isliving(moving_atom))
		var/mob/living/living = moving_atom
		if(world.time - living.last_bumped <= 1 SECONDS)
			return
		living.last_bumped = world.time

	try_switch_state(moving_atom)


/obj/structure/alien/resin/door/CanPass(atom/movable/mover, turf/target, height = 0)
	if(istype(mover) && mover.checkpass(PASS_OTHER_THINGS))
		return TRUE

	if(istype(mover) && mover.checkpass(PASSDOOR))
		return TRUE

	return !density


/obj/structure/alien/resin/door/proc/try_switch_state(atom/movable/user)
	if(operating)
		return

	add_fingerprint(user)

	if(!isalien(user))
		return

	var/mob/living/carbon/alien/alien = user
	if(alien.incapacitated())
		return

	switch_state()


/obj/structure/alien/resin/door/proc/switch_state()
	switch(state)
		if(RESIN_DOOR_CLOSED)
			open()
		if(RESIN_DOOR_OPENED)
			close()


/obj/structure/alien/resin/door/proc/open()

	if(operating || !density)
		return

	if(autoclose)
		autoclose_in(autoclose_delay)

	flick("resin_door_opening", src)
	playsound(loc, 'sound/creatures/alien/xeno_door_open.ogg', 100, TRUE)
	operating = TRUE

	sleep(0.1 SECONDS)
	set_opacity(FALSE)
	update_freelook_sight()

	sleep(0.4 SECONDS)
	density = FALSE
	air_update_turf(TRUE)

	sleep(0.1 SECONDS)
	operating = FALSE
	state = RESIN_DOOR_OPENED
	update_icon()


/obj/structure/alien/resin/door/proc/close()

	if(operating || density)
		return

	var/turf/source_turf = get_turf(src)
	for(var/atom/movable/moving_atom in source_turf)
		if(moving_atom.density && moving_atom != src)
			if(autoclose)
				autoclose_in(autoclose_delay * 0.5)
			return

	flick("resin_door_closing", src)
	playsound(loc, 'sound/creatures/alien/xeno_door_close.ogg', 100, TRUE)
	operating = TRUE

	sleep(0.1 SECONDS)
	density = TRUE
	air_update_turf(TRUE)

	sleep(0.4 SECONDS)
	set_opacity(TRUE)
	update_freelook_sight()

	sleep(0.1 SECONDS)
	operating = FALSE
	state = RESIN_DOOR_CLOSED
	update_icon()
	check_mobs()


/obj/structure/alien/resin/door/proc/check_mobs()
	if(locate(/mob/living) in get_turf(src))
		sleep(0.1 SECONDS)
		open()


/obj/structure/alien/resin/door/proc/autoclose()
	if(!QDELETED(src) && !density && !operating && autoclose)
		close()


/obj/structure/alien/resin/door/proc/autoclose_in(wait)
	addtimer(CALLBACK(src, PROC_REF(autoclose)), wait, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)


/obj/structure/alien/resin/door/proc/update_freelook_sight()
	if(GLOB.cameranet)
		GLOB.cameranet.updateVisibility(src, FALSE)


#undef RESIN_DOOR_CLOSED
#undef RESIN_DOOR_OPENED


/*
 * Weeds
 */

#define NODERANGE 3

/obj/structure/alien/weeds
	gender = PLURAL
	name = "resin floor"
	desc = "A thick resin surface covers the floor."
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "weeds"
	max_integrity = 15
	var/obj/structure/alien/weeds/node/linked_node = null
	var/static/list/weedImageCache


/obj/structure/alien/weeds/New(pos, node)
	..()
	linked_node = node
	if(istype(loc, /turf/space))
		qdel(src)
		return
	if(icon_state == "weeds")
		icon_state = pick("weeds", "weeds1", "weeds2")
	fullUpdateWeedOverlays()
	spawn(rand(150, 200))
		if(src)
			Life()

/obj/structure/alien/weeds/Destroy()
	var/turf/T = loc
	for(var/obj/structure/alien/weeds/W in range(1,T))
		W.updateWeedOverlays()
	linked_node = null
	return ..()

/obj/structure/alien/weeds/proc/Life()
	var/turf/U = get_turf(src)

	if(istype(U, /turf/space))
		qdel(src)
		return

	if(!linked_node || get_dist(linked_node, src) > linked_node.node_range)
		return

	for(var/turf/T in U.GetAtmosAdjacentTurfs())

		if(locate(/obj/structure/alien/weeds) in T || istype(T, /turf/space))
			continue

		new /obj/structure/alien/weeds(T, linked_node)

/obj/structure/alien/weeds/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/obj/structure/alien/weeds/proc/updateWeedOverlays()

	overlays.Cut()

	if(!weedImageCache || !weedImageCache.len)
		weedImageCache = list()
		weedImageCache.len = 4
		weedImageCache[WEED_NORTH_EDGING] = image('icons/mob/alien.dmi', "weeds_side_n", layer=2.11, pixel_y = -32)
		weedImageCache[WEED_SOUTH_EDGING] = image('icons/mob/alien.dmi', "weeds_side_s", layer=2.11, pixel_y = 32)
		weedImageCache[WEED_EAST_EDGING] = image('icons/mob/alien.dmi', "weeds_side_e", layer=2.11, pixel_x = -32)
		weedImageCache[WEED_WEST_EDGING] = image('icons/mob/alien.dmi', "weeds_side_w", layer=2.11, pixel_x = 32)

	var/turf/N = get_step(src, NORTH)
	var/turf/S = get_step(src, SOUTH)
	var/turf/E = get_step(src, EAST)
	var/turf/W = get_step(src, WEST)
	if(!locate(/obj/structure/alien) in N.contents)
		if(istype(N, /turf/simulated/floor))
			overlays += weedImageCache[WEED_SOUTH_EDGING]
	if(!locate(/obj/structure/alien) in S.contents)
		if(istype(S, /turf/simulated/floor))
			overlays += weedImageCache[WEED_NORTH_EDGING]
	if(!locate(/obj/structure/alien) in E.contents)
		if(istype(E, /turf/simulated/floor))
			overlays += weedImageCache[WEED_WEST_EDGING]
	if(!locate(/obj/structure/alien) in W.contents)
		if(istype(W, /turf/simulated/floor))
			overlays += weedImageCache[WEED_EAST_EDGING]


/obj/structure/alien/weeds/proc/fullUpdateWeedOverlays()
	for(var/obj/structure/alien/weeds/W in range(1,src))
		W.updateWeedOverlays()

//Weed nodes
/obj/structure/alien/weeds/node
	name = "glowing resin"
	desc = "Blue bioluminescence shines from beneath the surface."
	icon_state = "weednode"
	light_range = 1
	layer = MID_TURF_LAYER
	var/node_range = NODERANGE


/obj/structure/alien/weeds/node/New()
	..(loc, src)

#undef NODERANGE


/*
 * Egg
 */

//for the status var
#define BURST 0
#define BURSTING 1
#define GROWING 2
#define GROWN 3
#define MIN_GROWTH_TIME 1800	//time it takes to grow a hugger
#define MAX_GROWTH_TIME 3000

/obj/structure/alien/egg
	name = "egg"
	desc = "A large mottled egg."
	icon_state = "egg_growing"
	density = FALSE
	anchored = TRUE
	max_integrity = 100
	integrity_failure = 5
	var/status = GROWING	//can be GROWING, GROWN or BURST; all mutually exclusive
	layer = MOB_LAYER

/obj/structure/alien/egg/grown
	status = GROWN
	icon_state = "egg"

/obj/structure/alien/egg/burst
	status = BURST
	icon_state = "egg_hatched"

/obj/structure/alien/egg/New()
	new /obj/item/clothing/mask/facehugger(src)
	..()
	if(status == BURST)
		obj_integrity = integrity_failure
	else if(status != GROWN)
		spawn(rand(MIN_GROWTH_TIME, MAX_GROWTH_TIME))
		Grow()

/obj/structure/alien/egg/attack_alien(mob/living/carbon/alien/user)
	return attack_hand(user)

/obj/structure/alien/egg/attack_hand(mob/living/user)
	if(user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		switch(status)
			if(BURST)
				to_chat(user, "<span class='notice'>You clear the hatched egg.</span>")
				playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
				qdel(src)
				return
			if(GROWING)
				to_chat(user, "<span class='notice'>The child is not developed yet.</span>")
				return
			if(GROWN)
				to_chat(user, "<span class='notice'>You retrieve the child.</span>")
				Burst(0)
				return
	else
		to_chat(user, "<span class='notice'>It feels slimy.</span>")
		user.changeNext_move(CLICK_CD_MELEE)


/obj/structure/alien/egg/proc/GetFacehugger()
	return locate(/obj/item/clothing/mask/facehugger) in contents

/obj/structure/alien/egg/proc/Grow()
	icon_state = "egg"
	status = GROWN
	AddComponent(/datum/component/proximity_monitor)

/obj/structure/alien/egg/proc/Burst(kill = TRUE)	//drops and kills the hugger if any is remaining
	if(status == GROWN || status == GROWING)
		playsound(get_turf(src), 'sound/creatures/alien/xeno_egg_crack.ogg', 50)
		icon_state = "egg_hatched"
		flick("egg_opening", src)
		status = BURSTING
		qdel(GetComponent(/datum/component/proximity_monitor))
		spawn(15)
			status = BURST
			var/obj/item/clothing/mask/facehugger/child = GetFacehugger()
			if(child)
				child.loc = get_turf(src)
				if(kill && istype(child))
					child.Die()
				else
					for(var/mob/M in range(1,src))
						if(CanHug(M))
							child.Attach(M)
							break

/obj/structure/alien/egg/obj_break(damage_flag)
	if(!(flags & NODECONSTRUCT))
		if(status != BURST)
			Burst(kill = TRUE)

/obj/structure/alien/egg/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 500)
		take_damage(5, BURN, 0, 0)

/obj/structure/alien/egg/HasProximity(atom/movable/AM)
	if(status == GROWN)
		if(!CanHug(AM))
			return

		var/mob/living/carbon/C = AM
		if(C.stat == CONSCIOUS && C.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo))
			return

		Burst(0)

#undef BURST
#undef BURSTING
#undef GROWING
#undef GROWN
#undef MIN_GROWTH_TIME
#undef MAX_GROWTH_TIME

#undef ALIEN_RESIN_BURN_MOD
#undef ALIEN_RESIN_BRUTE_MOD

#undef WEED_NORTH_EDGING
#undef WEED_SOUTH_EDGING
#undef WEED_EAST_EDGING
#undef WEED_WEST_EDGING
