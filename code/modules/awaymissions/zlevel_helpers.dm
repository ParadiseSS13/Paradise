/datum/milla_safe/late_setup_level

// Ensures that atmos and environment are set up.
/datum/milla_safe/late_setup_level/on_run(turfs, smoothTurfs)
	var/total_timer = start_watch()
	var/subtimer = start_watch()
	if(!smoothTurfs)
		smoothTurfs = turfs

	log_debug("Setting up atmos")
	/* setup_allturfs is superfluous during server initialization because
	 * air subsystem will call subsequently call setup_allturfs with _every_
	 * turf in the world */
	if(SSair && SSair.initialized)
		SSair.setup_allturfs_sleepless(turfs)
	log_debug("\tTook [stop_watch(subtimer)]s")

	subtimer = start_watch()
	log_debug("Smoothing tiles")
	for(var/turf/T in smoothTurfs)
		if(T.smoothing_flags)
			QUEUE_SMOOTH(T)
		for(var/R in T)
			var/atom/A = R
			if(A.smoothing_flags)
				QUEUE_SMOOTH(A)
	log_debug("\tTook [stop_watch(subtimer)]s")
	log_debug("Late setup finished - took [stop_watch(total_timer)]s")

/proc/empty_rect(low_x,low_y, hi_x,hi_y, z)
	var/timer = start_watch()
	log_debug("Emptying region: ([low_x], [low_y]) to ([hi_x], [hi_y]) on z '[z]'")
	empty_region(block(low_x, low_y, z, hi_x, hi_y, z))
	log_debug("Took [stop_watch(timer)]s")

/proc/empty_region(list/turfs)
	for(var/thing in turfs)
		var/turf/T = thing
		for(var/otherthing in T)
			qdel(otherthing)
		T.ChangeTurf(T.baseturf)

/datum/map_template/ruin/proc/try_to_place(z,allowed_areas)
	var/sanity = PLACEMENT_TRIES
	while(sanity > 0)
		sanity--
		var/width_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(width / 2)
		var/height_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(height / 2)
		var/turf/central_turf = locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), z)
		var/valid = TRUE

		for(var/turf/check in get_affected_turfs(central_turf,1))
			var/area/new_area = get_area(check)
			if(!(istype(new_area, allowed_areas)) || check.flags & NO_RUINS)
				valid = FALSE
				break

		if(!valid)
			continue

		log_world("Ruin \"[name]\" placed at ([central_turf.x], [central_turf.y], [central_turf.z])")

		for(var/i in get_affected_turfs(central_turf, 1))
			var/turf/T = i
			for(var/obj/structure/spawner/nest in T)
				qdel(nest)
			for(var/mob/living/simple_animal/monster in T)
				qdel(monster)
			for(var/obj/structure/flora/ash/plant in T)
				qdel(plant)

		load(central_turf,centered = TRUE)
		loaded++

		for(var/turf/T in get_affected_turfs(central_turf, 1))
			T.flags |= NO_RUINS

		new /obj/effect/landmark/ruin(central_turf, src)

		var/map_filename = splittext(mappath, "/")
		map_filename = map_filename[length(map_filename)]
		SSblackbox.record_feedback("associative", "ruin_placement", 1, list(
			"map" = map_filename,
			"coords" = "[central_turf.x],[central_turf.y],[central_turf.z]"
		))

		return TRUE
	return FALSE
