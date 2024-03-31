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

/obj/vehicle/hypnodisc/Bump(atom/A)
	// Handle doors
	..()

	if(!has_buckled_mobs())
		// No murder if no one is on it
		return

	if(istype(A, /obj/machinery/door))
		return // We already handled doors

	playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	playsound(src, 'sound/weapons/circsawhit.ogg', 50, TRUE)

	if(istype(A, /mob/living/carbon/human))
		// Handle human damage
		var/mob/living/carbon/human/H = A

		H.adjustBruteLoss(75) // Youve been hit with a bigass spinning disc - its going to hurt
		// We ignore canstun here, need to knock people over to avoid chain damage
		H.Stun(10 SECONDS, TRUE)
		H.Weaken(10 SECONDS, TRUE)


	if(istype(A, /turf/simulated/wall))
		var/wall_damage = 25 // Base wall damage

		if(istype(A, /turf/simulated/wall/r_wall))
			wall_damage = 50 // More damage for rwalls

		var/turf/simulated/wall/W = A
		W.take_damage(wall_damage)


	if(istype(A, /obj))
		// Damage objects
		var/obj/O = A
		O.take_damage(50)
