var/global/list/potentialRandomZlevels = generateMapList(filename = "config/away_mission_config.txt")

// Call this before you remove the last dirt on a z level - that way, all objects
// will have proper atmos and other important enviro things
/proc/late_setup_level(turfs, smoothTurfs)
	var/total_timer = start_watch()
	var/subtimer = start_watch()
	if(!smoothTurfs)
		smoothTurfs = turfs

	log_debug("Setting up atmos")
	if(air_master)
		air_master.setup_allturfs(turfs)
	log_debug("\tTook [stop_watch(subtimer)]s")

	subtimer = start_watch()
	log_debug("Initializing lighting")
	for(var/turf/T in turfs)
		if(T.dynamic_lighting)
			T.lighting_build_overlays()
	log_debug("\tTook [stop_watch(subtimer)]s")

	subtimer = start_watch()
	log_debug("Smoothing tiles")
	for(var/turf/T in smoothTurfs)
		if(T.smooth)
			smooth_icon(T)
		for(var/R in T)
			var/atom/A = R
			if(A.smooth)
				smooth_icon(A)
		if(istype(T, /turf/simulated/mineral)) // For the listening post, among other maps
			var/turf/simulated/mineral/MT = T
			MT.add_edges()
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
		T.ChangeTurf(/turf/space)

/proc/createRandomZlevel()
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
			log_to_dd("  Away mission loaded: [map]")

		for(var/obj/effect/landmark/L in landmarks_list)
			if(L.name != "awaystart")
				continue
			awaydestinations.Add(L)

		log_startup_progress("  Away mission loaded in [stop_watch(watch)]s.")

	else
		log_startup_progress("  No away missions found.")
		return

/proc/createALLZlevels()
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
				log_to_dd("  Away mission loaded: [map]")

			//map_transition_config.Add(AWAY_MISSION_LIST)

			for(var/obj/effect/landmark/L in landmarks_list)
				if(L.name != "awaystart")
					continue
				awaydestinations.Add(L)

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


/proc/seedRuins(z_level = 1, budget = 0, whitelist = /area/space, list/potentialRuins = space_ruins_templates)
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
			var/turf/T = locate(rand(25, world.maxx - 25), rand(25, world.maxy - 25), z_level)
			var/valid = 1

			for(var/turf/check in ruin.get_affected_turfs(T,1))
				var/area/new_area = get_area(check)
				if(!(istype(new_area, whitelist)))
					valid = 0
					break

			if(!valid)
				continue

			log_to_dd("  Ruin \"[ruin.name]\" loaded in [stop_watch(watch)]s at ([T.x], [T.y], [T.z]).")

			var/obj/effect/ruin_loader/R = new /obj/effect/ruin_loader(T)
			R.Load(ruins,ruin)
			budget -= ruin.cost
			if(!ruin.allow_duplicates)
				ruins -= ruin.name
			break


	if(initialbudget == budget) //Kill me
		log_to_dd("  No ruins loaded.")


/obj/effect/ruin_loader
	name = "random ruin"
	desc = "If you got lucky enough to see this..."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	invisibility = 0

/obj/effect/ruin_loader/proc/Load(list/potentialRuins = space_ruins_templates, datum/map_template/template = null)
	var/list/possible_ruins = list()
	for(var/A in potentialRuins)
		var/datum/map_template/T = potentialRuins[A]
		if(!T.loaded)
			possible_ruins += T
	if(!template && possible_ruins.len)
		template = safepick(possible_ruins)
	if(!template)
		return 0
	template.load(get_turf(src),centered = 1)
	template.loaded++
	qdel(src)
	return 1
