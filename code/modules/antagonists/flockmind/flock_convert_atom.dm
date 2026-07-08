/proc/flock_convert_turf(turf/T, datum/flock/flock, force)
	if(!T?.can_flock_convert(force))
		return

	if(isflockturf(T))
		. = T

	else if(iswallturf(T))
		. = T.ChangeTurf(/turf/simulated/wall/flock, ignore_air = TRUE)

	else if(isfloorturf(T))
		. = T.ChangeTurf(/turf/simulated/floor/flock, ignore_air = TRUE)
		var/list/datum/element/decal/decals = T.get_decals()
		for(var/datum/element/decal/dcl in decals)
			dcl.Detach(T)
		T.RemoveElement(/datum/element/decal)

	var/obj/structure/lattice/L = locate() in .
	if(L)
		qdel(L)
		if(istype(L, /obj/structure/lattice/catwalk))
			. = T.ChangeTurf(/turf/simulated/floor/flock)

	for(var/obj/O in .)
		if(iseffect(O))
			continue

		O.try_flock_convert(flock, force)

/// Attempt to convert an object. Default behavior is to do nothing.
/obj/proc/try_flock_convert(datum/flock/flock, force)
	return

/obj/machinery/camera/try_flock_convert(datum/flock/flock, force)
	deconstruct()

/obj/structure/window/try_flock_convert(datum/flock/flock, force)
	var/turf/T = loc
	var/obj/structure/window/flock/new_window
	qdel(src)

	if(fulltile)
		new_window = new /obj/structure/window/flock/fulltile(T)
	else
		new_window = new /obj/structure/window/flock(T)
		new_window.dir = dir

	new_window.AddComponent(/datum/component/flock_interest, flock)
	return new_window

/obj/machinery/door/try_flock_convert(datum/flock/flock, force)
	var/turf/T = loc
	qdel(src)
	return new /obj/machinery/door/flock(T)

// This results in double layered doors
/obj/machinery/door/firedoor/try_flock_convert(datum/flock/flock, force)
	return

/obj/machinery/light/try_flock_convert(datum/flock/flock, force)
	var/obj/L = new /obj/machinery/light/flock(loc)
	L.setDir(dir)
	qdel(src)
	return L

/obj/machinery/light/floor/try_flock_convert(datum/flock/flock, force)
	. = new /obj/machinery/light/floor/has_bulb/flock(loc)
	qdel(src)

/obj/structure/computerframe/try_flock_convert(datum/flock/flock, force)
	. = new /obj/structure/flock/compute(loc, flock)
	qdel(src)

/obj/machinery/computer4/try_flock_convert(datum/flock/flock, force)
	. = new /obj/structure/flock/compute(loc, flock)
	qdel(src)

/obj/machinery/computer/try_flock_convert(datum/flock/flock, force)
	. = new /obj/structure/flock/compute(loc, flock)
	qdel(src)

/obj/machinery/seed_extractor/try_flock_convert(datum/flock/flock, force)
	. = new /obj/structure/flock/compute(loc, flock)
	qdel(src)

/obj/machinery/telecomms/try_flock_convert(datum/flock/flock, force)
	. = new /obj/structure/flock/compute(loc, flock)
	qdel(src)

/obj/structure/chair/try_flock_convert(datum/flock/flock, force)
	. = ..()
	var/obj/structure/chair/comfy/flock/F = new /obj/structure/chair/comfy/flock(get_turf(src), flock)
	F.AddComponent(/datum/component/flock_interest, flock)
	F.setDir(dir)
	qdel(src)

/obj/structure/lattice/try_flock_convert(datum/flock/flock, force)
	. = ..()
	var/obj/structure/lattice/flock/F = new /obj/structure/lattice/flock(get_turf(src))
	F.AddComponent(/datum/component/flock_interest, flock)
	qdel(src)

/obj/structure/closet/try_flock_convert(datum/flock/flock, force)
	. = ..()
	dump_contents()
	var/obj/structure/closet/flock/F = new(get_turf(src), flock)
	F.take_contents()
	F.AddComponent(/datum/component/flock_interest, flock)
	qdel(src)

/obj/machinery/porta_turret/try_flock_convert(datum/flock/flock, force)
	. = ..()
	new /obj/structure/flock/gnesis_turret(get_turf(src), flock)
	qdel(src)

/obj/structure/grille/try_flock_convert(datum/flock/flock, force)
	var/obj/structure/grille/G
	if(broken)
		G = new /obj/structure/grille/flock/broken(get_turf(src))
	else
		G = new /obj/structure/grille/flock(get_turf(src))
	G.AddComponent(/datum/component/flock_interest, flock)
	qdel(src)

/turf/proc/can_flock_convert(force)
	return FALSE

/turf/space/can_flock_convert(force)
	var/obj/structure/lattice/L = locate() in src
	if(L)
		return TRUE
	return FALSE

/turf/simulated/floor/can_flock_convert(force)
	return TRUE

/turf/simulated/floor/flock/can_flock_convert(force)
	return TRUE

/turf/simulated/wall/can_flock_convert(force)
	return TRUE
