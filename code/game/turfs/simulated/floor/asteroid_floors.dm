
/**********************Asteroid**************************/

/turf/simulated/floor/plating/asteroid
	gender = PLURAL
	name = "asteroid sand"
	baseturf = /turf/simulated/floor/plating/asteroid
	icon_state = "asteroid"
	icon_plating = "asteroid"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	var/environment_type = "asteroid"
	var/turf_type = /turf/simulated/floor/plating/asteroid //Because caves do whacky shit to revert to normal
	var/floor_variance = 20 //probability floor has a different icon state
	var/obj/item/stack/digResult = /obj/item/stack/ore/glass/basalt
	var/dug

/turf/simulated/floor/plating/asteroid/Initialize(mapload)
	var/proper_name = name
	. = ..()
	name = proper_name
	if(prob(floor_variance))
		icon_state = "[environment_type][rand(0,12)]"

/turf/simulated/floor/plating/asteroid/proc/getDug(productivity_mod = 1)
	new digResult(src, round(5 + productivity_mod))
	icon_plating = "[environment_type]_dug"
	icon_state = "[environment_type]_dug"
	SSblackbox.record_feedback("tally", "ore_mined", 5, "[digResult]")
	dug = TRUE

/turf/simulated/floor/plating/asteroid/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, "<span class='notice'>Looks like someone has dug here already.</span>")

/turf/simulated/floor/plating/asteroid/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/simulated/floor/plating/asteroid/burn_tile()
	return

/turf/simulated/floor/plating/asteroid/remove_plating()
	return

/turf/simulated/floor/plating/asteroid/ex_act(severity)
	if(!can_dig())
		return
	switch(severity)
		if(3)
			return
		if(2)
			if(prob(20))
				getDug()
		if(1)
			getDug()

/turf/simulated/floor/plating/asteroid/proc/attempt_ore_pickup(obj/item/storage/bag/ore/S, mob/user)
	if(!istype(S))
		return

	if(S.pickup_all_on_tile)
		for(var/obj/item/stack/ore/O in contents)
			O.attackby__legacy__attackchain(S, user)
			return

/turf/simulated/floor/plating/asteroid/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(QDELETED(user)|| QDELETED(used))
		return ITEM_INTERACT_COMPLETE

	if((istype(used, /obj/item/shovel) || istype(used, /obj/item/pickaxe)))
		if(!can_dig(user))
			return TRUE

		var/turf/T = get_turf(user)
		if(!istype(T))
			return

		to_chat(user, "<span class='notice'>You start digging...</span>")

		playsound(src, used.usesound, 50, TRUE)
		if(do_after(user, 40 * used.toolspeed, target = src))
			if(!can_dig(user))
				return TRUE
			to_chat(user, "<span class='notice'>You dig a hole.</span>")
			getDug(used.bit_productivity_mod)
			return TRUE

	else if(istype(used, /obj/item/storage/bag/ore))
		attempt_ore_pickup(used, user)

	else if(istype(used, /obj/item/stack/tile))
		var/obj/item/stack/tile/Z = used
		if(!Z.use(1))
			return
		if(istype(Z, /obj/item/stack/tile/plasteel)) // Turn asteroid floors into plating by default
			ChangeTurf(/turf/simulated/floor/plating, keep_icon = FALSE)
		else
			ChangeTurf(Z.turf_type, keep_icon = FALSE)
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)

/turf/simulated/floor/plating/asteroid/screwdriver_act(mob/user, obj/item/I)
	return

/turf/simulated/floor/plating/asteroid/welder_act(mob/user, obj/item/I)
	return

/turf/simulated/floor/plating/asteroid/basalt
	name = "volcanic floor"
	baseturf = /turf/simulated/floor/plating/asteroid/basalt
	icon_state = "basalt"
	icon_plating = "basalt"
	environment_type = "basalt"
	floor_variance = 15

/// lava underneath
/turf/simulated/floor/plating/asteroid/basalt/lava
	baseturf = /turf/simulated/floor/lava

/turf/simulated/floor/plating/asteroid/basalt/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/plating/asteroid/ancient
	digResult = /obj/item/stack/ore/glass/basalt/ancient
	baseturf = /turf/simulated/floor/plating/asteroid/ancient/airless

/turf/simulated/floor/plating/asteroid/ancient/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/plating/asteroid/basalt/Initialize(mapload)
	. = ..()
	set_basalt_light(src)

/turf/simulated/floor/plating/asteroid/basalt/getDug()
	set_light(0)
	return ..()

/proc/set_basalt_light(turf/simulated/floor/B)
	switch(B.icon_state)
		if("basalt1", "basalt2", "basalt3")
			B.set_light(2, 0.6, LIGHT_COLOR_LAVA) //more light
		if("basalt5", "basalt9")
			B.set_light(1.4, 0.6, LIGHT_COLOR_LAVA) //barely anything!

///////Surface. The surface is warm, but survivable without a suit. Internals are required. The floors break to chasms, which drop you into the underground.

/turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND
	baseturf = /turf/simulated/floor/lava/mapping_lava

/turf/simulated/floor/plating/asteroid/basalt/lowpressure
	oxygen = 8
	nitrogen = 14

/turf/simulated/floor/plating/asteroid/basalt/lava_land_surface_hard
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND
	color = COLOR_FLOOR_HARD_ROCK
	baseturf = /turf/simulated/floor/lava/lava_land_surface

/turf/simulated/floor/plating/asteroid/basalt/plasma
	temperature = 1000
	oxygen = 0
	nitrogen = 0
	carbon_dioxide = 1.2
	toxins = 10
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/plasma
	atmos_mode = ATMOS_MODE_NO_DECAY

/turf/simulated/floor/plating/asteroid/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0
	turf_type = /turf/simulated/floor/plating/asteroid/airless

/obj/effect/spawner/oasisrock
	name = "Oasis rock spawner"
	var/passed_radius

/obj/effect/spawner/oasisrock/Initialize(mapload, radius)
	. = ..()
	passed_radius = radius
	return INITIALIZE_HINT_LATELOAD

/obj/effect/spawner/oasisrock/LateInitialize() //Let us try this for a moment.
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(make_rock), passed_radius), 5 SECONDS)

/obj/effect/spawner/oasisrock/proc/make_rock(radius)
	var/our_turf = get_turf(src)
	for(var/turf/oasis in circlerangeturfs(our_turf, radius))
		if(istype(oasis.loc, /area/ruin))
			continue
		oasis.ChangeTurf(/turf/simulated/mineral/random/high_chance/volcanic, ignore_air = TRUE)
	var/list/valid_turfs = circlerangeturfs(our_turf, radius + 1)
	valid_turfs -= circlerangeturfs(our_turf, radius)
	for(var/mob/M in circlerange(src, radius)) //We don't want mobs inside the ore rock
		M.forceMove(pick_n_take(valid_turfs))
	for(var/obj/structure/spawner/lavaland/O in circlerange(src, radius)) //We don't want tendrils in there either
		O.forceMove(pick_n_take(valid_turfs))
	qdel(src)

/turf/simulated/floor/plating/asteroid/snow
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	baseturf = /turf/simulated/floor/plating/asteroid/snow
	icon_state = "snow"
	icon_plating = "snow"
	temperature = 180
	slowdown = 2
	environment_type = "snow"
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_COLD
	digResult = /obj/item/stack/sheet/mineral/snow

/turf/simulated/floor/plating/asteroid/snow/burn_tile()
	if(!burnt)
		visible_message("<span class='danger'>[src] melts away!.</span>")
		slowdown = 0
		burnt = TRUE
		icon_state = "snow_dug"
		return TRUE
	return FALSE

/turf/simulated/floor/plating/asteroid/snow/get_burnt_states()
	return list("snow_dug")

/turf/simulated/floor/plating/asteroid/snow/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0
	atmos_mode = ATMOS_MODE_SEALED

/turf/simulated/floor/plating/asteroid/snow/atmosphere
	atmos_mode = ATMOS_MODE_SEALED
