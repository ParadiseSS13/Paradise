/obj/vehicle/motorcycle
	name = "motorcycle"
	desc = "A fast and highly maneuverable vehicle."
	icon = 'icons/vehicles/motorcycle.dmi'
	icon_state = "motorcycle_4dir"
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 1
	var/static/image/bikecover = null


/obj/vehicle/motorcycle/New()
	..()
	if(!bikecover)
		bikecover = image("icons/vehicles/motorcycle.dmi", "motorcycle_overlay_4d")
		bikecover.layer = MOB_LAYER + 0.1


obj/vehicle/motorcycle/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		overlays += bikecover
	else
		overlays -= bikecover


/obj/vehicle/motorcycle/handle_vehicle_layer()
	if(dir == SOUTH)
		layer = MOB_LAYER+0.1
	else
		layer = OBJ_LAYER