GLOBAL_LIST_INIT(potentialRandomZlevels, generateMapList(filename = "config/away_mission_config.txt"))

// Call this before you remove the last dirt on a z level - that way, all objects
// will have proper atmos and other important enviro things
/proc/late_setup_level(turfs, smoothTurfs)
	var/total_timer = start_watch()
	var/subtimer = start_watch()
	if(!smoothTurfs)
		smoothTurfs = turfs

	log_debug("Setting up atmos")
	if(SSair)
		SSair.setup_allturfs(turfs)
	log_debug("\tTook [stop_watch(subtimer)]s")

	subtimer = start_watch()
	log_debug("Smoothing tiles")
	for(var/turf/T in smoothTurfs)
		if(T.smooth)
			queue_smooth(T)
		for(var/R in T)
			var/atom/A = R
			if(A.smooth)
				queue_smooth(A)
	log_debug("\tTook [stop_watch(subtimer)]s")
	log_debug("Late setup finished - took [stop_watch(total_timer)]s")

/proc/empty_rect(low_x,low_y, hi_x,hi_y, z)
	var/timer = start_watch()
	log_debug("Emptying region: ([low_x], [low_y]) to ([hi_x], [hi_y]) on z '[z]'")
	empty_region(block(locate(low_x, low_y, z), locate(hi_x, hi_y, z)))
	log_debug("Took [stop_watch(timer)]s")

/proc/empty_region(list/turfs)
	for(var/thing in turfs)
		var/turf/T = thing
		for(var/otherthing in T)
			qdel(otherthing)
		T.ChangeTurf(T.baseturf)

/proc/createRandomZlevel()
	if(GLOB.awaydestinations.len)	//crude, but it saves another var!
		return

	if(GLOB.potentialRandomZlevels && GLOB.potentialRandomZlevels.len)
		var/watch = start_watch()
		log_startup_progress("Loading away mission...")

		var/map = pick(GLOB.potentialRandomZlevels)
		var/file = wrap_file(map)
		if(isfile(file))
			var/zlev = GLOB.space_manager.add_new_zlevel(AWAY_MISSION, linkage = UNAFFECTED, traits = list(AWAY_LEVEL,BLOCK_TELEPORT))
			GLOB.space_manager.add_dirt(zlev)
			GLOB.maploader.load_map(file, z_offset = zlev)
			late_setup_level(block(locate(1, 1, zlev), locate(world.maxx, world.maxy, zlev)))
			GLOB.space_manager.remove_dirt(zlev)
			log_world("  Away mission loaded: [map]")

		for(var/thing in GLOB.landmarks_list)
			var/obj/effect/landmark/L = thing
			if(L.name != "awaystart")
				continue
			GLOB.awaydestinations.Add(L)

		log_startup_progress("  Away mission loaded in [stop_watch(watch)]s.")

	else
		log_startup_progress("  No away missions found.")
		return


/proc/createALLZlevels()
	if(GLOB.awaydestinations.len)	//crude, but it saves another var!
		return

	if(GLOB.potentialRandomZlevels && GLOB.potentialRandomZlevels.len)
		var/watch = start_watch()
		log_startup_progress("Loading away missions...")

		for(var/map in GLOB.potentialRandomZlevels)
			var/file = wrap_file(map)
			if(isfile(file))
				log_startup_progress("Loading away mission: [map]")
				var/zlev = GLOB.space_manager.add_new_zlevel()
				GLOB.space_manager.add_dirt(zlev)
				GLOB.maploader.load_map(file, z_offset = zlev)
				late_setup_level(block(locate(1, 1, zlev), locate(world.maxx, world.maxy, zlev)))
				GLOB.space_manager.remove_dirt(zlev)
				log_world("  Away mission loaded: [map]")

			//map_transition_config.Add(AWAY_MISSION_LIST)

			for(var/thing in GLOB.landmarks_list)
				var/obj/effect/landmark/L = thing
				if(L.name != "awaystart")
					continue
				GLOB.awaydestinations.Add(L)

			log_startup_progress("  Away mission loaded in [stop_watch(watch)]s.")
			watch = start_watch()

	else
		log_startup_progress("  No away missions found.")
		return

/proc/generateMapList(filename)
	var/list/potentialMaps = list()
	var/list/Lines = file2list(filename)

	if(!Lines.len)
		return
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null

		if(pos)
			name = lowertext(copytext(t, 1, pos))

		else
			name = lowertext(t)

		if(!name)
			continue

		potentialMaps.Add(t)

	return potentialMaps


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
		return TRUE
	return FALSE
