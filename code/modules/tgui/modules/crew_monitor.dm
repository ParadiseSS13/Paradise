#define MIN_ZOOM 1
#define MAX_ZOOM 8
#define MIN_TAB_INDEX 0
#define MAX_TAB_INDEX 1

/datum/ui_module/crew_monitor
	name = "Crew monitor"
	var/is_advanced = FALSE
	var/viewing_current_z_level
	/// If true, we'll see everyone, regardless of their suit sensors.
	var/ignore_sensors = FALSE
	/// The ID of the currently opened UI tab
	var/tab_index = 0
	/// The zoom level of the UI map view
	var/zoom = 1
	/// The X offset of the UI map
	var/offset_x = 0
	/// The Y offset of the UI map
	var/offset_y = 0
	/// A list of displayed names. Displayed names were intentionally chosen over ckeys,
	/// refs, or uids, because exposing any of the aforementioned to the client could allow
	/// an exploit to detect changelings on sensors.
	var/highlighted_names = list()

/datum/ui_module/crew_monitor/ui_act(action, params)
	if(..())
		return TRUE

	if(!is_advanced)
		var/turf/T = get_turf(ui_host())
		if(!T || !is_level_reachable(T.z))
			to_chat(usr, "<span class='warning'><b>Unable to establish a connection</b>: You're too far away from the station!</span>")
			return FALSE

	. = TRUE

	switch(action)
		if("track")
			var/mob/living/carbon/human/H = locate(params["track"]) in GLOB.human_list
			if(is_ai(usr))
				var/mob/living/silicon/ai/AI = usr
				if(hassensorlevel(H, SUIT_SENSOR_TRACKING))
					AI.ai_actual_track(H)
			if(isobserver(usr))
				var/mob/dead/observer/ghost = usr
				ghost.manual_follow(H)
		if("switch_level")
			if(!is_advanced)
				return
			viewing_current_z_level = text2num(params["new_level"])
		if("set_tab_index")
			var/new_tab_index = text2num(params["tab_index"])
			if(isnull(new_tab_index) || new_tab_index < MIN_TAB_INDEX || new_tab_index > MAX_TAB_INDEX)
				return
			tab_index = new_tab_index
		if("set_zoom")
			var/new_zoom = text2num(params["zoom"])
			if(isnull(new_zoom) || new_zoom < MIN_ZOOM || new_zoom > MAX_ZOOM)
				return
			zoom = new_zoom
		if("set_offset")
			var/new_offset_x = text2num(params["offset_x"])
			var/new_offset_y = text2num(params["offset_y"])
			if(isnull(new_offset_x) || isnull(new_offset_y))
				return
			offset_x = new_offset_x
			offset_y = new_offset_y
		if("add_highlighted_name")
			// Intentionally not sanitized as the name is not used for rendering
			var/name = params["name"]
			highlighted_names += list(name)
		if("remove_highlighted_name")
			// Intentionally not sanitized as the name is not used for rendering
			var/name = params["name"]
			highlighted_names -= list(name)
		if("clear_highlighted_names")
			highlighted_names = list()

/datum/ui_module/crew_monitor/ui_state(mob/user)
	return GLOB.default_state

/datum/ui_module/crew_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrewMonitor", name)
		ui.open()

/datum/ui_module/crew_monitor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps)
	)

/datum/ui_module/crew_monitor/ui_data(mob/user)
	var/list/data = list()
	if(!is_advanced) // Advanced, allow viewing across multiple z-levels, but controlled by ui_act
		var/turf/T = get_turf(ui_host())
		viewing_current_z_level = T.z

	if(!viewing_current_z_level)
		viewing_current_z_level = level_name_to_num(MAIN_STATION) // by default, set it to the station

	data["viewing_current_z_level"] = viewing_current_z_level
	data["tabIndex"] = tab_index
	data["zoom"] = zoom
	data["offsetX"] = offset_x
	data["offsetY"] = offset_y

	data["isAI"] = is_ai(user)
	data["isObserver"] = isobserver(user)
	data["ignoreSensors"] = ignore_sensors
	data["crewmembers"] = GLOB.crew_repository.health_data(viewing_current_z_level, ignore_sensors)
	data["highlightedNames"] = highlighted_names
	data["critThreshold"] = HEALTH_THRESHOLD_CRIT

	return data

/datum/ui_module/crew_monitor/ui_static_data(mob/user)
	var/list/data = list()

	data["is_advanced"] = is_advanced
	data["possible_levels"] = list()
	for(var/zl in GLOB.space_manager.z_list)
		data["possible_levels"] |= zl

	return data

/datum/ui_module/crew_monitor/mod
	name = "Crew monitor (Modsuit)"

/datum/ui_module/crew_monitor/mod/ui_state(mob/user)
	return GLOB.deep_inventory_state

/datum/ui_module/crew_monitor/ghost
	name = "Crew monitor (Observer)"
	is_advanced = TRUE
	ignore_sensors = TRUE

/datum/ui_module/crew_monitor/ghost/ui_state(mob/user)
	return GLOB.observer_state

#undef MIN_ZOOM
#undef MAX_ZOOM
#undef MIN_TAB_INDEX
#undef MAX_TAB_INDEX
