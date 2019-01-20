
/obj/structure/fusionreactor
	name = "syndicate fusion reactor"
	desc = ""
	icon = 'icons/obj/device.dmi'
	icon_state = "powersink1"
	anchored = 1
	max_integrity = 50
	var/area/syndicate_depot/core/depotarea
	var/has_overloaded = FALSE

/obj/structure/fusionreactor/New()
	. = ..()
	// Do not attempt to put the code below into Initialize() or even LateInitialize() with a "return INITIALIZE_HINT_LATELOAD". It won't work!
	depotarea = areaMaster
	if(istype(depotarea))
		depotarea.reactor = src
		for(var/obj/machinery/porta_turret/syndicate/T in range(50, loc))
			if(!istype(T.depotarea))
				T.depotarea = depotarea
	else
		log_debug("[src] at [x],[y],[z] failed depotarea istype check during New()! Either it was spawned outside the depot area (bad idea), or a bug is happening.")

/obj/structure/fusionreactor/Destroy()
	if(istype(depotarea))
		if(!has_overloaded)
			overload(TRUE, TRUE)
		depotarea.reactor = null
	..()

/obj/structure/fusionreactor/ex_act(severity)
	if(severity < 3)
		obj_integrity = 0
		healthcheck()

/obj/structure/fusionreactor/bullet_act(obj/item/projectile/Proj)
	obj_integrity -= Proj.damage
	..()
	healthcheck()

/obj/structure/fusionreactor/proc/healthcheck()
	if(obj_integrity <= 0 && istype(depotarea))
		overload(TRUE)

/obj/structure/fusionreactor/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))
		playsound(loc, I.usesound, 50, 1)
		to_chat(user, "<span class='notice'>The [src] is too well secured to the floor.</span>")
	else if(isscrewdriver(I))
		to_chat(user, "<span class='notice'>You try to screwdriver open [src], but accidentally release some radiation!</span>")
		if(prob(50))
			empulse(src, 4, 10)
		else
			for(var/mob/living/M in range(10, loc))
				M.apply_effect(rand(5, 25), IRRADIATE)
	else
		return ..()

/obj/structure/fusionreactor/proc/overload(containment_failure = FALSE, skip_qdel = FALSE)
	if(has_overloaded)
		return
	has_overloaded = TRUE
	if(istype(depotarea) && !depotarea.used_self_destruct)
		depotarea.activate_self_destruct("Fusion reactor cracked open. Core loose!", TRUE)
	var/obj/effect/overload/O = new /obj/effect/overload(get_turf(src))
	if(containment_failure)
		playsound(loc, 'sound/machines/alarm.ogg', 100, 0, 0)
		O.deliberate = TRUE
		O.max_cycles = 6
	if(!skip_qdel)
		qdel(src)


/obj/effect/overload
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32
	anchored = 1
	var/cycles = 0
	var/beepsound = 'sound/items/timer.ogg'
	var/deliberate = FALSE
	var/max_cycles = 10
	var/max_fire_range = 9
	var/area/syndicate_depot/core/depotarea

/obj/effect/overload/New()
	. = ..()
	// Do not attempt to put the code below into Initialize() or even LateInitialize() with a "return INITIALIZE_HINT_LATELOAD". It won't work!
	processing_objects.Add(src)
	depotarea = areaMaster
	if(istype(depotarea))
		if(!depotarea.used_self_destruct)
			depotarea.used_self_destruct = TRUE // Silences all further alerts from this point onwards.
			depotarea.updateicon()
		depotarea.shields_down()
	else
		log_debug("[src] at [x],[y],[z] failed depotarea istype check during New()! Either it was spawned outside the depot area (bad idea), or a bug is happening.")

/obj/effect/overload/process()
	var/turf/T = get_turf(src)
	if(cycles < max_cycles)
		if(!deliberate)
			playsound(loc, beepsound, 50, 0)
		cycles++
		var/fire_range = min(cycles, max_fire_range)

		for(var/turf/simulated/turf in range(fire_range, T))
			new /obj/effect/hotspot(turf)
		return

	if(!istype(depotarea))
		depotarea = areaMaster
	if(istype(depotarea))
		depotarea.destroyed = TRUE
		depotarea.updateicon()

	for(var/obj/structure/closet/L in range(30, T))
		L.open()
	for(var/mob/living/M in range(30, T))
		M.gib()
	for(var/obj/mecha/E in range(30, T))
		E.Destroy()
	explosion(get_turf(src), 25, 35, 45, 55, 1, 1, 60, 0, 0)
	processing_objects.Remove(src)
	qdel(src)

