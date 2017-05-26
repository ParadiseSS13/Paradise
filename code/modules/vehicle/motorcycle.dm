/obj/vehicle/motorcycle
	name = "motorcycle"
	desc = "A fast and highly maneuverable vehicle."
	icon = 'icons/vehicles/motorcycle.dmi'
	icon_state = "motorcycle_4dir"
	var/static/image/bikecover = null

/obj/vehicle/motorcycle/buckle_mob()
	. = ..()
	riding_datum = new/datum/riding/motorcycle

/obj/vehicle/motorcycle/New()
	..()
	if(!bikecover)
		bikecover = image("icons/vehicles/motorcycle.dmi", "motorcycle_overlay_4d")
		bikecover.layer = MOB_LAYER + 0.1
		riding_datum = new/datum/riding/motorcycle


/obj/vehicle/motorcycle/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		overlays += bikecover
	else
		overlays -= bikecover

