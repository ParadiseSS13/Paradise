/datum/controller/subsystem/mapping/Initialize()
	. = ..()
	// Pick a random away mission.
	if(GLOB.configuration.gateway.enable_away_mission)
		load_away_mission()
	else
		log_startup_progress("Skipping away mission...")

/datum/controller/subsystem/mapping/proc/load_away_mission()
	if(!length(GLOB.configuration.gateway.enabled_away_missions))
		log_startup_progress("No away missions found.")
		return

	var/watch = start_watch()
	log_startup_progress("Loading away mission...")

	var/map = pick(GLOB.configuration.gateway.enabled_away_missions)
	var/file = wrap_file(map)
	if(!isfile(file))
		log_startup_progress("Picked away mission doesnt exist.")
		return

	var/zlev = GLOB.space_manager.add_new_zlevel(AWAY_MISSION, linkage = UNAFFECTED, traits = list(AWAY_LEVEL, BLOCK_TELEPORT))
	GLOB.space_manager.add_dirt(zlev)
	GLOB.maploader.load_map(file, z_offset = zlev)
	var/datum/milla_safe/late_setup_level/milla = new()
	milla.invoke_async(block(locate(1, 1, zlev), locate(world.maxx, world.maxy, zlev)))
	GLOB.space_manager.remove_dirt(zlev)
	log_world("Away mission loaded: [map]")

	log_startup_progress("Away mission loaded in [stop_watch(watch)]s.")
