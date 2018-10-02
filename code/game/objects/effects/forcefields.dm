/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon = 'icons/effects/effects.dmi'
	icon_state = "m_shield"
	anchored = 1
	opacity = 0
	density = 1
	unacidable = 1

/obj/effect/forcefield/CanAtmosPass(turf/T)
	return !density

///////////Mimewalls///////////

/obj/effect/forcefield/mime
	icon_state = "empty"
	name = "invisible wall"
	desc = "You have a bad feeling about this."
	var/lifetime = 30 SECONDS

/obj/effect/forcefield/mime/New()
	..()
	if(lifetime)
		QDEL_IN(src, lifetime)