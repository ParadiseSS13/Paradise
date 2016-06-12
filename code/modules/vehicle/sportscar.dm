/obj/vehicle/car
	name = "sports car"
	desc = "A very luxurious vehicle."
	icon = 'icons/vehicles/sportscar.dmi'
	icon_state = "sportscar"
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 1
	var/static/image/carcover = null


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

/obj/vehicle/car/handle_vehicle_offsets()
	..()
	if(buckled_mob)
		switch(buckled_mob.dir)
			if(NORTH)
				buckled_mob.pixel_x = 2
				buckled_mob.pixel_y = 20
			if(EAST)
				buckled_mob.pixel_x = 20
				buckled_mob.pixel_y = 23
			if(SOUTH)
				buckled_mob.pixel_x = 20
				buckled_mob.pixel_y = 27
			if(WEST)
				buckled_mob.pixel_x = 34
				buckled_mob.pixel_y = 10


/obj/vehicle/car/handle_vehicle_layer()
	if(dir == SOUTH)
		layer = MOB_LAYER+0.1
	else
		layer = OBJ_LAYER