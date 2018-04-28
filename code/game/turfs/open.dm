/turf/open
	var/slowdown = 0 //negative for faster, positive for slower

	var/image/wet_overlay = null

/turf/open/indestructible
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

/turf/open/indestructible/sound
	name = "squeeky floor"
	var/sound

/turf/open/indestructible/sound/Entered(var/mob/AM)
	if(istype(AM))
		playsound(src,sound,50,1)

/turf/open/Initalize_Atmos(times_fired)
	excited = 0
	update_visuals()

	current_cycle = times_fired

	//cache some vars
	var/datum/gas_mixture/air = src.air
	var/list/atmos_adjacent_turfs = src.atmos_adjacent_turfs

	for(var/direction in cardinal)
		var/turf/open/enemy_tile = get_step(src, direction)
		if(!istype(enemy_tile))
			atmos_adjacent_turfs -= enemy_tile
			continue
		var/datum/gas_mixture/enemy_air = enemy_tile.return_air()

		//only check this turf, if it didn't check us when it was initalized
		if(enemy_tile.current_cycle < times_fired)
			if(CanAtmosPass(enemy_tile))
				atmos_adjacent_turfs |= enemy_tile
				enemy_tile.atmos_adjacent_turfs |= src
			else
				atmos_adjacent_turfs -= enemy_tile
				enemy_tile.atmos_adjacent_turfs -= src
				continue
		else
			if (!(enemy_tile in atmos_adjacent_turfs))
				continue


		var/is_active = air.compare(enemy_air)

		if(is_active)
			//testing("Active turf found. Return value of compare(): [is_active]")
			if(!excited) //make sure we aren't already excited
				excited = 1
				SSair.active_turfs |= src

/turf/open/proc/GetHeatCapacity()
	. = air.heat_capacity()

/turf/open/proc/GetTemperature()
	. = air.temperature

/turf/open/proc/TakeTemperature(temp)
	air.temperature += temp
	air_update_turf()

/turf/open/handle_fall(mob/faller, forced)
	faller.lying = pick(90, 270)
	if(!forced)
		return
	if(has_gravity(src))
		playsound(src, "bodyfall", 50, 1)

/turf/open/handle_slip(mob/living/carbon/C, s_amount, w_amount, obj/O, lube)
	if(has_gravity(src))
		var/obj/buckled_obj
		if(C.buckled)
			buckled_obj = C.buckled
			if(!(lube&GALOSHES_DONT_HELP)) //can't slip while buckled unless it's lube.
				return 0
		else
			if(C.lying || !(CANWEAKEN in C.status_flags)) // can't slip unbuckled mob if they're lying or can't fall.
				return 0
			if(C.m_intent=="walk" && (lube & NO_SLIP_WHEN_WALKING))
				return 0
		C << "<span class='notice'>You slipped[ O ? " on the [O.name]" : ""]!</span>"

		C.attack_log += "\[[time_stamp()]\] <font color='orange'>Slipped[O ? " on the [O.name]" : ""][(lube&SLIDE)? " (LUBE)" : ""]!</font>"
		playsound(C.loc, 'sound/misc/slip.ogg', 50, 1, -3)

		C.accident(C.l_hand)
		C.accident(C.r_hand)

		var/olddir = C.dir
		C.Stun(s_amount)
		C.Weaken(w_amount)
		C.stop_pulling()
		if(buckled_obj)
			buckled_obj.unbuckle_mob(C)
			step(buckled_obj, olddir)
		else if(lube&SLIDE)
			for(var/i=1, i<5, i++)
				spawn (i)
					step(C, olddir)
					C.spin(1,1)
		return 1
