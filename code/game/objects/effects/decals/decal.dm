/obj/effect/turf_decal
	icon = 'icons/turf/decals.dmi'
	icon_state = "warningline"
	layer = TURF_DECAL_LAYER

/obj/effect/turf_decal/Initialize(mapload)
	. = ..()
	qdel(src) // return INITIALIZE_HINT_QDEL <-- Doesn't work

/obj/effect/turf_decal/ComponentInitialize()
	. = ..()
	var/turf/T = loc
	if(!istype(T)) //you know this will happen somehow
		CRASH("Turf decal initialized in an object/nullspace")
	T.AddComponent(/datum/component/decal, icon, icon_state, dir, CLEAN_GOD, color, null, null, alpha)