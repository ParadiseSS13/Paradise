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
	cares_about_temperature = TRUE

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
	var/is_alien = TRUE

/obj/structure/alien/resin/Initialize(mapload)
	recalculate_atmos_connectivity()
	if(!is_alien)
		return ..()
	for(var/obj/structure/alien/weeds/node/W in get_turf(src))
		qdel(W)
	if(locate(/obj/structure/alien/weeds) in get_turf(src))
		return ..()
	new /obj/structure/alien/weeds(loc, src)
	return ..()

/obj/structure/alien/resin/Destroy()
	var/turf/T = get_turf(src)
	playsound(loc, 'sound/effects/alien_resin_break2.ogg', 100, TRUE)
	. = ..()
	T.recalculate_atmos_connectivity()

/obj/structure/alien/resin/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/alien/resin/CanAtmosPass(direction)
	return !density

/obj/structure/alien/resin/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(user.a_intent != INTENT_HARM)
		return
	to_chat(user, "<span class='noticealien'>We begin tearing down this resin structure.</span>")
	if(!do_after(user, 40, target = src) || QDELETED(src))
		return
	qdel(src)

/obj/structure/alien/resin/wall
	name = "resin wall"
	desc = "Thick resin solidified into a wall."
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WALLS)

/obj/structure/alien/resin/wall/get_superconductivity(direction)
	return FALSE

/*
 *Resin-Door - Borrows its code from Mineral-Door, not a subtype due to needing many overrides if so
*/
/obj/structure/alien/resin/door
	name = "resin door"
	icon = 'icons/obj/smooth_structures/alien/resin_door.dmi'
	icon_state = "resin"
	base_icon_state = "resin"
	max_integrity = 60
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	rad_insulation_beta = RAD_MEDIUM_INSULATION
	rad_insulation_gamma = RAD_LIGHT_INSULATION
	var/initial_state
	var/state_open = FALSE
	var/is_operating = FALSE
	var/close_delay = 3 SECONDS
	smoothing_flags = null
	var/open_sound = 'sound/machines/alien_airlock.ogg'
	var/close_sound = 'sound/machines/alien_airlock.ogg'

	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WALLS)

/obj/structure/alien/resin/door/Initialize(mapload)
	. = ..()
	initial_state = icon_state
	QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/alien/resin/door/Destroy()
	density = FALSE
	QUEUE_SMOOTH_NEIGHBORS(src)
	recalculate_atmos_connectivity()
	return ..()

/obj/structure/alien/resin/door/Move()
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/alien/resin/door/attack_ai(mob/user)
	return

/obj/structure/alien/resin/door/attack_hand(mob/user)
	return try_to_operate(user)

/obj/structure/alien/resin/door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		operate()

/obj/structure/alien/resin/door/CanAtmosPass(direction)
	return !density

/obj/structure/alien/resin/door/proc/try_to_operate(mob/user, bumped_open = FALSE)
	if(is_operating)
		return
	if(!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	if(C.get_int_organ(/obj/item/organ/internal/alien/hivenode))
		if(!C.handcuffed)
			operate(bumped_open)
		return
	to_chat(user, "<span class='noticealien'>Your lack of connection to the hive prevents the resin door from opening</span>")
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

/obj/structure/alien/resin/door/proc/operate(bumped_open = FALSE)
	is_operating = TRUE
	if(!state_open)
		playsound(loc, open_sound, 50, TRUE)
		flick("[initial_state]opening", src)
	else
		for(var/mob/living/L in get_turf(src))
			is_operating = FALSE
			if(state_open)
				addtimer(CALLBACK(src, PROC_REF(mobless_try_to_operate)), close_delay)
			return
		playsound(loc, close_sound, 50, 1)
		flick("[initial_state]closing", src)
	density = !density
	set_opacity(!opacity)
	state_open = !state_open
	addtimer(CALLBACK(src, PROC_REF(operate_update), bumped_open), 1 SECONDS)

/obj/structure/alien/resin/door/proc/operate_update(bumped_open)
	recalculate_atmos_connectivity()
	update_icon(UPDATE_ICON_STATE)
	is_operating = FALSE

	if(state_open && bumped_open)
		addtimer(CALLBACK(src, PROC_REF(mobless_try_to_operate)), close_delay)

/obj/structure/alien/resin/door/update_icon_state()
	icon_state = state_open ? "[initial_state]open" : initial_state

/obj/structure/alien/resin/door/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(user.a_intent != INTENT_HARM)
		try_to_operate(user)
		return
	to_chat(user, "<span class='noticealien'>We begin tearing down this resin structure.</span>")
	if(!do_after(user, 40, target = src) || QDELETED(src))
		return
	qdel(src)

/obj/structure/alien/resin/door/Bumped(atom/user)
	..()
	if(!state_open)
		return try_to_operate(user, TRUE)

/*
 * Weeds
 */

#define NODERANGE 3

/obj/structure/alien/weeds
	gender = PLURAL
	name = "resin floor"
	desc = "A thick resin surface covers the floor."
	anchored = TRUE
	plane = FLOOR_PLANE
	icon = 'icons/obj/smooth_structures/alien/weeds.dmi'
	icon_state = "weeds"
	base_icon_state = "weeds"
	max_integrity = 15
	layer = ABOVE_ICYOVERLAY_LAYER
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WEEDS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WEEDS, SMOOTH_GROUP_WALLS)
	creates_cover = TRUE
	var/obj/structure/alien/weeds/node/linked_node = null
	var/obj/structure/alien/wallweed/wall_weed // This var is used to handle wall-weed interactions for when they need to be deleted
	var/static/list/weedImageCache
	var/check_counter // This var is how many process() procs it takes for a weed to spread
	/// This var is used for making automatic weed removals silent instead of making them produce the breaking sound
	var/silent_removal = FALSE

/obj/structure/alien/weeds/Initialize(mapload, node)
	. = ..()
	linked_node = node
	if(isspaceturf(loc))
		qdel(src)
		return
	check_surroundings()
	START_PROCESSING(SSobj, src)
	RegisterSignal(linked_node, COMSIG_PARENT_QDELETING, PROC_REF(clear_linked_node))

/obj/structure/alien/weeds/Destroy()
	STOP_PROCESSING(SSobj, src)
	QUEUE_SMOOTH_NEIGHBORS(src)
	if(!silent_removal)
		playsound(loc, pick('sound/effects/alien_resin_break2.ogg','sound/effects/alien_resin_break1.ogg'), 50, FALSE)
	linked_node = null
	clear_wall_weed()
	return ..()

/obj/structure/alien/weeds/proc/clear_linked_node()
	SIGNAL_HANDLER
	UnregisterSignal(linked_node, COMSIG_PARENT_QDELETING)
	linked_node = null

/obj/structure/alien/weeds/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(user.a_intent != INTENT_HARM)
		return
	return ..()

/obj/structure/alien/weeds/process()
	check_counter++
	if(check_counter >= 5)
		spread()
		check_counter = 0

/obj/structure/alien/weeds/proc/clear_wall_weed()
	if(wall_weed && !QDELETED(wall_weed))
		wall_weed.weed = null
		wall_weed.silent_removal = TRUE
	QDEL_NULL(wall_weed)

/obj/structure/alien/weeds/proc/check_surroundings()
	var/turf/T = get_turf(src)
	var/list/nearby_dense_turfs = T.AdjacentTurfs(cardinal_only = FALSE, dense_only = TRUE)
	if(!length(nearby_dense_turfs)) // There is no dense turfs around it
		clear_wall_weed()
		return

	var/list/wall_dirs = list()
	for(var/turf/W in nearby_dense_turfs)
		if(iswallturf(W))
			wall_dirs.Add(get_dir(W, T))
	if(!length(wall_dirs)) // There is no walls around it
		clear_wall_weed()
		return

	var/list/nearby_open_turfs = T.AdjacentTurfs(open_only = TRUE, cardinal_only = TRUE)

	for(var/turf/W in nearby_open_turfs) // This handles removal of corner-weeds when they are to be replaced with a full side-weed instead
		if(locate(/obj/structure/alien/weeds, W))
			var/dirs = get_dir(W, T)
			switch(dirs)
				if(NORTH)
					wall_dirs.Remove(NORTHEAST, NORTHWEST)
				if(SOUTH)
					wall_dirs.Remove(SOUTHEAST, SOUTHWEST)
				if(EAST)
					wall_dirs.Remove(NORTHEAST, SOUTHEAST)
				if(WEST)
					wall_dirs.Remove(NORTHWEST, SOUTHWEST)

	if(!length(wall_dirs)) // No weeds will be applied, better off deleting it
		clear_wall_weed()
		return

	if(!wall_weed || QDELETED(wall_weed))
		wall_weed = new /obj/structure/alien/wallweed(T, src)

	wall_weed.compare_overlays(wall_dirs)

/obj/structure/alien/weeds/proc/spread()
	var/turf/U = get_turf(src)

	if(isspaceturf(U))
		qdel(src)
		return

	if(!linked_node)
		if(prob(20))
			silent_removal = TRUE
			qdel(src)
		return

	if((istype(linked_node, /obj/structure/alien/resin/door)) || (istype(linked_node, /obj/structure/alien/resin/wall)))
		return

	if(get_dist(linked_node, src) > linked_node.node_range) /*!linked_node || */
		return

	for(var/turf/T in U.GetAtmosAdjacentTurfs())
		if((locate(/obj/structure/alien/weeds) in T) || isspaceturf(T) || islava(T) || ischasm(T))
			continue
		new /obj/structure/alien/weeds(T, linked_node)
		check_surroundings()

/obj/structure/alien/weeds/temperature_expose(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/*
 * Wall Weeds
 */

/obj/structure/alien/wallweed
	name = "resin overgrowth"
	desc = "A thick resin surface covers the wall."
	icon = 'icons/obj/smooth_structures/alien/weeds.dmi'
	icon_state = null
	anchored = TRUE
	layer = ABOVE_WINDOW_LAYER

	max_integrity = 15
	var/obj/structure/alien/weeds/weed
	var/list/overlay_list = list()
	/// This var is used for making automatic weed removals silent instead of making them produce the breaking sound
	var/silent_removal = FALSE

/obj/structure/alien/wallweed/Initialize(mapload, weed_owner)
	. = ..()
	weed = weed_owner

/obj/structure/alien/wallweed/Destroy()
	if(!silent_removal)
		playsound(loc, pick('sound/effects/alien_resin_break2.ogg','sound/effects/alien_resin_break1.ogg'), 50, FALSE)
	if(weed)
		weed.wall_weed = null
	return ..()

/obj/structure/alien/wallweed/proc/compare_overlays(list/wall_dirs)
	if(overlay_list != wall_dirs)
		overlay_list = wall_dirs
		update_icon(UPDATE_OVERLAYS)

/obj/structure/alien/wallweed/update_overlays()
	. = ..()
	if(!length(overlay_list))
		return
	for(var/dirs in overlay_list)
		var/image/I = image(icon, icon_state = "wallweed-[dirs]")
		switch(dirs)
			if(NORTH, NORTHEAST, NORTHWEST)
				I.pixel_y = -32
			if(SOUTH, SOUTHEAST, SOUTHWEST)
				I.pixel_y = 32
		switch(dirs)
			if(EAST, NORTHEAST, SOUTHEAST)
				I.pixel_x = -32
			if(WEST, NORTHWEST, SOUTHWEST)
				I.pixel_x = 32
		I.layer = BELOW_MOB_LAYER
		. += I

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
	light_range = 1
	var/node_range = NODERANGE


/obj/structure/alien/weeds/node/Initialize(mapload)
	add_overlay("weednode")
	return ..(loc, src)

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
	anchored = TRUE
	integrity_failure = 5
	layer = MOB_LAYER
	flags_2 = CRITICAL_ATOM_2
	/*can be GROWING, GROWN or BURST; all mutually exclusive. GROWING has the egg in the grown state, and it will take 180-300 seconds for it to advance to the hatched state
	*In the GROWN state, an alien egg can be destroyed or attacked by a xenomorph to force it to be burst, going near an egg in this state will also cause it to burst if you can be infected by a face hugger
	*In the BURST/BURSTING state, the alien egg can be removed by being attacked by a alien or any other weapon
	**/
	var/status = GROWING
	var/datum/proximity_monitor/proximity_monitor

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
	if(status == GROWN)
		proximity_monitor = new(src)

/obj/structure/alien/egg/attack_alien(mob/living/carbon/alien/user)
	return attack_hand(user)

/obj/structure/alien/egg/attack_hand(mob/living/user)
	if(user.get_int_organ(/obj/item/organ/internal/alien/plasmavessel))
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
	proximity_monitor = new(src)

///Need to carry the kill from Burst() to Hatch(), this section handles the alien opening the egg
/obj/structure/alien/egg/proc/burst(kill)
	if(status == GROWN || status == GROWING)
		icon_state = "egg_hatched"
		flick("egg_opening", src)
		status = BURSTING
		QDEL_NULL(proximity_monitor)
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

/obj/structure/alien/egg/temperature_expose(exposed_temperature, exposed_volume)
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
