/obj/effect/mapping_helpers
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""
	var/late = FALSE

/obj/effect/mapping_helpers/Initialize()
	..()
	return late ? INITIALIZE_HINT_LATELOAD : qdel(src) // INITIALIZE_HINT_QDEL <-- Doesn't work

/obj/effect/mapping_helpers/no_lava
	icon_state = "no_lava"

/obj/effect/mapping_helpers/no_lava/New()
	. = ..()
	var/turf/T = get_turf(src)
	T.flags |= NO_LAVA_GEN