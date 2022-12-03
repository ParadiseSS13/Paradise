/obj/effect/turf_decal
	icon = 'icons/turf/decals.dmi'
	icon_state = "warningline"
	layer = TURF_DECAL_LAYER
	var/do_not_delete_me = FALSE

/obj/effect/turf_decal/Initialize(mapload)
	. = ..()
	if(!do_not_delete_me)
		qdel(src) // return INITIALIZE_HINT_QDEL <-- Doesn't work
	invisibility = INVISIBILITY_MAXIMUM

/obj/effect/turf_decal/ComponentInitialize()
	. = ..()
	var/turf/T = loc
	if(!istype(T)) //you know this will happen somehow
		CRASH("Turf decal initialized in an object/nullspace")
	T.AddComponent(/datum/component/decal, icon, icon_state, dir, CLEAN_GOD, color, null, null, alpha)

/obj/effect/turf_decal/onShuttleMove()
	. = ..()
	var/turf/T = loc
	if(!istype(T)) //you know this will happen somehow
		return
	T.AddComponent(/datum/component/decal, icon, icon_state, dir, CLEAN_GOD, color, null, null, alpha)
