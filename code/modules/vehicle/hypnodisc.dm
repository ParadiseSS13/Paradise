/obj/vehicle/hypnodisc
	name = "Hypnodisc"
	desc = "From Middleton Cheney boundry in Oxfordshire, <b>Hypnodisc</b>"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "hypnodisc"
	vehicle_move_delay = 1

/obj/vehicle/hypnodisc/handle_vehicle_offsets()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(dir)
			switch(dir)
				if(NORTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 10
				if(SOUTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 8
				if(EAST)
					buckled_mob.pixel_x = -8
					buckled_mob.pixel_y = 10
				if(WEST)
					buckled_mob.pixel_x = 8
					buckled_mob.pixel_y = 10

/obj/vehicle/hypnodisc/Bump(atom/movable/M)
	// Handle doors
	..()

	if(!has_buckled_mobs())
		// No murder if no one is on it
		return

	if(!istype(M, /mob/living/carbon/human))
		// No murdering non humans
		return

	var/mob/living/carbon/human/H = M

	H.adjustBruteLoss(75) // Youve been hit with a bigass spinning disc - its going to hurt
	// We ignore canstun here, need to knock people over to avoid chain damage
	H.Stun(10 SECONDS, TRUE)
	H.Weaken(10 SECONDS, TRUE)

