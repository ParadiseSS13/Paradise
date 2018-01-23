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

/obj/effect/overlay/temp/speedbike_trail
	name = "speedbike trails"
	icon = 'icons/effects/effects.dmi'
	icon_state = "ion_fade"
	duration = 10
	randomdir = 0
	layer = MOB_LAYER - 0.2

/obj/effect/overlay/temp/speedbike_trail/New(loc,move_dir)
	..()
	dir = move_dir

/obj/vehicle/space/speedbike/Move(newloc,move_dir)
	if(has_buckled_mobs())
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
	if(has_buckled_mobs())
		for(var/i in 1 to buckled_mobs.len)
			var/mob/living/buckled_mob = buckled_mobs[i]
			switch(buckled_mob.dir)
				if(NORTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 8 * i
				if(SOUTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 4 * i
				if(EAST)
					buckled_mob.pixel_x = -10 * i
					buckled_mob.pixel_y = 5 * i
				if(WEST)
					buckled_mob.pixel_x = 10 * i
					buckled_mob.pixel_y = 5 * i

/obj/vehicle/space/speedbike/red
	icon_state = "speedbike_red"
	overlay_state = "cover_red"