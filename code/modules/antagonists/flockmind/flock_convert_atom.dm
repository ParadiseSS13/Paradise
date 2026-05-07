/proc/flock_convert_turf(turf/T, datum/flock/flock, force)
	if(!T?.can_flock_convert(force))
		return

	if(isflockturf(T))
		. = T

	else if(iswallturf(T))
		. = T.ChangeTurf(/turf/simulated/wall/flock)

	else if(isfloorturf(T))
		. = T.ChangeTurf(/turf/simulated/floor/flock)

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

/obj/structure/low_wall/try_flock_convert(datum/flock/flock, force)
	set_material(/datum/material/gnesis, TRUE)
	AddComponent(/datum/component/flock_object)
	AddComponent(/datum/component/flock_protection, report_unarmed=FALSE)
	AddComponent(/datum/component/flock_interest, flock)
	return src

/obj/machinery/light/try_flock_convert(datum/flock/flock, force)
	var/obj/L = new /obj/machinery/light/flock(loc)
	L.setDir(dir)
	qdel(src)
	return L

/obj/machinery/light/floor/try_flock_convert(datum/flock/flock, force)
	. = new /obj/machinery/light/floor/has_bulb/flock(loc)
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

/turf/proc/can_flock_convert(force)
	return FALSE

/turf/open/floor/can_flock_convert(force)
	return TRUE

/turf/simulated/floor/flock/can_flock_convert(force)
	return TRUE

/turf/closed/wall/can_flock_convert(force)
	return TRUE
