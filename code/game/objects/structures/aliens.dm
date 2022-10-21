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

/obj/structure/alien
	icon = 'icons/mob/alien.dmi'
	max_integrity = 100

/obj/structure/alien/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee")
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
	..()

/obj/structure/alien/resin/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/alien/resin/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/alien/resin/CanAtmosPass()
	return !density

/obj/structure/alien/resin/wall
	name = "resin wall"
	desc = "Thick resin solidified into a wall."
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi'
	icon_state = "resin_wall-0" //same as resin, but consistency ho!
	base_icon_state = "resin_wall"
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WALLS)

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
	icon_state = "resin_membrane-0"
	base_icon_state = "resin_membrane"
	opacity = 0
	max_integrity = 160
	resintype = "membrane"
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WALLS)

/obj/structure/alien/resin/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
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
	icon = 'icons/obj/smooth_structures/alien/weeds1.dmi'
	icon_state = "weeds1-0"
	base_icon_state = "weeds1"
	max_integrity = 15
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WEEDS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WEEDS, SMOOTH_GROUP_WALLS)
	transform = matrix(1, 0, -4, 0, 1, -4)
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
	spawn(rand(150, 200))
		if(src)
			Life()

/obj/structure/alien/weeds/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src)
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

//Weed nodes
/obj/structure/alien/weeds/node
	name = "glowing resin"
	desc = "Blue bioluminescence shines from beneath the surface."
	icon = 'icons/obj/smooth_structures/alien/weednode.dmi'
	icon_state = "weednode-0"
	base_icon_state = "weednode"
	light_range = 1
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

#undef WEED_NORTH_EDGING
#undef WEED_SOUTH_EDGING
#undef WEED_EAST_EDGING
#undef WEED_WEST_EDGING
