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
		preload_size(mappath)
	if(map)
		mapfile = map
	if(rename)
		name = rename

/datum/map_template/proc/preload_size(path)
	var/quote = ascii2text(34)
	var/map_file = file2text(path)
	var/key_len = length(copytext(map_file,2,findtext(map_file,quote,2,0)))
	//assuming one map per file since more makes no sense for templates anyway
	var/mapstart = findtext(map_file,"\n(1,1,") //todo replace with something saner
	var/content = copytext(map_file,findtext(map_file,quote+"\n",mapstart,0)+2,findtext(map_file,"\n"+quote,mapstart,0)+1)
	var/line_len = length(copytext(content,1,findtext(content,"\n",2,0)))

	width = line_len/key_len
	height = length(content)/(line_len+1)

/datum/map_template/proc/load(turf/T, centered = 0)
	if(centered)
		T = locate(T.x - round(width / 2), T.y - round(height / 2), T.z)
	if(!T)
		return
	if(T.x+width > world.maxx)
		return
	if(T.y+height > world.maxy)
		return

	maploader.load_map(get_file(), T.x-1, T.y-1, T.z)
	late_setup_level(
		block(T, locate(T.x + width - 1, T.y + height - 1, T.z)),
		block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + width, T.y + height, T.z)))

	log_game("[name] loaded at at [T.x],[T.y],[T.z]")

/datum/map_template/proc/get_file()
	if(mapfile)
		return mapfile
	if(mappath)
		mapfile = file(mappath)
		return mapfile

/datum/map_template/proc/get_affected_turfs(turf/T, centered = 0)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - round(width/2), placement.y - round(height/2), placement.z)
		if(corner)
			placement = corner
	return block(placement, locate(placement.x+width-1, placement.y+height-1, placement.z))


/proc/preloadTemplates(path = "_maps/map_files/templates/") //see master controller setup
	for(var/map in flist(path))
		if(cmptext(copytext(map, length(map) - 3), ".dmm"))
			var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
			map_templates[T.name] = T