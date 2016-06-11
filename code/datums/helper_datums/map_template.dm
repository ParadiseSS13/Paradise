/datum/map_template
	var/name = "Default Template Name"
	var/width = 0
	var/height = 0
	var/mappath = null
	var/mapfile = null
	var/loaded = 0 // Times loaded this round

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
	var/bounds = maploader.load_map(file(path), 1, 1, 1, cropMap = 0, measureOnly = 1)
	if(bounds)
		width = bounds[MAP_MAXX] // Assumes all templates are rectangular, have a single Z level, and begin at 1,1,1
		height = bounds[MAP_MAXY]
	return bounds

/datum/map_template/proc/load(turf/T, centered = 0)
	if(centered)
		T = locate(T.x - round(width/2), T.y - round(height/2), T.z)
	if(!T)
		return
	if(T.x+width > world.maxx)
		return
	if(T.y+height > world.maxy)
		return

	var/list/bounds = maploader.load_map(get_file(), T.x, T.y, T.z, cropMap = 1)
	if(!bounds)
		return 0
	late_setup_level(
		block(T, locate(T.x + width - 1, T.y + height - 1, T.z)),
		block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + width, T.y + height, T.z)))

	log_game("[name] loaded at [T.x],[T.y],[T.z]")
	return 1

/datum/map_template/proc/get_file()
	if(mapfile)
		. = mapfile
	else if(mappath)
		. = file(mappath)

	if(!.)
		log_to_dd("  The file of [src] appears to be empty/non-existent.")

/datum/map_template/proc/get_affected_turfs(turf/T, centered = 0)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - round(width/2), placement.y - round(height/2), placement.z)
		if(corner)
			placement = corner
	return block(placement, locate(placement.x+width-1, placement.y+height-1, placement.z))


/proc/preloadTemplates(path = "_maps/map_files/templates/") //see master controller setup
	var/list/filelist = flist(path)
	for(var/map in filelist)
		var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
		map_templates[T.name] = T

	if(!config.disable_space_ruins) // so we don't unnecessarily clutter start-up
		preloadRuinTemplates()
	//preloadShuttleTemplates()

/proc/preloadRuinTemplates()
	// Still supporting bans by filename
	var/list/banned
	if(fexists("config/spaceRuinBlacklist.txt"))
		banned = generateMapList("config/spaceRuinBlacklist.txt")
	else
		banned = generateMapList("config/example/spaceRuinBlacklist.txt")
	//banned += generateMapList("config/lavaRuinBlacklist.txt")

	for(var/item in subtypesof(/datum/map_template/ruin))
		var/datum/map_template/ruin/ruin_type = item
		// screen out the abstract subtypes
		if(!initial(ruin_type.id))
			continue
		var/datum/map_template/ruin/R = new ruin_type()

		if(banned.Find(R.mappath))
			continue

		map_templates[R.name] = R
		ruins_templates[R.name] = R

		/*
		if(istype(R, /datum/map_template/ruin/lavaland))
			lava_ruins_templates[R.name] = R
		*/
		if(istype(R, /datum/map_template/ruin/space))
			space_ruins_templates[R.name] = R

/*
/proc/preloadShuttleTemplates()
	for(var/item in subtypesof(/datum/map_template/shuttle))
		var/datum/map_template/shuttle/shuttle_type = item
		if(!(initial(shuttle_type.suffix)))
			continue

		var/datum/map_template/shuttle/S = new shuttle_type()

		shuttle_templates[S.shuttle_id] = S
		map_templates[S.shuttle_id] = S
*/
