/datum/map_template
	var/name = "Default Template Name"
	var/width = 0
	var/height = 0
	var/mappath = null
	var/mapfile = null
	var/loaded = 0 // Times loaded this round
	/// Do we exclude this from CI checks? If so, set this to the templates pathtype itself to avoid it getting passed down
	var/ci_exclude = null // DO NOT SET THIS IF YOU DO NOT KNOW WHAT YOU ARE DOING

/datum/map_template/New(path = null, map = null, rename = null)
	if(path)
		mappath = path
	if(mappath)
		preload_size(mappath)
	if(map)
		mapfile = map
	if(rename)
		name = rename

/datum/map_template/proc/preload_size(path)
	var/bounds = GLOB.maploader.load_map(file(path), 1, 1, 1, shouldCropMap = FALSE, measureOnly = TRUE)
	if(bounds)
		width = bounds[MAP_MAXX] // Assumes all templates are rectangular, have a single Z level, and begin at 1,1,1
		height = bounds[MAP_MAXY]
	return bounds

/datum/map_template/proc/load(turf/T, centered = 0)
	var/turf/placement = T
	var/min_x = placement.x
	var/min_y = placement.y
	if(centered)
		min_x -= round(width/2)
		min_y -= round(height/2)

	var/max_x = min_x + width - 1
	var/max_y = min_y + height - 1

	if(!T)
		return 0

	var/turf/bot_left = locate(max(1, min_x), max(1, min_y), placement.z)
	var/turf/top_right = locate(min(world.maxx, max_x), min(world.maxy, max_y), placement.z)

	// 1 bigger, to update the turf smoothing
	var/turf/ST_bot_left = locate(max(1, min_x-1), max(1, min_y-1), placement.z)
	var/turf/ST_top_right = locate(min(world.maxx, max_x+1), min(world.maxy, max_y+1), placement.z)
	// This is to place a freeze on initialization until the map's done loading
	// otherwise atmos and stuff will start running mid-load
	// This system will metaphorically snap in half (not postpone init everywhere)
	// if given a multi-z template
	// it might need to be adapted for that when that time comes
	GLOB.space_manager.add_dirt(placement.z)
	var/datum/milla_safe/freeze_z_level/milla_freeze = new()
	milla_freeze.invoke_async(T.z)
	UNTIL(milla_freeze.done)
	try
		var/list/bounds = GLOB.maploader.load_map(get_file(), min_x, min_y, placement.z, shouldCropMap = TRUE)
		if(!bounds)
			return 0
		if(bot_left == null || top_right == null)
			stack_trace("One of the late setup corners is bust")

		if(ST_bot_left == null || ST_top_right == null)
			stack_trace("One of the smoothing corners is bust")
	catch(var/exception/e)
		GLOB.space_manager.remove_dirt(placement.z)
		var/datum/milla_safe_must_sleep/late_setup_level/milla = new()
		milla.invoke_async(bot_left, top_right, block(ST_bot_left, ST_top_right))
		message_admins("Map template [name] threw an error while loading. Safe exit attempted, but check for errors at [ADMIN_COORDJMP(placement)].")
		log_admin("Map template [name] threw an error while loading. Safe exit attempted.")
		throw e
	GLOB.space_manager.remove_dirt(placement.z)
	var/datum/milla_safe_must_sleep/late_setup_level/milla = new()
	milla.invoke_async(bot_left, top_right, block(ST_bot_left, ST_top_right))

	log_game("[name] loaded at [min_x],[min_y],[placement.z]")
	return 1

/datum/map_template/proc/get_file()
	if(mapfile)
		. = mapfile
	else if(mappath)
		. = wrap_file(mappath)

	if(!.)
		stack_trace("  The file of [src] appears to be empty/non-existent.")

/datum/map_template/proc/get_affected_turfs(turf/T, centered = 0)
	var/list/coordinate_bounds = get_coordinate_bounds(T, centered)
	var/datum/coords/bottom_left = coordinate_bounds["bottom_left"]
	var/datum/coords/top_right = coordinate_bounds["top_right"]
	return block(max(bottom_left.x_pos, 1), max(bottom_left.y_pos, 1), T.z, min(top_right.x_pos, world.maxx), min(top_right.y_pos, world.maxy), T.z)

/datum/map_template/proc/get_coordinate_bounds(turf/T, centered = FALSE)
	var/turf/placement = T
	var/min_x = placement.x
	var/min_y = placement.y
	if(centered)
		min_x -= round(width/2)
		min_y -= round(height/2)

	var/max_x = min_x + width-1
	var/max_y = min_y + height-1

	var/datum/coords/bottom_left = new(min_x, min_y, 1)
	var/datum/coords/top_right = new(max_x, max_y, 1)
	return list("bottom_left" = bottom_left, "top_right" = top_right)

/datum/map_template/proc/fits_in_map_bounds(turf/T, centered = 0)
	var/turf/placement = T
	var/min_x = placement.x
	var/min_y = placement.y
	if(centered)
		min_x -= round(width/2)
		min_y -= round(height/2)

	var/max_x = min_x + width-1
	var/max_y = min_y + height-1
	if(min_x < 1 || min_y < 1 || max_x > world.maxx || max_y > world.maxy)
		return FALSE
	else
		return TRUE


/proc/preloadTemplates(path = "_maps/map_files/templates/") //see master controller setup
	for(var/map in flist(path))
		if(cmptext(copytext(map, length(map) - 3), ".dmm"))
			var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
			GLOB.map_templates[T.name] = T

	if(GLOB.configuration.ruins.enable_ruins) // so we don't unnecessarily clutter start-up
		preloadRuinTemplates()
	preloadShelterTemplates()
	preloadShuttleTemplates()
	preloadBridgeTemplates()
	preloadEventTemplates()

/proc/preloadRuinTemplates()
	// Merge the active lists together
	var/list/space_ruins = GLOB.configuration.ruins.active_space_ruins.Copy()
	var/list/lava_ruins = GLOB.configuration.ruins.active_lava_ruins.Copy()
	var/list/all_ruins = space_ruins | lava_ruins

	for(var/item in subtypesof(/datum/map_template/ruin))
		var/datum/map_template/ruin/ruin_type = item
		// screen out the abstract subtypes
		if(!initial(ruin_type.id))
			continue
		var/datum/map_template/ruin/R = new ruin_type()

		// If not in the active list, skip it
		if(!(R.mappath in all_ruins))
			continue

		GLOB.map_templates[R.name] = R

		if(istype(R, /datum/map_template/ruin/lavaland))
			GLOB.lava_ruins_templates[R.name] = R
		if(istype(R, /datum/map_template/ruin/space))
			GLOB.space_ruins_templates[R.name] = R

/proc/preloadShelterTemplates()
	for(var/item in subtypesof(/datum/map_template/shelter))
		var/datum/map_template/shelter/shelter_type = item
		if(!(initial(shelter_type.mappath)))
			continue
		var/datum/map_template/shelter/S = new shelter_type()

		GLOB.shelter_templates[S.shelter_id] = S
		GLOB.map_templates[S.shelter_id] = S

/proc/preloadShuttleTemplates()
	for(var/item in subtypesof(/datum/map_template/shuttle))
		var/datum/map_template/shuttle/shuttle_type = item
		if(!initial(shuttle_type.suffix))
			continue

		var/datum/map_template/shuttle/S = new shuttle_type()

		GLOB.shuttle_templates[S.shuttle_id] = S
		GLOB.map_templates[S.shuttle_id] = S

/proc/preloadBridgeTemplates()
	for(var/item in subtypesof(/datum/map_template/ruin/lavaland/zlvl_bridge/vertical))
		var/datum/map_template/ruin/lavaland/zlvl_bridge/vertical/vertical_type = item
		if(!(initial(vertical_type.suffix)))
			continue
		var/datum/map_template/ruin/lavaland/zlvl_bridge/vertical/V = new vertical_type()
		GLOB.lavaland_zlvl_bridge_templates[V.suffix] = V
		GLOB.map_templates[V.suffix] = V
	for(var/item in subtypesof(/datum/map_template/ruin/lavaland/zlvl_bridge/horizontal))
		var/datum/map_template/ruin/lavaland/zlvl_bridge/horizontal/horizontal_type = item
		if(!(initial(horizontal_type.suffix)))
			continue
		var/datum/map_template/ruin/lavaland/zlvl_bridge/horizontal/V = new horizontal_type()
		GLOB.lavaland_zlvl_bridge_templates[V.suffix] = V
		GLOB.map_templates[V.suffix] = V


/proc/preloadEventTemplates()
	for(var/item in subtypesof(/datum/map_template/event))
		var/datum/map_template/event/event_type = item
		if(!initial(event_type.mappath))
			continue

		var/datum/map_template/event/E = new event_type()

		GLOB.map_templates[E.event_id] = E
