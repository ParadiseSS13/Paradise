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

/obj/structure/snow/AltClick(mob/user)
	. = ..()
	if(ishuman(user) && Adjacent(user))
		var/mob/living/carbon/human/H = user
		H.put_in_hands(new /obj/item/snowball)
