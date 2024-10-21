/obj/effect/turf_decal
	icon = 'icons/turf/decals.dmi'
	icon_state = "warningline"
	layer = TURF_DECAL_LAYER

/obj/effect/turf_decal/Initialize(mapload)
	..()
	. = INITIALIZE_HINT_QDEL
	var/turf/T = loc
	if(!istype(T)) //you know this will happen somehow
		CRASH("Turf decal initialized in an object/nullspace")

	T.AddElement(/datum/element/decal, icon, icon_state, dir, layer, alpha, color, FALSE, null)
