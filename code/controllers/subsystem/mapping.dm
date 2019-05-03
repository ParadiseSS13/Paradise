SUBSYSTEM_DEF(mapping)
   	name = "Mapping"
   	init_order = INIT_ORDER_MAPPING // 9
   	flags = SS_NO_FIRE
   	var/list/teleportlocs = list()
   	var/list/ghostteleportlocs = list()


/datum/controller/subsystem/mapping/Initialize(timeofday)
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
	// This is all stuff from garbage that used to be known as hooks
	for(var/area/AR in world)
		if(AR.no_teleportlocs) continue
		if(teleportlocs.Find(AR.name)) continue
		var/turf/picked = safepick(get_area_turfs(AR.type))
		if(picked && is_station_level(picked.z))
			teleportlocs += AR.name
			teleportlocs[AR.name] = AR
	teleportlocs = sortAssoc(teleportlocs)

	for(var/area/AR in world)
		if(ghostteleportlocs.Find(AR.name)) continue
		var/list/turfs = get_area_turfs(AR.type)
		if(turfs.len)
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR
	ghostteleportlocs = sortAssoc(ghostteleportlocs)
	
	return ..()

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT