// This used to be part of the blob gamemode files. Why.
/datum/station_state
	/// Amount of floors
	var/floor = 0
	/// Amount of regular walls
	var/wall = 0
	/// Amount of reinforced walles
	var/r_wall = 0
	/// Amount of full windows
	var/window = 0
	/// Amount of airlocks
	var/door = 0
	/// Amount of grilles (without windows)
	var/grille = 0
	/// Amount of machines
	var/mach = 0

/datum/station_state/proc/count()
	var/watch = start_watch()
	log_debug("Counting station atoms")
	var/station_zlevel = level_name_to_num(MAIN_STATION)
	for(var/turf/T in block(1, 1, station_zlevel, world.maxx, world.maxy, station_zlevel))

		if(istype(T, /turf/simulated/floor))
			var/turf/simulated/floor/T2 = T
			if(!(T2.burnt))
				floor += 12
			else
				floor += 1

		if(istype(T, /turf/simulated/wall))
			var/turf/simulated/wall/W = T
			if(W.intact)
				wall += 2
			else
				wall += 1

		if(istype(T, /turf/simulated/wall/r_wall))
			var/turf/simulated/wall/r_wall/R = T
			if(R.intact)
				r_wall += 2
			else
				r_wall += 1


		for(var/obj/O in T.contents)
			if(istype(O, /obj/structure/window))
				window += 1

			else if(istype(O, /obj/structure/grille))
				var/obj/structure/grille/GR = O
				if(!GR.broken)
					grille += 1

			else if(isairlock(O))
				door += 1

			else if(istype(O, /obj/machinery))
				mach += 1

	log_debug("Counted station atoms in [stop_watch(watch)]s")

/datum/station_state/proc/score(datum/station_state/result)
	if(!result)
		return 0

	var/output = 0

	output += (result.floor / max(floor, 1))
	output += (result.r_wall/ max(r_wall, 1))
	output += (result.wall / max(wall, 1))
	output += (result.window / max(window, 1))
	output += (result.door / max(door, 1))
	output += (result.grille / max(grille, 1))
	output += (result.mach / max(mach, 1))

	return (output/7)
