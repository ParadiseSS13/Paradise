//Anomalies, used for events. Note that these DO NOT work by themselves; their procs are called by the event datum.

/// Chance of taking a step per second
#define ANOMALY_MOVECHANCE 70
#define BLUESPACE_MASS_TELEPORT_RANGE 16

/obj/effect/anomaly
	name = "anomaly"
	desc = "A mysterious anomaly, seen commonly only in the region of space that the station orbits..."
	icon_state = "bhole3"
	density = FALSE
	light_range = 3
	var/movechance = ANOMALY_MOVECHANCE
	var/obj/item/assembly/signaler/anomaly/aSignal = /obj/item/assembly/signaler/anomaly
	var/area/impact_area
	/// Time in deciseconds before the anomaly triggers
	var/lifespan = 990
	var/death_time

	var/countdown_colour
	var/obj/effect/countdown/anomaly/countdown

	/// Do we drop a core when we're neutralized?
	var/drops_core = TRUE

/obj/effect/anomaly/Initialize(mapload, new_lifespan, _drops_core = TRUE)
	. = ..()
	GLOB.poi_list |= src
	START_PROCESSING(SSobj, src)
	impact_area = get_area(src)

	if(!impact_area)
		return INITIALIZE_HINT_QDEL

	drops_core = _drops_core

	aSignal = new aSignal(src)
	aSignal.code = rand(1, 100)
	aSignal.anomaly_type = type

	var/frequency = rand(PUBLIC_LOW_FREQ, PUBLIC_HIGH_FREQ)
	if(ISMULTIPLE(frequency, 2))//signaller frequencies are always uneven!
		frequency++
	aSignal.frequency = frequency

	if(new_lifespan)
		lifespan = new_lifespan
	death_time = world.time + lifespan
	countdown = new(src)
	if(countdown_colour)
		countdown.color = countdown_colour
	countdown.start()

/obj/effect/anomaly/Destroy()
	GLOB.poi_list.Remove(src)
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(countdown)
	QDEL_NULL(aSignal)
	return ..()

/obj/effect/anomaly/process()
	anomalyEffect()
	if(death_time < world.time)
		if(loc)
			detonate()
		qdel(src)

/obj/effect/anomaly/proc/anomalyEffect()
	if(prob(movechance))
		step(src, pick(GLOB.alldirs))

/obj/effect/anomaly/proc/detonate()
	return

/obj/effect/anomaly/ex_act(severity)
	if(severity == EXPLODE_DEVASTATE)
		qdel(src)

/obj/effect/anomaly/proc/anomalyNeutralize()
	new /obj/effect/particle_effect/smoke/bad(loc)

	if(drops_core)
		aSignal.forceMove(drop_location())
		aSignal = null
	// else, anomaly core gets deleted by qdel(src).

	qdel(src)


/obj/effect/anomaly/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/analyzer))
		to_chat(user, "<span class='notice'>Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(aSignal.frequency)], code [aSignal.code].</span>")

///////////////////////

/obj/effect/anomaly/grav
	name = "gravitational anomaly"
	icon_state = "shield2"
	density = FALSE
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	var/boing = FALSE
	var/knockdown = FALSE
	aSignal = /obj/item/assembly/signaler/anomaly/grav
	var/obj/effect/warp_effect/supermatter/warp

/obj/effect/anomaly/grav/Initialize(mapload, new_lifespan, _drops_core = TRUE, event_spawned = TRUE)
	. = ..()
	warp = new(src)
	vis_contents += warp
	if(!event_spawned) //So an anomaly in the hallway is assured to have some risk to it, but not make sm / vetus too much pain
		return
	for(var/I in 1 to 3)
		if(prob(75))
			new /obj/item/stack/rods(loc)
		if(prob(75))
			new /obj/item/shard(loc)

/obj/effect/anomaly/grav/Destroy()
	vis_contents -= warp
	QDEL_NULL(warp)  // don't want to leave it hanging
	return ..()

/obj/effect/anomaly/grav/anomalyEffect()
	..()
	boing = TRUE
	for(var/obj/O in orange(4, src))
		if(!O.anchored)
			step_towards(O,src)
	for(var/mob/living/M in range(0, src))
		gravShock(M)
	for(var/mob/living/M in orange(4, src))
		if(!M.mob_negates_gravity())
			step_towards(M,src)
	for(var/obj/O in range(0, src))
		if(!O.anchored && O.loc != src && O.move_resist < MOVE_FORCE_OVERPOWERING) // so it cannot throw the anomaly core or super big things
			for(var/mob/living/target in view(4, src))
				if(target && !target.stat && (get_dist(target, src) > 1 || prob(50))) //We don't want to always throw at the person that is in the anomaly, fuck up people around it.
					O.throw_at(target, 5, 10, dodgeable = FALSE)
					break
	//anomaly quickly contracts then slowly expands it's ring
	animate(warp, time = 6, transform = matrix().Scale(0.5,0.5))
	animate(time = 14, transform = matrix())

/obj/effect/anomaly/grav/Crossed(atom/movable/AM)
	. = ..()
	gravShock(AM)

/obj/effect/anomaly/grav/Bump(atom/A)
	gravShock(A)

/obj/effect/anomaly/grav/Bumped(atom/movable/AM)
	gravShock(AM)

/obj/effect/anomaly/grav/proc/gravShock(mob/living/A)
	if(boing && isliving(A) && !A.stat)
		if(!knockdown)
			A.Weaken(4 SECONDS)
		else
			A.KnockDown(4 SECONDS) //You know, maybe hard stuns in a megafauna fight are a bad idea.
		var/atom/target = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
		A.throw_at(target, 5, 1)
		boing = FALSE

/obj/effect/anomaly/grav/detonate()
	if(!drops_core)
		return
	var/turf/T = get_turf(src)
	if(T && length(GLOB.gravity_generators["[T.z]"]))
		var/obj/machinery/gravity_generator/main/G = pick(GLOB.gravity_generators["[T.z]"])
		G.set_broken() //Requires engineering to fix the gravity generator, as it gets overloaded by the anomaly.

/////////////////////

/obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "electricity2"
	density = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/flux
	var/canshock = FALSE
	var/shockdamage = 20
	var/explosive = TRUE
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
	var/zap_range = 5
	var/power = 5000
	var/knockdown = FALSE

/obj/effect/anomaly/flux/Initialize(mapload, new_lifespan, drops_core = TRUE, _explosive = TRUE)
	. = ..()
	explosive = _explosive
	if(explosive)
		zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN
		power = 15000

/obj/effect/anomaly/flux/anomalyEffect()
	..()
	canshock = TRUE
	for(var/mob/living/M in get_turf(src))
		mobShock(M)
	if(explosive) //Let us not fuck up the sm that much
		tesla_zap(src, zap_range, power, zap_flags)


/obj/effect/anomaly/flux/Crossed(atom/movable/AM)
	. = ..()
	mobShock(AM)

/obj/effect/anomaly/flux/Bump(atom/A)
	mobShock(A)

/obj/effect/anomaly/flux/Bumped(atom/movable/AM)
	mobShock(AM)

/obj/effect/anomaly/flux/proc/mobShock(mob/living/M)
	if(canshock && istype(M))
		canshock = FALSE //Just so you don't instakill yourself if you slam into the anomaly five times in a second.
		M.electrocute_act(shockdamage, name, flags = SHOCK_NOGLOVES)
		if(!knockdown)
			M.Weaken(explosive ? 6 SECONDS : 3 SECONDS) //Back to being deadly if you touch it, rather than just being able to crawl out of it. Non explosive ones less deadly, since you can't loot them
		else
			M.KnockDown(3 SECONDS)

/obj/effect/anomaly/flux/detonate()
	if(explosive)
		explosion(src, 1, 4, 16, 18) //Low devastation, but hits a lot of stuff.
	else
		new /obj/effect/particle_effect/sparks(loc)

/////////////////////

/obj/effect/anomaly/bluespace
	name = "bluespace anomaly"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	density = TRUE
	var/mass_teleporting = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/bluespace

/obj/effect/anomaly/bluespace/Initialize(mapload, new_lifespan, drops_core = TRUE, _mass_teleporting = TRUE)
	. = ..()
	mass_teleporting = _mass_teleporting

/obj/effect/anomaly/bluespace/anomalyEffect()
	..()
	for(var/mob/living/M in range(4, src))
		do_teleport(M, locate(M.x, M.y, M.z), 4)
	for(var/obj/O in range (4, src))
		if(!O.anchored && O.invisibility == 0 && prob(50))
			do_teleport(O, locate(O.x, O.y, O.z), 6)

/obj/effect/anomaly/bluespace/Bumped(atom/movable/AM)
	if(isliving(AM))
		do_teleport(AM, locate(AM.x, AM.y, AM.z), 8)

/obj/effect/anomaly/bluespace/detonate()
	if(!mass_teleporting)
		return
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		// Calculate new position (searches through beacons in world)
		var/obj/item/radio/beacon/chosen
		var/list/possible = list()
		for(var/obj/item/radio/beacon/W in GLOB.beacons)
			if(!is_station_level(W.z))
				continue
			possible += W

		if(length(possible))
			chosen = pick(possible)

		if(chosen)
			// Calculate previous position for transition
			var/turf/turf_from = T // the turf of origin we're travelling FROM
			var/turf/turf_to = get_turf(chosen) // the turf of origin we're travelling TO

			playsound(turf_to, 'sound/effects/phasein.ogg', 100, TRUE)
			GLOB.minor_announcement.Announce("Massive bluespace translocation detected.", "Anomaly Alert")

			var/list/flashers = list()
			for(var/mob/living/carbon/C in viewers(turf_to, null))
				if(C.flash_eyes())
					flashers += C

			var/y_distance = turf_to.y - turf_from.y
			var/x_distance = turf_to.x - turf_from.x
			for(var/atom/movable/A in urange(BLUESPACE_MASS_TELEPORT_RANGE, turf_from)) // iterate thru list of mobs in the area
				if(istype(A, /obj/item/radio/beacon))
					continue // don't teleport beacons because that's just insanely stupid
				if(A.anchored || A.move_resist == INFINITY)
					continue

				var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, turf_to.z) // calculate the new place
				if(!A.Move(newloc) && newloc) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
					A.forceMove(newloc)

				if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
					var/mob/M = A
					if(M.client)
						INVOKE_ASYNC(src, PROC_REF(blue_effect), M)

/obj/effect/anomaly/bluespace/proc/blue_effect(mob/M)
	var/obj/blueeffect = new /obj(src)
	blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
	blueeffect.icon = 'icons/effects/effects.dmi'
	blueeffect.icon_state = "shieldsparkles"
	blueeffect.layer = FLASH_LAYER
	blueeffect.plane = FULLSCREEN_PLANE
	blueeffect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	M.client.screen += blueeffect
	sleep(20)
	M.client.screen -= blueeffect
	qdel(blueeffect)


/////////////////////

/obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "mustard"
	var/ticks = 0
	var/produces_slime = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/pyro

/obj/effect/anomaly/pyro/Initialize(mapload, new_lifespan, drops_core = TRUE, _produces_slime = TRUE)
	. = ..()
	produces_slime = _produces_slime

/obj/effect/anomaly/pyro/anomalyEffect()
	..()
	ticks++
	for(var/mob/living/M in hearers(4, src))
		if(prob(50))
			M.adjust_fire_stacks(4)
			M.IgniteMob()

	if(ticks < 4)
		return
	else
		ticks = 0
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS | LINDA_SPAWN_OXYGEN, 20)

/obj/effect/anomaly/pyro/detonate()
	if(produces_slime)
		INVOKE_ASYNC(src, PROC_REF(makepyroslime))

/obj/effect/anomaly/pyro/proc/makepyroslime()
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS | LINDA_SPAWN_OXYGEN, 500) //Make it hot and burny for the new slime
	var/new_colour = pick("red", "orange")
	var/mob/living/simple_animal/slime/S = new(T, new_colour)
	S.rabid = TRUE
	S.amount_grown = SLIME_EVOLUTION_THRESHOLD
	S.Evolve()
	var/datum/action/innate/slime/reproduce/A = new
	A.Grant(S)

	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as a pyroclastic anomaly slime?", ROLE_SENTIENT, FALSE, 100, source = S, role_cleanname = "pyroclastic anomaly slime")
	if(length(candidates) && !QDELETED(S))
		var/mob/dead/observer/chosen = pick(candidates)
		S.key = chosen.key
		S.mind.special_role = SPECIAL_ROLE_PYROCLASTIC_SLIME
		dust_if_respawnable(chosen)
		log_game("[key_name(S.key)] was made into a slime by pyroclastic anomaly at [AREACOORD(T)].")

/////////////////////

/obj/effect/anomaly/cryo
	name = "cryogenic anomaly"
	desc = "Hope you brought a jacket!"
	icon_state = "cryoanomaly"
	aSignal = /obj/item/assembly/signaler/anomaly/cryo

/obj/effect/anomaly/cryo/anomalyEffect()
	..()

	var/list/turf_targets = list()
	for(var/turf/T in oview(get_turf(src), 7))
		turf_targets += T

	for(var/mob/living/carbon/human/H in view(get_turf(src), 3))
		shootAt(H)

	for(var/I in 1 to rand(1, 3))
		var/turf/target = pick(turf_targets)
		shootAt(target)

	if(prob(50))
		for(var/turf/simulated/floor/nearby_floor in oview(get_turf(src), (drops_core ? 2 : 1)))
			nearby_floor.MakeSlippery((drops_core? TURF_WET_PERMAFROST : TURF_WET_ICE), (drops_core? null : rand(10, 20 SECONDS)))

		var/turf/simulated/T = get_turf(src)
		if(istype(T))
			T.atmos_spawn_air(LINDA_SPAWN_COLD | LINDA_SPAWN_N2O | LINDA_SPAWN_CO2, 20)

	if(prob(10))
		var/obj/effect/nanofrost_container/A = new /obj/effect/nanofrost_container(get_turf(src))
		for(var/i in 1 to 5)
			step_towards(A, pick(turf_targets))
			sleep(2)
		A.Smoke()

/obj/effect/anomaly/cryo/proc/shootAt(atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!T || !U)
		return
	var/obj/item/projectile/temp/basilisk/O = new /obj/item/projectile/temp/basilisk(T)
	playsound(get_turf(src), 'sound/weapons/taser2.ogg', 75, TRUE)
	if(drops_core)
		O.stun = 0.5 SECONDS
	O.original = target
	O.current = T
	O.yo = U.y - T.y
	O.xo = U.x - T.x
	O.fire()

/obj/effect/anomaly/cryo/detonate()
	var/turf/simulated/T = get_turf(src)
	if(istype(T) && drops_core)
		T.atmos_spawn_air(LINDA_SPAWN_COLD | LINDA_SPAWN_CO2, 1000)

/////////////////////

/obj/effect/anomaly/bhole
	name = "vortex anomaly"
	icon_state = "bhole3"
	desc = "That's a nice station you have there. It'd be a shame if something happened to it."
	aSignal = /obj/item/assembly/signaler/anomaly/vortex

/obj/effect/anomaly/bhole/anomalyEffect()
	..()
	if(!isturf(loc)) //blackhole cannot be contained inside anything. Weird stuff might happen
		qdel(src)
		return

	grav(rand(0, 3), rand(2, 3), 100, 30)

	//Throwing stuff around!
	for(var/obj/O in range(3, src))
		if(O == src || O.loc == src)
			return //DON'T DELETE YOURSELF OR YOUR CORE GOD DAMN
		if(!O.anchored)
			var/mob/living/target = locate() in view(5, src)
			if(target && !target.stat)
				O.throw_at(target, 7, 5, dodgeable = FALSE)
		else
			O.ex_act(EXPLODE_HEAVY)

/obj/effect/anomaly/bhole/proc/grav(r, ex_act_force, pull_chance, turf_removal_chance)
	for(var/t = -r, t < r, t++)
		affect_coord(x + t, y - r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x - t, y + r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x + r, y + t, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x - r, y - t, ex_act_force, pull_chance, turf_removal_chance)

/obj/effect/anomaly/bhole/proc/affect_coord(x, y, ex_act_force, pull_chance, turf_removal_chance)
	//Get turf at coordinate
	var/turf/T = locate(x, y, z)
	if(isnull(T))
		return

	//Pulling and/or ex_act-ing movable atoms in that turf
	if(prob(pull_chance))
		for(var/obj/O in T.contents)
			if(O.anchored)
				O.ex_act(ex_act_force)
			else
				step_towards(O, src)
		for(var/mob/living/M in T.contents)
			step_towards(M, src)
			if(drops_core)
				M.Weaken(3.5 SECONDS) //You ran into a black hole, you ride the pain train.
			M.KnockDown(7 SECONDS)

	//Damaging the turf
	if(T && prob(turf_removal_chance))
		T.ex_act(ex_act_force)

#undef ANOMALY_MOVECHANCE
#undef BLUESPACE_MASS_TELEPORT_RANGE
