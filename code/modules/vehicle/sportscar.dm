/obj/vehicle/car
	name = "sports car"
	desc = "A very luxurious vehicle."
	icon = 'icons/vehicles/sportscar.dmi'
	icon_state = "sportscar"
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 1
	var/mutable_appearance/carcover

/obj/vehicle/car/Initialize(mapload)
	. = ..()
	carcover = mutable_appearance(icon, "sportscar_cover", ABOVE_MOB_LAYER)

/obj/vehicle/car/post_buckle_mob(mob/living/M)
	add_overlay(carcover)
	return ..()

/obj/vehicle/car/post_unbuckle_mob(mob/living/M)
	if(!has_buckled_mobs())
		cut_overlay(carcover)
	return ..()

/obj/vehicle/car/handle_vehicle_offsets()
	..()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
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
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER
