// Floor painter

/datum/painter/floor
	module_name = "floor painter"
	module_state = "floor_painter"

	var/floor_icon
	var/floor_state = "floor"
	var/floor_dir = SOUTH

	var/static/list/allowed_states = list("arrival", "arrivalcorner", "bar", "barber", "bcircuit", "black", "blackcorner", "blue", "bluecorner",
		"bluefull", "bluered", "blueyellow", "blueyellowfull", "bot", "brown", "browncorner", "browncornerold", "cafeteria", "caution",
		"cautioncorner", "cautionfull", "chapel", "cmo", "dark", "delivery", "escape", "escapecorner", "floor", "floorgrime", "freezerfloor", "gcircuit",
		"green", "greenblue", "greenbluefull", "greencorner", "greenfull", "greenyellow", "greenyellowfull", "grimy", "hydrofloor", "loadingarea", "neutral",
		"neutralcorner", "neutralfull", "orange", "orangecorner", "orangefull", "purple", "purplecorner", "purplefull", "rcircuit", "rampbottom", "ramptop", "red",
		"redblue", "redbluefull", "darkredblue", "darkredbluefull", "redcorner", "redfull", "redgreen", "redgreenfull", "darkredgreen", "darkredgreenfull",
		"redyellow", "redyellowfull", "darkredyellow", "darkredyellowfull", "warning", "warningcorner", "warnwhite", "warnwhitecorner", "white",
		"whiteblue", "whitebluecorner", "whitebluefull", "whitebot", "whitecorner", "whitedelivery", "whitegreen", "whitegreencorner", "whitegreenfull", "whitehall",
		"whitepurple", "whitepurplecorner", "whitepurplefull", "whitered", "whiteredcorner", "whiteredfull", "whiteyellow", "whiteyellowcorner", "whiteyellowfull",
		"yellow", "yellowcorner", "yellowcornersiding", "yellowsiding", "darkpurple", "darkpurplecorners", "darkpurplefull",
		"darkred", "darkredcorners", "darkredfull", "darkblue", "darkbluecorners", "darkbluefull", "darkgreen", "darkgreencorners",
		"darkgreenfull", "darkyellow", "darkyellowcorners", "darkyellowfull", "darkbrown", "darkbrowncorners", "darkbrownfull")

/datum/painter/floor/paint_atom(atom/target, mob/user)
	if(!istype(target, /turf/simulated/floor/plasteel))
		to_chat(user, "<span class='warning'>[holder] can only be used on station flooring.</span>")
		return
	var/turf/simulated/floor/plasteel/F = target

	if(F.icon_state == floor_state && F.dir == floor_dir)
		to_chat(user, "<span class='notice'>This is already painted [floor_state] [dir2text(floor_dir)]!</span>")
		return

	F.icon_state = floor_state
	F.icon_regular_floor = floor_state
	F.dir = floor_dir
	return TRUE

/datum/painter/floor/pick_color(mob/user)
	if(!user)
		return
	ui_interact(user)

/datum/painter/floor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "FloorPainter", module_name, 405, 470, master_ui, state)
		// Disable automatic updates, because:
		// 1) we are the only user of the item, and don't expect to observe external changes
		// 2) generating and sending the icon each tick is a bit expensive, and creates small but noticeable lag
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/painter/floor/ui_data(mob/user)
	var/list/data = list()
	data["availableStyles"] = allowed_states
	data["selectedStyle"] = floor_state
	data["selectedDir"] = dir2text(floor_dir)

	data["directionsPreview"] = list()
	for(var/dir in GLOB.alldirs)
		var/icon/floor_icon = icon('icons/turf/floors.dmi', floor_state, dir)
		data["directionsPreview"][dir2text(dir)] = icon2base64(floor_icon)

	return data


/datum/painter/floor/ui_static_data(mob/user)
	var/list/data = list()
	data["allStylesPreview"] = list()
	for(var/style in allowed_states)
		var/icon/floor_icon = icon('icons/turf/floors.dmi', style, SOUTH)
		data["allStylesPreview"][style] = icon2base64(floor_icon)

	return data

/datum/painter/floor/ui_act(action, params)
	if(..())
		return

	if(action == "select_style")
		var/new_style = params["style"]
		if(allowed_states.Find(new_style) != 0)
			floor_state = new_style

	if(action == "cycle_style")
		var/index = allowed_states.Find(floor_state)
		index += text2num(params["offset"])
		while(index < 1)
			index += length(allowed_states)
		while(index > length(allowed_states))
			index -= length(allowed_states)
		floor_state = allowed_states[index]

	if(action == "select_direction")
		var/dir = text2dir(params["direction"])
		if(dir != 0)
			floor_dir = dir

	SStgui.update_uis(src)
