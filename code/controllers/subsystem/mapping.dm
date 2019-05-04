SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = INIT_ORDER_MAPPING // 9
	flags = SS_NO_FIRE
	var/list/potentialRandomZlevels = list()

/datum/controller/subsystem/mapping/Initialize(timeofday)
	// Make the map list
	potentialRandomZlevels = generateMapList(filename = "config/away_mission_config.txt")
	// Load all Z level templates
	preloadTemplates()
	// Pick a random away mission.
	if(!config.disable_away_missions)
		createRandomZlevel()
	// Seed space ruins
	if(!config.disable_space_ruins)
		var/timer = start_watch()
		log_startup_progress("Creating random space levels...")
		seedRuins(level_name_to_num(EMPTY_AREA), rand(0, 3), /area/space, space_ruins_templates)
		log_startup_progress("Loaded random space levels in [stop_watch(timer)]s.")

		// load in extra levels of space ruins

		var/num_extra_space = rand(config.extra_space_ruin_levels_min, config.extra_space_ruin_levels_max)
		for(var/i = 1, i <= num_extra_space, i++)
			var/zlev = space_manager.add_new_zlevel("[EMPTY_AREA] #[i]", linkage = CROSSLINKED)
			seedRuins(zlev, rand(0, 3), /area/space, space_ruins_templates)

	// Setup the Z-level linkage
	space_manager.do_transition_setup()
	// Populate mining Z-level hidden rooms
	for(var/i=0, i<max_secret_rooms, i++)
		make_mining_asteroid_secret()
	return ..()

// Call this before you remove the last dirt on a z level - that way, all objects
// will have proper atmos and other important enviro things
/datum/controller/subsystem/mapping/proc/late_setup_level(turfs, smoothTurfs)
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
		if(istype(T, /turf/simulated/mineral)) // For the listening post, among other maps
			var/turf/simulated/mineral/MT = T
			MT.add_edges()
	log_debug("\tTook [stop_watch(subtimer)]s")
	log_debug("Late setup finished - took [stop_watch(total_timer)]s")

// Tells a region to empty itself
/datum/controller/subsystem/mapping/proc/empty_rect(low_x,low_y, hi_x,hi_y, z)
	var/timer = start_watch()
	log_debug("Emptying region: ([low_x], [low_y]) to ([hi_x], [hi_y]) on z '[z]'")
	empty_region(block(locate(low_x, low_y, z), locate(hi_x, hi_y, z)))
	log_debug("Took [stop_watch(timer)]s")

// Empties a specified region
/datum/controller/subsystem/mapping/proc/empty_region(list/turfs)
	for(var/thing in turfs)
		var/turf/T = thing
		for(var/otherthing in T)
			qdel(otherthing)
		T.ChangeTurf(/turf/space)

// Create ONE away mission
/datum/controller/subsystem/mapping/proc/createRandomZlevel()
	if(awaydestinations.len)	//crude, but it saves another var!
		return

	if(potentialRandomZlevels && potentialRandomZlevels.len)
		var/watch = start_watch()
		log_startup_progress("Loading away mission...")

		var/map = pick(potentialRandomZlevels)
		var/file = file(map)
		if(isfile(file))
			var/zlev = space_manager.add_new_zlevel(AWAY_MISSION, linkage = UNAFFECTED, traits = list(AWAY_LEVEL,BLOCK_TELEPORT))
			space_manager.add_dirt(zlev)
			maploader.load_map(file, z_offset = zlev)
			late_setup_level(block(locate(1, 1, zlev), locate(world.maxx, world.maxy, zlev)))
			space_manager.remove_dirt(zlev)
			log_world("  Away mission loaded: [map]")

		for(var/obj/effect/landmark/L in GLOB.landmarks_list)
			if(L.name != "awaystart")
				continue
			awaydestinations.Add(L)

		log_startup_progress("  Away mission loaded in [stop_watch(watch)]s.")

	else
		log_startup_progress("  No away missions found.")
		return

// Make ALL gateway Z levels. Dont do this for the love of god why
/datum/controller/subsystem/mapping/proc/createALLZlevels()
	if(awaydestinations.len)	//crude, but it saves another var!
		return

	if(potentialRandomZlevels && potentialRandomZlevels.len)
		var/watch = start_watch()
		log_startup_progress("Loading away missions...")

		for(var/map in potentialRandomZlevels)
			var/file = file(map)
			if(isfile(file))
				log_startup_progress("Loading away mission: [map]")
				var/zlev = space_manager.add_new_zlevel()
				space_manager.add_dirt(zlev)
				maploader.load_map(file, z_offset = zlev)
				late_setup_level(block(locate(1, 1, zlev), locate(world.maxx, world.maxy, zlev)))
				space_manager.remove_dirt(zlev)
				log_world("  Away mission loaded: [map]")

			//map_transition_config.Add(AWAY_MISSION_LIST)

			for(var/obj/effect/landmark/L in GLOB.landmarks_list)
				if(L.name != "awaystart")
					continue
				awaydestinations.Add(L)

			log_startup_progress("  Away mission loaded in [stop_watch(watch)]s.")
			watch = start_watch()

	else
		log_startup_progress("  No away missions found.")
		return

// Makes a list of maps from a file
/datum/controller/subsystem/mapping/proc/generateMapList(filename)
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

// Puts ruins in space
/datum/controller/subsystem/mapping/proc/seedRuins(z_level = 1, budget = 0, whitelist = /area/space, list/potentialRuins = space_ruins_templates)
	var/overall_sanity = 100
	var/ruins = potentialRuins.Copy()
	var/initialbudget = budget
	var/watch = start_watch()

	while(budget > 0 && overall_sanity > 0)
		// Pick a ruin
		var/datum/map_template/ruin/ruin = ruins[pick(ruins)]
		// Can we afford it
		if(ruin.cost > budget)
			overall_sanity--
			continue
		// If so, try to place it
		var/sanity = 100
		// And if we can't fit it anywhere, give up, try again

		while(sanity > 0)
			sanity--
			// 8: 7 is the normal view distance of a client, +1 so that ruins don't suddenly appear
			var/turf/T = locate(rand(TRANSITION_BORDER_WEST + (8 + ruin.width/2), TRANSITION_BORDER_EAST - (8 + ruin.width/2)), rand(TRANSITION_BORDER_SOUTH + (8 + ruin.height/2), TRANSITION_BORDER_NORTH - (8 + ruin.height/2)), z_level)
			var/valid = 1

			for(var/turf/check in ruin.get_affected_turfs(T,1))
				var/area/new_area = get_area(check)
				if(!(istype(new_area, whitelist)))
					valid = 0
					break

			if(!valid)
				continue

			log_world("  Ruin \"[ruin.name]\" loaded in [stop_watch(watch)]s at ([T.x], [T.y], [T.z]).")

			var/obj/effect/ruin_loader/R = new /obj/effect/ruin_loader(T)
			R.Load(ruins,ruin)
			budget -= ruin.cost
			if(!ruin.allow_duplicates)
				ruins -= ruin.name
			break


	if(initialbudget == budget) //Kill me
		log_world("  No ruins loaded.")


/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT