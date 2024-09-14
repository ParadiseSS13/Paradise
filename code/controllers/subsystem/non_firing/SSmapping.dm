SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = INIT_ORDER_MAPPING // 9
	flags = SS_NO_FIRE
	/// What map datum are we using
	var/datum/map/map_datum
	/// What map will be used next round
	var/datum/map/next_map
	/// List of all areas that can be accessed via IC means
	var/list/teleportlocs
	/// List of all areas that can be accessed via IC and OOC means
	var/list/ghostteleportlocs
	///List of areas that exist on the station this shift
	var/list/existing_station_areas
	///What do we have as the lavaland theme today?
	var/datum/lavaland_theme/lavaland_theme
	///What primary cave theme we have picked for cave generation today.
	var/cave_theme
	// Tells if all maintenance airlocks have emergency access enabled
	var/maint_all_access = FALSE
	// Tells if all station airlocks have emergency access enabled
	var/station_all_access = FALSE

	/// A mapping of environment names to MILLA environment IDs.
	var/list/environments

// This has to be here because world/New() uses [station_name()], which looks this datum up
/datum/controller/subsystem/mapping/PreInit()
	. = ..()
	if(map_datum) // Dont do this again if we are recovering
		return
	if(fexists("data/next_map.txt"))
		var/list/lines = file2list("data/next_map.txt")
		// Check its valid
		try
			map_datum = text2path(lines[1])
			map_datum = new map_datum
		catch
			map_datum = new /datum/map/boxstation // Assume cyberiad if non-existent
		fdel("data/next_map.txt") // Remove to avoid the same map existing forever
	else
		map_datum = new /datum/map/boxstation // Assume cyberiad if non-existent

/datum/controller/subsystem/mapping/Shutdown()
	if(next_map) // Save map for next round
		var/F = file("data/next_map.txt")
		F << next_map.type

/datum/controller/subsystem/mapping/Initialize()
	environments = list()
	environments[ENVIRONMENT_LAVALAND] = create_environment(oxygen = LAVALAND_OXYGEN, nitrogen = LAVALAND_NITROGEN, temperature = LAVALAND_TEMPERATURE)
	environments[ENVIRONMENT_TEMPERATE] = create_environment(oxygen = MOLES_O2STANDARD, nitrogen = MOLES_N2STANDARD, temperature = T20C)
	environments[ENVIRONMENT_COLD] = create_environment(oxygen = MOLES_O2STANDARD, nitrogen = MOLES_N2STANDARD, temperature = 180)

	var/datum/lavaland_theme/lavaland_theme_type = pick(subtypesof(/datum/lavaland_theme))
	ASSERT(lavaland_theme_type)
	lavaland_theme = new lavaland_theme_type
	log_startup_progress("We're in the mood for [initial(lavaland_theme.name)] today...") //We load this first. In the event some nerd ever makes a surface map, and we don't have it in lavaland in the event lavaland is disabled.

	cave_theme = pick(BLOCKED_BURROWS, CLASSIC_CAVES, DEADLY_DEEPROCK)
	log_startup_progress("We feel like [cave_theme] today...")
	// Load all Z level templates
	preloadTemplates()
	preloadTemplates(path = "code/modules/unit_tests/atmos/")

	// Load the station
	loadStation()

	// Load lavaland
	loadLavaland()

	// Seed space ruins
	if(GLOB.configuration.ruins.enable_space_ruins)
		handleRuins()
	else
		log_startup_progress("Skipping space ruins...")

	// Makes a blank space level for the sake of randomness
	GLOB.space_manager.add_new_zlevel("Empty Area", linkage = CROSSLINKED, traits = list(REACHABLE_BY_CREW, REACHABLE_SPACE_ONLY))


	// Setup the Z-level linkage
	GLOB.space_manager.do_transition_setup()

	if(GLOB.configuration.ruins.enable_lavaland)
		// Spawn Lavaland ruins and rivers.
		log_startup_progress("Populating lavaland...")
		var/lavaland_setup_timer = start_watch()
		seedRuins(list(level_name_to_num(MINING)), GLOB.configuration.ruins.lavaland_ruin_budget, /area/lavaland/surface/outdoors/unexplored, GLOB.lava_ruins_templates)
		if(lavaland_theme)
			lavaland_theme.setup()
			lavaland_theme.setup_caves()
		var/time_spent = stop_watch(lavaland_setup_timer)
		log_startup_progress("Successfully populated lavaland in [time_spent]s.")
	else
		log_startup_progress("Skipping lavaland ruins...")

	// Now we make a list of areas for teleport locs
	// Located below is some of the worst code I've ever seen
	// Checking all areas to see if they have a turf in them? Nice one ssmapping!

	var/list/all_areas = list()
	for(var/area/areas in world)
		all_areas += areas

	teleportlocs = list()
	for(var/area/AR as anything in all_areas)
		if(AR.no_teleportlocs)
			continue
		if(teleportlocs[AR.name])
			continue
		var/list/pickable_turfs = list()
		for(var/turf/turfs in AR)
			pickable_turfs += turfs
			CHECK_TICK
		var/turf/picked = safepick(pickable_turfs)
		if(picked && is_station_level(picked.z))
			teleportlocs[AR.name] = AR
		CHECK_TICK

	teleportlocs = sortAssoc(teleportlocs)

	ghostteleportlocs = list()
	for(var/area/AR as anything in all_areas)
		if(ghostteleportlocs[AR.name])
			continue
		var/list/pickable_turfs = list()
		for(var/turf/turfs in AR)
			pickable_turfs += turfs
			CHECK_TICK
		if(length(pickable_turfs))
			ghostteleportlocs[AR.name] = AR
		CHECK_TICK

	ghostteleportlocs = sortAssoc(ghostteleportlocs)

	// Now we make a list of areas that exist on the station. Good for if you don't want to select areas that exist for one station but not others. Directly references
	existing_station_areas = list()
	for(var/area/AR as anything in all_areas)
		var/list/pickable_turfs = list()
		for(var/turf/turfs in AR)
			pickable_turfs += turfs
			CHECK_TICK
		var/turf/picked = safepick(pickable_turfs)
		if(picked && is_station_level(picked.z))
			existing_station_areas += AR
		CHECK_TICK

	// World name
	if(GLOB.configuration.general.server_name)
		world.name = "[GLOB.configuration.general.server_name]: [station_name()]"
	else
		world.name = station_name()

	if(HAS_TRAIT(SSstation, STATION_TRAIT_MESSY))
		generate_themed_messes(subtypesof(/obj/effect/spawner/themed_mess) - /obj/effect/spawner/themed_mess/party)
	if(HAS_TRAIT(SSstation, STATION_TRAIT_HANGOVER))
		generate_themed_messes(list(/obj/effect/spawner/themed_mess/party))

/datum/controller/subsystem/mapping/proc/seed_space_salvage(space_z_levels)
	log_startup_progress("Seeding space salvage...")
	var/space_salvage_timer = start_watch()
	var/seeded_salvage_surfaces = list()
	var/seeded_salvage_closets = list()

	var/list/small_salvage_items = list(
		/obj/item/salvage/ruin/brick,
		/obj/item/salvage/ruin/nanotrasen,
		/obj/item/salvage/ruin/carp,
		/obj/item/salvage/ruin/tablet,
		/obj/item/salvage/ruin/pirate,
		/obj/item/salvage/ruin/russian
	)

	for(var/z_level in space_z_levels)
		var/list/turf/z_level_turfs = block(1, 1, z_level, world.maxx, world.maxy, z_level)
		for(var/z_level_turf in z_level_turfs)
			var/turf/T = z_level_turf
			var/area/A = get_area(T)
			if(istype(A, /area/ruin/space))
							// cardboard boxes are blacklisted otherwise deepstorage.dmm ends up hogging all the loot
				var/list/closet_blacklist = list(/obj/structure/closet/cardboard, /obj/structure/closet/fireaxecabinet, /obj/structure/closet/walllocker/emerglocker, /obj/structure/closet/crate/can, /obj/structure/closet/body_bag, /obj/structure/closet/coffin)
				for(var/obj/structure/closet/closet in T)
					if(is_type_in_list(closet, closet_blacklist))
						continue

					seeded_salvage_closets |= closet
				for(var/obj/structure/table/table in T)
					if(locate(/obj/machinery) in T)
						continue // Machinery on tables tend to take up all the visible space
					seeded_salvage_surfaces |= table

	var/max_salvage_attempts = rand(10, 15)
	while(max_salvage_attempts > 0 && length(seeded_salvage_closets) > 0)
		var/obj/structure/closet/C = pick_n_take(seeded_salvage_closets)
		var/salvage_item_type = pick(small_salvage_items)
		var/obj/salvage_item = new salvage_item_type(C)
		salvage_item.pixel_x = rand(-5, 5)
		salvage_item.pixel_y = rand(-5, 5)
		max_salvage_attempts -= 1

	max_salvage_attempts = rand(10, 15)
	while(max_salvage_attempts > 0 && length(seeded_salvage_surfaces) > 0)
		var/obj/T = pick_n_take(seeded_salvage_surfaces)
		var/salvage_item_type = pick(small_salvage_items)
		var/obj/salvage_item = new salvage_item_type(T.loc)
		salvage_item.pixel_x = rand(-5, 5)
		salvage_item.pixel_y = rand(-5, 5)
		max_salvage_attempts -= 1

	log_startup_progress("Successfully seeded space salvage in [stop_watch(space_salvage_timer)]s.")

// Do not confuse with seedRuins()
/datum/controller/subsystem/mapping/proc/handleRuins()
	// load in extra levels of space ruins
	var/load_zlevels_timer = start_watch()
	log_startup_progress("Creating random space levels...")
	var/num_extra_space = rand(GLOB.configuration.ruins.extra_levels_min, GLOB.configuration.ruins.extra_levels_max)
	for(var/i in 1 to num_extra_space)
		GLOB.space_manager.add_new_zlevel("Ruin Area #[i]", linkage = CROSSLINKED, traits = list(REACHABLE_BY_CREW, SPAWN_RUINS, REACHABLE_SPACE_ONLY))
		CHECK_TICK

	log_startup_progress("Loaded random space levels in [stop_watch(load_zlevels_timer)]s.")

	// Now spawn ruins, random budget between 20 and 30 for all zlevels combined.
	// While this may seem like a high number, the amount of ruin Z levels can be anywhere between 3 and 7.
	// Note that this budget is not split evenly accross all zlevels
	log_startup_progress("Seeding ruins...")
	var/seed_ruins_timer = start_watch()
	var/space_z_levels = levels_by_trait(SPAWN_RUINS)
	seedRuins(space_z_levels, rand(20, 30), /area/space, GLOB.space_ruins_templates)
	log_startup_progress("Successfully seeded ruins in [stop_watch(seed_ruins_timer)]s.")
	seed_space_salvage(space_z_levels)

// Loads in the station
/datum/controller/subsystem/mapping/proc/loadStation()
	if(GLOB.configuration.system.override_map)
		log_startup_progress("Station map overridden by configuration to [GLOB.configuration.system.override_map].")
		var/map_datum_path = text2path(GLOB.configuration.system.override_map)
		if(map_datum_path)
			map_datum = new map_datum_path
		else
			to_chat(world, "<span class='narsie'>ERROR: The map datum specified to load is invalid. Falling back to... cyberiad probably?</span>")

	ASSERT(map_datum.map_path)
	if(!fexists(map_datum.map_path))
		// Make a VERY OBVIOUS error
		to_chat(world, "<span class='narsie'>ERROR: The path specified for the map to load is invalid. No station has been loaded!</span>")
		return

	var/watch = start_watch()
	log_startup_progress("Loading [map_datum.fluff_name]...")
	// This should always be Z2, but you never know
	var/map_z_level = GLOB.space_manager.add_new_zlevel(MAIN_STATION, linkage = CROSSLINKED, traits = list(STATION_LEVEL, STATION_CONTACT, REACHABLE_BY_CREW, REACHABLE_SPACE_ONLY, AI_OK))
	GLOB.maploader.load_map(wrap_file(map_datum.map_path), z_offset = map_z_level)
	log_startup_progress("Loaded [map_datum.fluff_name] in [stop_watch(watch)]s")

	// Save station name in the DB
	if(!SSdbcore.IsConnected())
		return
	var/datum/db_query/query_set_map = SSdbcore.NewQuery(
		"UPDATE round SET start_datetime=NOW(), map_name=:mapname, station_name=:stationname WHERE id=:round_id",
		list("mapname" = map_datum.technical_name, "stationname" = map_datum.fluff_name, "round_id" = GLOB.round_id)
	)
	query_set_map.Execute(async = FALSE) // This happens during a time of intense server lag, so should be non-async
	qdel(query_set_map)

// Loads in lavaland
/datum/controller/subsystem/mapping/proc/loadLavaland()
	if(!GLOB.configuration.ruins.enable_lavaland)
		log_startup_progress("Skipping Lavaland...")
		return
	var/watch = start_watch()
	log_startup_progress("Loading Lavaland...")
	var/lavaland_z_level = GLOB.space_manager.add_new_zlevel(MINING, linkage = SELFLOOPING, traits = list(ORE_LEVEL, REACHABLE_BY_CREW, STATION_CONTACT, HAS_WEATHER, AI_OK))
	GLOB.maploader.load_map(file("_maps/map_files220/generic/Lavaland.dmm"), z_offset = lavaland_z_level) // SS220 EDIT - map_files
	log_startup_progress("Loaded Lavaland in [stop_watch(watch)]s")

/datum/controller/subsystem/mapping/proc/seedRuins(list/z_levels = null, budget = 0, whitelist = /area/space, list/potentialRuins)
	if(!z_levels || !length(z_levels))
		WARNING("No Z levels provided - Not generating ruins")
		return

	for(var/zl in z_levels)
		var/turf/T = locate(1, 1, zl)
		if(!T)
			WARNING("Z level [zl] does not exist - Not generating ruins")
			return

	var/list/ruins = potentialRuins.Copy()

	var/list/forced_ruins = list()		//These go first on the z level associated (same random one by default)
	var/list/ruins_availible = list()	//we can try these in the current pass
	var/forced_z	//If set we won't pick z level and use this one instead.

	//Set up the starting ruin list
	for(var/key in ruins)
		var/datum/map_template/ruin/R = ruins[key]
		if(R.cost > budget) //Why would you do that
			continue
		if(R.always_place)
			forced_ruins[R] = -1
		if(R.unpickable)
			continue
		ruins_availible[R] = R.placement_weight

	while(budget > 0 && (length(ruins_availible) || length(forced_ruins)))
		var/datum/map_template/ruin/current_pick
		var/forced = FALSE
		if(length(forced_ruins)) //We have something we need to load right now, so just pick it
			for(var/ruin in forced_ruins)
				current_pick = ruin
				if(forced_ruins[ruin] > 0) //Load into designated z
					forced_z = forced_ruins[ruin]
				forced = TRUE
				break
		else //Otherwise just pick random one
			current_pick = pickweight(ruins_availible)

		var/placement_tries = PLACEMENT_TRIES
		var/failed_to_place = TRUE
		var/z_placed = 0
		while(placement_tries > 0)
			placement_tries--
			z_placed = pick(z_levels)
			if(!current_pick.try_to_place(forced_z ? forced_z : z_placed,whitelist))
				continue
			else
				failed_to_place = FALSE
				break

		//That's done remove from priority even if it failed
		if(forced)
			//TODO : handle forced ruins with multiple variants
			forced_ruins -= current_pick
			forced = FALSE

		if(failed_to_place)
			for(var/datum/map_template/ruin/R in ruins_availible)
				if(R.id == current_pick.id)
					ruins_availible -= R
			log_world("Failed to place [current_pick.name] ruin.")
		else
			budget -= current_pick.cost
			if(!current_pick.allow_duplicates)
				for(var/datum/map_template/ruin/R in ruins_availible)
					if(R.id == current_pick.id)
						ruins_availible -= R
			if(current_pick.never_spawn_with)
				for(var/blacklisted_type in current_pick.never_spawn_with)
					for(var/possible_exclusion in ruins_availible)
						if(istype(possible_exclusion,blacklisted_type))
							ruins_availible -= possible_exclusion
		forced_z = 0

		//Update the availible list
		for(var/datum/map_template/ruin/R in ruins_availible)
			if(R.cost > budget)
				ruins_availible -= R

	log_world("Ruin loader finished with [budget] left to spend.")

/datum/controller/subsystem/mapping/proc/make_maint_all_access()
	for(var/area/station/maintenance/A in existing_station_areas)
		for(var/obj/machinery/door/airlock/D in A)
			D.emergency = TRUE
			D.update_icon()
	GLOB.minor_announcement.Announce("Access restrictions on maintenance and external airlocks have been removed.")
	maint_all_access = TRUE
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency maintenance access", "enabled"))

/datum/controller/subsystem/mapping/proc/revoke_maint_all_access()
	for(var/area/station/maintenance/A in existing_station_areas)
		for(var/obj/machinery/door/airlock/D in A)
			D.emergency = FALSE
			D.update_icon()
	GLOB.minor_announcement.Announce("Access restrictions on maintenance and external airlocks have been re-added.")
	maint_all_access = FALSE
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency maintenance access", "disabled"))

/datum/controller/subsystem/mapping/proc/make_station_all_access()
	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(is_station_level(D.z))
			D.emergency = TRUE
			D.update_icon()
	GLOB.minor_announcement.Announce("Access restrictions on all station airlocks have been removed due to an ongoing crisis. Trespassing laws still apply unless ordered otherwise by Command staff.")
	station_all_access = TRUE
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency station access", "enabled"))

/datum/controller/subsystem/mapping/proc/revoke_station_all_access()
	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(is_station_level(D.z))
			D.emergency = FALSE
			D.update_icon()
	GLOB.minor_announcement.Announce("Access restrictions on all station airlocks have been re-added. Seek station AI or a colleague's assistance if you are stuck.")
	station_all_access = FALSE
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency station access", "disabled"))

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
