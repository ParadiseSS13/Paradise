/datum/tgui_module/crew_monitor
	name = "Crew monitor"

/datum/tgui_module/crew_monitor/tgui_act(action, params)
	if(..())
		return TRUE

	var/turf/T = get_turf(tgui_host())
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


/datum/tgui_module/crew_monitor/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// The 557 may seem random, but its the perfectsize for margins on the nanomap
		ui = new(user, src, ui_key, "CrewMonitor", name, 1400, 557, master_ui, state)
		ui.autoupdate = TRUE
		ui.open()


/datum/tgui_module/crew_monitor/tgui_data(mob/user)
	var/data[0]
	var/turf/T = get_turf(tgui_host())

	data["isAI"] = isAI(user)
	data["crewmembers"] = GLOB.crew_repository.health_data(T)

	return data
