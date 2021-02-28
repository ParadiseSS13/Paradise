//TODO: Flash range does nothing currently

#define CREAK_DELAY 5 SECONDS //Time taken for the creak to play after explosion, if applicable.
#define DEVASTATION_PROB 30 //The probability modifier for devistation, maths!
#define HEAVY_IMPACT_PROB 5 //ditto
#define FAR_UPPER 60 //Upper limit for the far_volume, distance, clamped.
#define FAR_LOWER 40 //lower limit for the far_volume, distance, clamped.
#define PROB_SOUND 75 //The probability modifier for a sound to be an echo, or a far sound. (0-100)
#define SHAKE_CLAMP 2.5 //The limit for how much the camera can shake for out of view booms.
#define FREQ_UPPER 40 //The upper limit for the randomly selected frequency.
#define FREQ_LOWER 25 //The lower of the above.

/proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1, ignorecap = 0, flame_range = 0, silent = 0, smoke = 1, cause = null, breach = TRUE)
	epicenter = get_turf(epicenter)
	if(!epicenter)
		return

	// Archive the uncapped explosion for the doppler array
	var/orig_dev_range = devastation_range
	var/orig_heavy_range = heavy_impact_range
	var/orig_light_range = light_impact_range

	var/orig_max_distance = max(devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range)

	if(!ignorecap)
		// Clamp all values to MAX_EXPLOSION_RANGE
		devastation_range = min (GLOB.max_ex_devastation_range, devastation_range)
		heavy_impact_range = min (GLOB.max_ex_heavy_range, heavy_impact_range)
		light_impact_range = min (GLOB.max_ex_light_range, light_impact_range)
		flash_range = min (GLOB.max_ex_flash_range, flash_range)
		flame_range = min (GLOB.max_ex_flame_range, flame_range)

	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range, flame_range)

	spawn(0)
		var/watch = start_watch()

		var/list/cached_exp_block = list()

		if(adminlog)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in area [epicenter.loc.name] [cause ? "(Cause: [cause])" : ""] [ADMIN_COORDJMP(epicenter)] ")
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in area [epicenter.loc.name] [cause ? "(Cause: [cause])" : ""] [COORD(epicenter)] ")

		var/x0 = epicenter.x
		var/y0 = epicenter.y
		var/z0 = epicenter.z

		// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
		// Stereo users will also hear the direction of the explosion!

		// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
		// 3/7/14 will calculate to 80 + 35

		var/far_dist = 0
		far_dist += heavy_impact_range * 15
		far_dist += devastation_range * 20

		if(!silent)
			var/frequency = get_rand_frequency()
			var/sound/explosion_sound = sound(get_sfx("explosion"))
			var/sound/far_explosion_sound = sound('sound/effects/explosionfar.ogg')
			var/sound/creaking_explosion_sound = sound(get_sfx("explosion_creaking"))
			var/sound/hull_creaking_sound = sound(get_sfx("hull_creaking"))
			var/sound/explosion_echo_sound = sound('sound/effects/explosion_distant.ogg')
			var/on_station = is_station_level(epicenter.z)
			var/creaking_explosion = FALSE

			if(prob(devastation_range * DEVASTATION_PROB + heavy_impact_range * HEAVY_IMPACT_PROB) && on_station) // Huge explosions are near guaranteed to make the station creak and whine, smaller ones might.
				creaking_explosion = TRUE // prob over 100 always returns true

			for(var/MN in GLOB.player_list)
				var/mob/M = MN
				// Double check for client
				var/turf/M_turf = get_turf(M)
				if(M_turf && M_turf.z == z0)
					var/dist = get_dist(M_turf, epicenter)
					var/baseshakeamount
					if(orig_max_distance - dist > 0)
						baseshakeamount = sqrt((orig_max_distance - dist) * 0.1)
					// If inside the blast radius + world.view - 2
					if(dist <= round(max_range + world.view - 2, 1))
						M.playsound_local(epicenter, null, 100, 1, frequency, S = explosion_sound)
						if(baseshakeamount > 0)
							shake_camera(M, 25, clamp(baseshakeamount, 0, 10))
					// You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.
					else if(dist <= far_dist)
						var/far_volume = clamp(far_dist / 2, FAR_LOWER, FAR_UPPER) // Volume is based on explosion size and dist
						if(creaking_explosion)
							M.playsound_local(epicenter, null, far_volume, 1, frequency, S = creaking_explosion_sound, distance_multiplier = 0)
						else if(prob(PROB_SOUND)) // Sound variety during meteor storm/tesloose/other bad event
							M.playsound_local(epicenter, null, far_volume, 1, frequency, S = far_explosion_sound, distance_multiplier = 0) // Far sound
						else
							M.playsound_local(epicenter, null, far_volume, 1, frequency, S = explosion_echo_sound, distance_multiplier = 0) // Echo sound

						if(baseshakeamount > 0 || devastation_range)
							if(!baseshakeamount) // Devastating explosions rock the station and ground
								baseshakeamount = devastation_range * 3
							shake_camera(M, 10, clamp(baseshakeamount * 0.25, 0, SHAKE_CLAMP))
					else if(!isspaceturf(get_turf(M)) && heavy_impact_range) // Big enough explosions echo throughout the hull
						var/echo_volume = 40
						if(devastation_range)
							baseshakeamount = devastation_range
							shake_camera(M, 10, clamp(baseshakeamount * 0.25, 0, SHAKE_CLAMP))
							echo_volume = 60
						M.playsound_local(epicenter, null, echo_volume, 1, frequency, S = explosion_echo_sound, distance_multiplier = 0)

					if(creaking_explosion) // 5 seconds after the bang, the station begins to creak
						addtimer(CALLBACK(M, /mob/proc/playsound_local, epicenter, null, rand(FREQ_LOWER, FREQ_UPPER), 1, frequency, null, null, FALSE, hull_creaking_sound, 0), CREAK_DELAY)

		if(heavy_impact_range > 1)
			var/datum/effect_system/explosion/E
			if(smoke)
				E = new /datum/effect_system/explosion/smoke
			else
				E = new
			E.set_up(epicenter)
			E.start()

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
			var/dist = HYPOTENUSE(T.x, T.y, x0, y0)

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
							if(!QDELETED(AM) && AM.simulated)
								if(AM.level >= affecting_level)
									AM.ex_act(dist)
					else
						for(var/atom in T.contents)	//see above
							var/atom/AM = atom
							if(!QDELETED(AM) && AM.simulated)
								AM.ex_act(dist)
							CHECK_TICK
					if(breach)
						T.ex_act(dist)
					else
						T.ex_act(3)

			CHECK_TICK

		var/took = stop_watch(watch)
		//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes  to explosion code using this please so we can compare
		if(GLOB.debug2)
			log_world("## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds.")

		//Machines which report explosions.
		for(var/i,i<=GLOB.doppler_arrays.len,i++)
			var/obj/machinery/doppler_array/Array = GLOB.doppler_arrays[i]
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
		var/dist = HYPOTENUSE(T.x, T.y, x0, y0)

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

#undef CREAK_DELAY
#undef DEVASTATION_PROB
#undef HEAVY_IMPACT_PROB
#undef FAR_UPPER
#undef FAR_LOWER
#undef PROB_SOUND
#undef SHAKE_CLAMP
#undef FREQ_UPPER
#undef FREQ_LOWER
