// Floor painter

/datum/painter/floor
	module_name = "floor painter"
	module_state = "floor_painter"

	var/floor_icon = 'icons/turf/floors.dmi'
	var/floor_state = "floor"
	var/floor_dir = SOUTH
	var/wide_mode = FALSE

	var/static/list/allowed_states = list(
		"gcircuit",
		"bcircuit",
		"rcircuit",
		"floorgrime",
		"freezerfloor",
		"grimy",
		"loadingarea",
		"rampbottom",
		"ramptop",
		"tile_standard",
		"tile_edge",
		"tile_half",
		"tile_full",
		"tile_corner",
		"tile_grid",
		"tile_dark_standard",
		"tile_dark_edge",
		"tile_dark_half",
		"tile_dark_full",
		"tile_dark_corner",
		"tile_dark_grid",
		"tile_white_standard",
		"tile_white_edge",
		"tile_white_half",
		"tile_white_full",
		"tile_white_corner",
		"tile_white_grid",
	)

/datum/painter/floor/paint_atom(atom/target, mob/user)
	if(!istype(target, /turf/simulated/floor/plasteel))
		to_chat(user, "<span class='warning'>[holder] can only be used on station flooring.</span>")
		return
	var/turf/simulated/floor/plasteel/F = target

	if(!wide_mode && F.icon_state == floor_state && F.dir == floor_dir)
		to_chat(user, "<span class='notice'>This is already painted [floor_state] [dir2text(floor_dir)]!</span>")
		return

	F.icon_state = floor_state
	F.icon_regular_floor = floor_state
	F.dir = floor_dir

	if(wide_mode)
		var/turf/simulated/floor/plasteel/tileList = F.AdjacentTurfs(TRUE, FALSE, FALSE)
		for(var/turf/simulated/floor/plasteel/T in tileList)
			T.icon_state = floor_state
			T.icon_regular_floor = floor_state
			T.dir = floor_dir

	return TRUE

/datum/painter/floor/pick_color(mob/user)
	if(!user)
		return
	ui_interact(user)

/datum/painter/floor/ui_state(mob/user)
	return GLOB.inventory_state

/datum/painter/floor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FloorPainter", module_name)
		// Disable automatic updates, because we are the only user of the item, and don't expect to observe external changes
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/painter/floor/ui_data(mob/user)
	var/list/data = list()
	data["selectedStyle"] = floor_state
	data["selectedDir"] = floor_dir
	data["wideMode"] = wide_mode
	return data

/datum/painter/floor/ui_static_data(mob/user)
	var/list/data = list()
	data["icon"] = floor_icon
	data["availableStyles"] = allowed_states
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
		var/dir = params["direction"]
		if(dir != 0)
			floor_dir = dir

	if(action == "wide_mode")
		wide_mode = !wide_mode

	return TRUE
