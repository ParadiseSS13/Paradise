/datum/event/wallrot
	name = "Wallrot"
	role_weights = list(ASSIGNMENT_ENGINEERING = 5)
	role_requirements = list(ASSIGNMENT_ENGINEERING = 1)

/datum/event/wallrot/start()
	INVOKE_ASYNC(src, PROC_REF(spawn_wallrot))

/datum/event/wallrot/proc/apply_to_turf(turf/T)
	var/turf/simulated/wall/W = T
	W.rot()

/datum/event/wallrot/proc/is_valid_candidate(turf/T)
	return TRUE

/datum/event/wallrot/proc/spawn_wallrot()
	var/turf/simulated/wall/center = null

	// 100 attempts
	for(var/i in 0 to 100)
		var/turf/candidate = locate(rand(1, world.maxx), rand(1, world.maxy), level_name_to_num(MAIN_STATION))
		if(iswallturf(candidate) && is_valid_candidate(candidate))
			center = candidate
			break

	if(!center)
		return
	// Make sure at least one piece of wall rots!
	apply_to_turf(center)

	// Have a chance to rot lots of other walls.
	var/rotcount = 0
	var/actual_severity = severity * rand(5, 10)
	for(var/turf/simulated/wall/W in range(5, center))
		if(prob(50))
			apply_to_turf(W)
			rotcount++

			// Only rot up to severity walls
			if(rotcount >= actual_severity)
				break

/datum/event/wallrot/fungus
	name = "Fungal Growth"
	role_weights = list(ASSIGNMENT_CHEMIST = 5)
	role_requirements = list(ASSIGNMENT_CHEMIST = 0)

/datum/event/wallrot/fungus/is_valid_candidate(turf/T)
	return istype(get_area(T), /area/station/maintenance)

/datum/event/wallrot/fungus/apply_to_turf(turf/T)
	new /obj/effect/decal/cleanable/fungus(T)
