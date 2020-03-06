//TODO: Flash range does nothing currently

/proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1, ignorecap = 0, flame_range = 0, silent = 0, smoke = 1, cause = null, breach = TRUE)
	src = null	//so we don't abort once src is deleted
	epicenter = get_turf(epicenter)

	// Archive the uncapped explosion for the doppler array
	var/orig_dev_range = devastation_range
	var/orig_heavy_range = heavy_impact_range
	var/orig_light_range = light_impact_range

	if(!ignorecap)
		// Clamp all values to MAX_EXPLOSION_RANGE
		devastation_range = min (MAX_EX_DEVASTATION_RANGE, devastation_range)
		heavy_impact_range = min (MAX_EX_HEAVY_RANGE, heavy_impact_range)
		light_impact_range = min (MAX_EX_LIGHT_RANGE, light_impact_range)
		flash_range = min (MAX_EX_FLASH_RANGE, flash_range)
		flame_range = min (MAX_EX_FLAME_RANGE, flame_range)

	spawn(0)
		var/watch = start_watch()
		if(!epicenter) return

		var/max_range = max(devastation_range, heavy_impact_range, light_impact_range, flame_range)
		var/list/cached_exp_block = list()

		if(adminlog)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in area [epicenter.loc.name] [cause ? "(Cause: [cause])" : ""] [ADMIN_COORDJMP(epicenter)] ")
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in area [epicenter.loc.name] [cause ? "(Cause: [cause])" : ""] [COORD(epicenter)] ")

		// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
		// Stereo users will also hear the direction of the explosion!

		// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
		// 3/7/14 will calculate to 80 + 35

		var/far_dist = 0
		far_dist += heavy_impact_range * 5
		far_dist += devastation_range * 20

		if(!silent)
			var/frequency = get_rand_frequency()
			var/sound/explosion_sound = sound(get_sfx("explosion"))
			var/sound/global_boom = sound('sound/effects/explosionfar.ogg')

			for(var/P in GLOB.player_list)
				var/mob/M = P
				// Double check for client
				if(M && M.client)
					var/turf/M_turf = get_turf(M)
					if(M_turf && M_turf.z == epicenter.z)
						var/dist = get_dist(M_turf, epicenter)
						// If inside the blast radius + world.view - 2
						if(dist <= round(max_range + world.view - 2, 1))
							M.playsound_local(epicenter, null, 100, 1, frequency, falloff = 5, S = explosion_sound)
						// You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.
						else if(M.can_hear() && !isspaceturf(M.loc))
							M << global_boom

		if(heavy_impact_range > 1)
			if(smoke)
				var/datum/effect_system/explosion/smoke/E = new/datum/effect_system/explosion/smoke()
				E.set_up(epicenter)
				E.start()
			else
				var/datum/effect_system/explosion/E = new/datum/effect_system/explosion()
				E.set_up(epicenter)
				E.start()

		var/x0 = epicenter.x
		var/y0 = epicenter.y
		var/z0 = epicenter.z

		var/list/affected_turfs = spiral_range_turfs(max_range, epicenter)

		if(config.reactionary_explosions)
			for(var/A in affected_turfs) // we cache the explosion block rating of every turf in the explosion area
				var/turf/T = A
				cached_exp_block[T] = 0
				if(T.density && T.explosion_block)
					cached_exp_block[T] += T.explosion_block

				for(var/obj/O in T)
					var/the_block = O.explosion_block
					cached_exp_block[T] += the_block == EXPLOSION_BLOCK_PROC ? O.GetExplosionBlock() : the_block
				CHECK_TICK

		for(var/A in affected_turfs)
			var/turf/T = A
			if(!T)
				continue
			var/dist = hypotenuse(T.x, T.y, x0, y0)

			if(config.reactionary_explosions)
				var/turf/Trajectory = T
				while(Trajectory != epicenter)
					Trajectory = get_step_towards(Trajectory, epicenter)
					dist += cached_exp_block[Trajectory]

			var/flame_dist = 0
//			var/throw_dist = max_range - dist

			if(dist < flame_range)
				flame_dist = 1

			if(dist < devastation_range)		dist = 1
			else if(dist < heavy_impact_range)	dist = 2
			else if(dist < light_impact_range)	dist = 3
			else 								dist = 0

			//------- TURF FIRES -------

			if(T)
				if(flame_dist && prob(40) && !istype(T, /turf/space) && !T.density)
					new /obj/effect/hotspot(T) //Mostly for ambience!
				if(dist > 0)
					if(istype(T, /turf/simulated))
						var/turf/simulated/S = T
						var/affecting_level
						if(dist == 1)
							affecting_level = 1
						else
							affecting_level = S.is_shielded() ? 2 : (S.intact ? 2 : 1)
						for(var/atom in S.contents)	//bypass type checking since only atom can be contained by turfs anyway
							var/atom/AM = atom
							if(AM && AM.simulated)
								if(AM.level >= affecting_level)
									AM.ex_act(dist)
					else
						for(var/atom in T.contents)	//see above
							var/atom/AM = atom
							if(AM && AM.simulated)
								AM.ex_act(dist)
							CHECK_TICK
					if(breach)
						T.ex_act(dist)
					else
						T.ex_act(3)

			CHECK_TICK
			//--- THROW ITEMS AROUND ---
/*
			if(throw_dist > 0)
				var/throw_dir = get_dir(epicenter,T)
				for(var/obj/item/I in T)
					spawn(0) //Simultaneously not one at a time
						if(I && !I.anchored)
							var/throw_mult = 0.5 + (0.5 * rand()) // Between 0.5 and 1.0
							var/throw_range = round((throw_dist + 1) * throw_mult) // Roughly 50% to 100% of throw_dist
							if(throw_range > 0)
								var/turf/throw_at = get_ranged_target_turf(I, throw_dir, throw_range)
								I.throw_at(throw_at, throw_range, 2, no_spin = 1) //Throw it at 2 speed, this is purely visual anyway; don't spin the thrown items, it's very costly.
*/
		var/took = stop_watch(watch)
		//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes  to explosion code using this please so we can compare
		if(Debug2)
			log_world("## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds.")

		//Machines which report explosions.
		for(var/i,i<=doppler_arrays.len,i++)
			var/obj/machinery/doppler_array/Array = doppler_arrays[i]
			if(Array)
				Array.sense_explosion(x0,y0,z0,devastation_range,heavy_impact_range,light_impact_range,took,orig_dev_range,orig_heavy_range,orig_light_range)

	return 1



/proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in spiral_range_turfs(range, epicenter))
		tile.ex_act(2)

/client/proc/check_bomb_impacts()
	set name = "Check Bomb Impact"
	set category = "Debug"

	var/newmode = alert("Use reactionary explosions?","Check Bomb Impact", "Yes", "No")
	var/turf/epicenter = get_turf(mob)
	if(!epicenter)
		return

	var/dev = 0
	var/heavy = 0
	var/light = 0
	var/list/choices = list("Small Bomb","Medium Bomb","Big Bomb","Custom Bomb")
	var/choice = input("Bomb Size?") in choices
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			dev = 1
			heavy = 2
			light = 3
		if("Medium Bomb")
			dev = 2
			heavy = 3
			light = 4
		if("Big Bomb")
			dev = 3
			heavy = 5
			light = 7
		if("Custom Bomb")
			dev = input("Devestation range (Tiles):") as num
			heavy = input("Heavy impact range (Tiles):") as num
			light = input("Light impact range (Tiles):") as num

	var/max_range = max(dev, heavy, light)
	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/list/wipe_colours = list()
	for(var/turf/T in spiral_range_turfs(max_range, epicenter))
		wipe_colours += T
		var/dist = hypotenuse(T.x, T.y, x0, y0)

		if(newmode == "Yes")
			var/turf/TT = T
			while(TT != epicenter)
				TT = get_step_towards(TT,epicenter)
				if(TT.density)
					dist += TT.explosion_block

				for(var/obj/O in T)
					var/the_block = O.explosion_block
					dist += the_block == EXPLOSION_BLOCK_PROC ? O.GetExplosionBlock() : the_block

		if(dist < dev)
			T.color = "red"
			T.maptext = "Dev"
		else if(dist < heavy)
			T.color = "yellow"
			T.maptext = "Heavy"
		else if(dist < light)
			T.color = "blue"
			T.maptext = "Light"
		else
			continue

	sleep(100)
	for(var/turf/T in wipe_colours)
		T.color = null
		T.maptext = ""
