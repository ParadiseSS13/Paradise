/datum/ui_module/crew_monitor
	name = "Crew monitor"
	var/is_advanced = FALSE
	var/viewing_current_z_level

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
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/mob/living/carbon/human/H = locate(params["track"]) in GLOB.human_list
				if(hassensorlevel(H, SUIT_SENSOR_TRACKING))
					AI.ai_actual_track(H)
		if("switch_level")
			if(!is_advanced)
				return
			viewing_current_z_level = text2num(params["new_level"])



/datum/ui_module/crew_monitor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "CrewMonitor", name, 800, 600, master_ui, state)

		// Send nanomaps
		var/datum/asset/nanomaps = get_asset_datum(/datum/asset/simple/nanomaps)
		nanomaps.send(user)

		ui.open()


/datum/ui_module/crew_monitor/ui_data(mob/user)
	var/list/data = list()
	if(!is_advanced) // Advanced, allow viewing across multiple z-levels, but controlled by ui_act
		var/turf/T = get_turf(ui_host())
		viewing_current_z_level = T.z

	if(!viewing_current_z_level)
		viewing_current_z_level = level_name_to_num(MAIN_STATION) // by default, set it to the station

	data["viewing_current_z_level"] = viewing_current_z_level

	data["isAI"] = isAI(user)
	data["crewmembers"] = GLOB.crew_repository.health_data(viewing_current_z_level)
	data["critThreshold"] = HEALTH_THRESHOLD_CRIT

	return data

/datum/ui_module/crew_monitor/ui_static_data(mob/user)
	var/list/data = list()

	data["is_advanced"] = is_advanced

	data["possible_levels"] = list()
	for(var/z in 1 to world.maxz)
		data["possible_levels"] |= z

	return data
