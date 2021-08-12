/obj/structure/snow
	name = "snow"
	desc = "A crunchy layer of freshly fallen snow."
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	max_integrity = 15
	COOLDOWN_DECLARE(snowball_cooldown) // very cool down

/obj/structure/snow/AltClick(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, snowball_cooldown))
		return
	if(ishuman(user) && Adjacent(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/snowball/S = new
		COOLDOWN_START(src, snowball_cooldown, 3 SECONDS)

		if(H.put_in_hands(S))
			playsound(src, 'sound/weapons/slashmiss.ogg', 15) // crunchy snow sound
		else
			qdel(S) // Spawn in hands only
