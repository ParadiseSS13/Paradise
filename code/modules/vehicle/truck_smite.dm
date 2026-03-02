/obj/effect/immovablerod/truck
	icon = 'icons/tgmc/objects/64x64.dmi'
	icon_state = "truck"

/obj/effect/immovablerod/truck/clong(turf/victim)
	if(prob(10))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		audible_message("CLANG")

	clong_thing(soon_to_be_isekaied)

/obj/effect/immovablerod/truck/clong_thing(mob/living/carbon/human/victim)
	if(!istype(victim))
		return
