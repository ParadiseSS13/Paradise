/obj/vehicle/space/speedbike
	name = "Speedbike"
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedbike_blue"
	layer = MOB_LAYER - 0.1
	keytype = null
	vehicle_move_delay = 0
	var/overlay_state = "cover_blue"
	var/image/overlay = null

/obj/vehicle/space/speedbike/New()
	..()
	overlay = image("icons/obj/bike.dmi", overlay_state)
	overlay.layer = MOB_LAYER + 0.1
	overlays += overlay

/obj/vehicle/space/speedbike/Move(newloc,move_dir)
	if(buckled_mob)
		new /obj/effect/temp_visual/dir_setting/speedbike_trail(loc)
	. = ..()

/obj/vehicle/space/speedbike/handle_vehicle_layer()
	switch(dir)
		if(NORTH,SOUTH)
			pixel_x = -16
			pixel_y = -16
		if(EAST,WEST)
			pixel_x = -18
			pixel_y = 0

/obj/vehicle/space/speedbike/handle_vehicle_offsets()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = -8
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -10
				buckled_mob.pixel_y = 5
			if(WEST)
				buckled_mob.pixel_x = 10
				buckled_mob.pixel_y = 5

/obj/vehicle/space/speedbike/red
	icon_state = "speedbike_red"
	overlay_state = "cover_red"