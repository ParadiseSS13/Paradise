/obj/vehicle/car
	name = "sports car"
	desc = "A very luxurious vehicle."
	icon = 'icons/vehicles/sportscar.dmi'
	icon_state = "sportscar"
	var/static/image/carcover = null

/obj/vehicle/car/buckle_mob(mob/living/M, force = 0, check_loc = 1)
	. = ..()
	riding_datum = new/datum/riding/speedwagon

/obj/vehicle/car/New()
	..()
	if(!carcover)
		carcover = image("icons/vehicles/sportscar.dmi", "sportscar_cover")
		carcover.layer = MOB_LAYER + 0.1


/obj/vehicle/car/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		overlays += carcover
	else
		overlays -= carcover

