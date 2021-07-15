/datum/event/wallrot/start()
	INVOKE_ASYNC(src, .proc/spawn_wallrot)

/datum/event/wallrot/proc/spawn_wallrot()
	var/turf/simulated/wall/center = null

	// 100 attempts
	for(var/i in 0 to 100)
		var/turf/candidate = locate(rand(1, world.maxx), rand(1, world.maxy), level_name_to_num(MAIN_STATION))
		if(istype(candidate, /turf/simulated/wall))
			center = candidate
			break

	if(!center)
		return
	// Make sure at least one piece of wall rots!
	center.rot()

	// Have a chance to rot lots of other walls.
	var/rotcount = 0
	var/actual_severity = severity * rand(5, 10)
	for(var/turf/simulated/wall/W in range(5, center))
		if(prob(50))
			W.rot()
			rotcount++

			// Only rot up to severity walls
			if(rotcount >= actual_severity)
				break
