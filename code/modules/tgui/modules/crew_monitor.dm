/datum/ui_module/crew_monitor
	name = "Crew monitor"

/datum/ui_module/crew_monitor/ui_act(action, params)
	if(..())
		return TRUE

	var/turf/T = get_turf(ui_host())
	if(!T || !is_level_reachable(T.z))
		to_chat(usr, "<span class='warning'><b>Unable to establish a connection</b>: You're too far away from the station!</span>")
		return FALSE

	switch(action)
		if("track")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/mob/living/carbon/human/H = locate(params["track"]) in GLOB.human_list
				if(hassensorlevel(H, SUIT_SENSOR_TRACKING))
					AI.ai_actual_track(H)
			return TRUE


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
	var/turf/T = get_turf(ui_host())

	data["isAI"] = isAI(user)
	data["crewmembers"] = GLOB.crew_repository.health_data(T)

	return data
