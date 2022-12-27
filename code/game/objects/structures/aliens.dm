/* Alien structures!
 * Contains:
 *		structure/alien
 *		Resin
 *		Weeds
 *		Eggs
 */

#define WEED_NORTH_EDGING "north"
#define WEED_SOUTH_EDGING "south"
#define WEED_EAST_EDGING "east"
#define WEED_WEST_EDGING "west"

/obj/structure/alien
	icon = 'icons/mob/alien.dmi'
	max_integrity = 100

/obj/structure/alien/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BRUTE)
				damage_amount *= 0.25
			if(BURN)
				damage_amount *= 2
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

/*
 * Resin
 */
/obj/structure/alien/resin
	name = "resin"
	desc = "Looks like some kind of thick resin."
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi'
	icon_state = "resin_wall-0"
	base_icon_state = "resin_wall"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_RESIN)
	max_integrity = 200
	var/resintype = null

/obj/structure/alien/resin/Initialize()
	air_update_turf(1)
	for(var/obj/structure/alien/weeds/node/W in get_turf(src))
		qdel(W)
	if(locate(/obj/structure/alien/weeds/E) in get_turf(src))
		return ..()
	new /obj/structure/alien/weeds(loc)
	..()

/obj/structure/alien/resin/Destroy()
	var/turf/T = get_turf(src)
	playsound(loc, 'sound/effects/alien_resin_break2.ogg', 100, TRUE)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/alien/resin/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/alien/resin/CanAtmosPass()
	return !density

/obj/structure/alien/resin/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(user.a_intent != INTENT_HARM)
		return
	else
		to_chat(user, "<span class='noticealien'>We begin tearing down this resin structure.</span>")
		if(do_after(user, 40, target = src) && !QDELETED(src))
			qdel(src)


/obj/structure/alien/resin/wall
	name = "resin wall"
	desc = "Thick resin solidified into a wall."
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi'
	icon_state = "resin_wall-0"
	base_icon_state = "resin_wall"
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WALLS)

/obj/structure/alien/resin/wall/BlockSuperconductivity()
	return TRUE

/*
 *Resin-Door
*/
/obj/structure/alien/resin/door
	name = "resin door"
	density = TRUE
	anchored = TRUE
	opacity = TRUE

	icon = 'icons/obj/smooth_structures/alien/resin_door.dmi'
	icon_state = "resin"
	base_icon_state = "resin"
	max_integrity = 150
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	damage_deflection = 0
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	rad_insulation = RAD_MEDIUM_INSULATION
	var/initial_state
	var/state_open = FALSE
	var/is_operating = FALSE
	var/close_delay = 15
	smoothing_flags = null
	var/openSound = 'sound/machines/alien_airlock.ogg'
	var/closeSound = 'sound/machines/alien_airlock.ogg'

	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WALLS)

/obj/structure/alien/resin/door/Initialize()
	. = ..()
	initial_state = icon_state
	QUEUE_SMOOTH_NEIGHBORS(src)
	air_update_turf(1)
	for(var/obj/structure/alien/weeds/node/W in get_turf(src))
		qdel(W)
	if(locate(/obj/structure/alien/weeds/E) in get_turf(src))
		return
	new /obj/structure/alien/weeds(loc)

/obj/structure/alien/resin/door/Destroy()
	density = FALSE
	QUEUE_SMOOTH_NEIGHBORS(src)
	playsound(loc, pick('sound/effects/alien_resin_break2.ogg','sound/effects/alien_resin_break1.ogg'), 100, FALSE)
	air_update_turf(1)
	return ..()

/obj/structure/alien/resin/door/Move()
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/alien/resin/door/Crossed(mob/living/L, oldloc)
	..()
	if(!state_open)
		return try_to_operate(L)

/obj/structure/alien/resin/door/attack_ai(mob/user)
	return

/obj/structure/alien/resin/door/attack_hand(mob/user)
	return try_to_operate(user)

/obj/structure/alien/resin/door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		operate()

/obj/structure/alien/resin/door/CanAtmosPass(turf/T)
	return !density

/obj/structure/alien/resin/door/proc/try_to_operate(mob/user)
	if(is_operating)
		return
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.get_int_organ(/obj/item/organ/internal/xenos/hivenode))
			if(world.time - C.last_bumped <= 60)
				return
			if(!C.handcuffed)
				operate()
/*
  * This 2nd try_to_operate() is needed so that CALLBACK can close the door without having to either call operate() and get bugged when clicked much or 
  * call try_to_operate(atom/user) and not be able to use it due to not having a mob using it
*/
/obj/structure/alien/resin/door/proc/mobless_try_to_operate() 
	if(is_operating)
		if(state_open)
			addtimer(CALLBACK(src, PROC_REF(mobless_try_to_operate)), close_delay)
		return
	operate()

/obj/structure/alien/resin/door/proc/operate()
	is_operating = TRUE
	if(!state_open)
		playsound(loc, openSound, 100, 1)
		flick("[initial_state]opening",src)
	else
		var/turf/T = get_turf(src)
		for(var/mob/living/L in T)
			is_operating = FALSE
			if(state_open)
				addtimer(CALLBACK(src, PROC_REF(mobless_try_to_operate)), close_delay)
			return
		playsound(loc, closeSound, 100, 1)
		flick("[initial_state]closing",src)
	density = !density
	opacity = !opacity
	state_open = !state_open
	sleep(10)
	air_update_turf(1)
	update_icon(UPDATE_ICON_STATE)
	is_operating = FALSE

	if(state_open)
		addtimer(CALLBACK(src, PROC_REF(mobless_try_to_operate)), close_delay)

/obj/structure/alien/resin/door/update_icon_state()
	if(state_open)
		icon_state = "[initial_state]open"
	else
		icon_state = initial_state

/obj/structure/alien/resin/door/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(user.a_intent != INTENT_HARM)
		try_to_operate(user)
	else
		to_chat(user, "<span class='noticealien'>We begin tearing down this resin structure.</span>")
		if(do_after(user, 40, target = src) && !QDELETED(src))
			qdel(src)

/obj/structure/alien/resin/door/CanPass(atom/movable/mover, turf/target)
	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		if(C.get_int_organ(/obj/item/organ/internal/xenos/hivenode))
			return TRUE
	if(iscarbon(mover.pulledby))
		var/mob/living/carbon/L = mover.pulledby
		if(L.get_int_organ(/obj/item/organ/internal/xenos/hivenode))
			return TRUE
	return !density

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
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	icon = 'icons/obj/smooth_structures/alien/weeds.dmi'
	icon_state = "weeds"
	base_icon_state = "weeds"
	max_integrity = 15
	layer = 2.455
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WEEDS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WEEDS, SMOOTH_GROUP_WALLS)
	var/obj/structure/alien/weeds/node/linked_node = null
	var/static/list/weedImageCache
	var/check_counter

/obj/structure/alien/weeds/New(pos, node)
	..()
	linked_node = node
	if(isspaceturf(loc))
		qdel(src)
		return
	for(var/turf/simulated/wall/W in orange(1, src))
		var/wall_dir = get_dir(W, src)
		switch(wall_dir)
			if(1, 8, 4, 2)
				new /obj/structure/alien/wallweed(pos, wall_dir)
			if(9, 6, 5, 10)
				continue
	START_PROCESSING(SSobj, src)

/obj/structure/alien/weeds/Destroy()
	STOP_PROCESSING(SSobj, src)
	QUEUE_SMOOTH_NEIGHBORS(src)
	playsound(loc, pick('sound/effects/alien_resin_break2.ogg','sound/effects/alien_resin_break1.ogg'), 50, FALSE)
	linked_node = null
	return ..()

/obj/structure/alien/weeds/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(user.a_intent != INTENT_HARM)
		return
	else
		return ..()

/obj/structure/alien/weeds/process()
    check_counter++
    if(check_counter >= 5)
        spread()
        check_counter = 0

/obj/structure/alien/weeds/proc/spread()
	var/turf/U = get_turf(src)

	if(isspaceturf(U))
		qdel(src)
		return

	if(!linked_node || get_dist(linked_node, src) > linked_node.node_range)
		return

	for(var/turf/T in U.GetAtmosAdjacentTurfs())
		if(locate(/obj/structure/alien/weeds) in T || isspaceturf(T))
			continue
		new /obj/structure/alien/weeds(T, linked_node)

/obj/structure/alien/weeds/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/*
 * Wall Weeds
 */

/obj/structure/alien/wallweed
	name = "Wall Weed"
	desc = "A thick resin surface covers the wall."
	icon = 'icons/obj/smooth_structures/alien/weeds.dmi'
	icon_state = "wallweed"
	base_icon_state = "wallweed"
	anchored = TRUE
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE

	max_integrity = 15

/obj/structure/alien/wallweed/New(pos, wall_dir)
	switch(wall_dir)
		if(1, 5, 9)
			pixel_y = -32
		if(2, 6, 10)
			pixel_y = 32
	switch(wall_dir)
		if(4, 5 ,6)
			pixel_x = -32
		if(8, 9, 10)
			pixel_x = 32
		if(8, 4)
			layer = 4.1
		if(1, 2)
			layer = 4.2
	icon_state = "wallweed-[wall_dir]"
	..()

/obj/structure/alien/wallweed/Destroy()
	playsound(loc, pick('sound/effects/alien_resin_break2.ogg','sound/effects/alien_resin_break1.ogg'), 50, FALSE)
	return ..()

/obj/structure/alien/wallweed/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(user.a_intent != INTENT_HARM)
		return
	return ..()

/*
 * Weed nodes
 */

/obj/structure/alien/weeds/node
	name = "resin node"
	desc = "A large bulbous node pumping resin into the surface bellow it."
	icon = 'icons/obj/smooth_structures/alien/weeds.dmi'
	icon_state = "weeds"
	base_icon_state = "weeds"
	light_range = 1
	var/node_range = NODERANGE


/obj/structure/alien/weeds/node/New()
	add_overlay("weednode")
	..(loc, src)

#undef NODERANGE


/*
 * Egg
 */

///Used in the /status var
#define BURST 0
#define BURSTING 1
#define GROWING 2
#define GROWN 3
///time it takes to grow a hugger
#define MIN_GROWTH_TIME 2 MINUTES
#define MAX_GROWTH_TIME 3 MINUTES

/obj/structure/alien/egg
	name = "egg"
	desc = "A large mottled egg."
	icon_state = "egg_growing"
	density = FALSE
	anchored = TRUE
	max_integrity = 100
	integrity_failure = 5
	layer = MOB_LAYER
	flags_2 = CRITICAL_ATOM_2
	/*can be GROWING, GROWN or BURST; all mutually exclusive. GROWING has the egg in the grown state, and it will take 180-300 seconds for it to advance to the hatched state
	*In the GROWN state, an alien egg can be destroyed or attacked by a xenomorph to force it to be burst, going near an egg in this state will also cause it to burst if you can be infected by a face hugger
	*In the BURST/BURSTING state, the alien egg can be removed by being attacked by a alien or any other weapon
	**/
	var/status = GROWING

/obj/structure/alien/egg/grown
	status = GROWN
	icon_state = "egg"

/obj/structure/alien/egg/burst
	status = BURST
	icon_state = "egg_hatched"

/obj/structure/alien/egg/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/mask/facehugger(src)
	if(status == BURST)
		obj_integrity = integrity_failure
	else if(status != GROWN)
		addtimer(CALLBACK(src, PROC_REF(grow)), rand(MIN_GROWTH_TIME, MAX_GROWTH_TIME))

/obj/structure/alien/egg/attack_alien(mob/living/carbon/alien/user)
	return attack_hand(user)

/obj/structure/alien/egg/attack_hand(mob/living/user)
	if(user.get_int_organ(/obj/item/organ/internal/xenos/hivenode))
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
				burst(FALSE)
				return
	else
		to_chat(user, "<span class='notice'>It feels slimy.</span>")
		user.changeNext_move(CLICK_CD_MELEE)


/obj/structure/alien/egg/proc/getFacehugger()
	return locate(/obj/item/clothing/mask/facehugger) in contents

/obj/structure/alien/egg/proc/grow()
	icon_state = "egg"
	status = GROWN
	AddComponent(/datum/component/proximity_monitor)

///Need to carry the kill from Burst() to Hatch(), this section handles the alien opening the egg
/obj/structure/alien/egg/proc/burst(kill)
	if(status == GROWN || status == GROWING)
		icon_state = "egg_hatched"
		flick("egg_opening", src)
		status = BURSTING
		qdel(GetComponent(/datum/component/proximity_monitor))
		addtimer(CALLBACK(src, PROC_REF(hatch)), 1.5 SECONDS)

///We now check HOW the hugger is hatching, kill carried from Burst() and obj_break()
/obj/structure/alien/egg/proc/hatch(kill)
	status = BURST
	var/obj/item/clothing/mask/facehugger/child = getFacehugger()
	child.forceMove(get_turf(src))
	if(kill)
		child.Die()
	for(var/mob/M in range(1, src))
		if(CanHug(M))
			child.Attach(M)
			break

/obj/structure/alien/egg/obj_break(damage_flag)
	if(!(flags & NODECONSTRUCT))
		if(status != BURST)
			burst(kill = TRUE)

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

		burst(FALSE)

#undef BURST
#undef BURSTING
#undef GROWING
#undef GROWN
#undef MIN_GROWTH_TIME
#undef MAX_GROWTH_TIME

#undef WEED_NORTH_EDGING
#undef WEED_SOUTH_EDGING
#undef WEED_EAST_EDGING
#undef WEED_WEST_EDGING
