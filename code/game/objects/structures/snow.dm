/obj/structure/snow
	name = "snow"
	desc = "A crunchy layer of freshly fallen snow."
	anchored = TRUE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	max_integrity = 15
	var/cooldown = 0 // very cool down

/obj/structure/snow/AltClick(mob/user)
	if(cooldown > world.time)
		return
	if(ishuman(user) && Adjacent(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/snowball/S = new
		cooldown = world.time + 3 SECONDS

		if(H.put_in_hands(S))
			playsound(src, 'sound/weapons/slashmiss.ogg', 15) // crunchy snow sound
		else
			qdel(S) // Spawn in hands only
