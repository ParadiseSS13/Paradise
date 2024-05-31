/datum/ui_module/crew_monitor
	name = "Crew monitor"
	var/is_advanced = FALSE
	var/viewing_current_z_level
	/// If true, we'll see everyone, regardless of their suit sensors.
	var/ignore_sensors = FALSE

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
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				if(hassensorlevel(H, SUIT_SENSOR_TRACKING))
					AI.ai_actual_track(H)
			if(isobserver(usr))
				var/mob/dead/observer/ghost = usr
				ghost.ManualFollow(H)
		if("switch_level")
			if(!is_advanced)
				return
			viewing_current_z_level = text2num(params["new_level"])

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

	data["isAI"] = isAI(user)
	data["isObserver"] = isobserver(user)
	data["ignoreSensors"] = ignore_sensors
	data["crewmembers"] = GLOB.crew_repository.health_data(viewing_current_z_level, ignore_sensors)
	data["critThreshold"] = HEALTH_THRESHOLD_CRIT

	return data

/datum/ui_module/crew_monitor/ui_static_data(mob/user)
	var/list/data = list()

	data["is_advanced"] = is_advanced
	data["possible_levels"] = list()
	for(var/zl in GLOB.space_manager.z_list)
		data["possible_levels"] |= zl

	return data

/datum/ui_module/crew_monitor/ghost
	name = "Crew monitor (Observer)"
	is_advanced = TRUE
	ignore_sensors = TRUE

/datum/ui_module/crew_monitor/ghost/ui_state(mob/user)
	return GLOB.observer_state
