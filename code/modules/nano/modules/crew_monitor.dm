/datum/nano_module/crew_monitor
	name = "Crew monitor"

/datum/nano_module/crew_monitor/Topic(href, href_list)
	if(..())
		return 1
	var/turf/T = get_turf(nano_host())
	if(!T || !is_level_reachable(T.z))
		to_chat(usr, "<span class='warning'><b>Unable to establish a connection</b>: You're too far away from the station!</span>")
		return 0
	if(href_list["track"])
		if(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			var/mob/living/carbon/human/H = locate(href_list["track"]) in GLOB.mob_list
			if(hassensorlevel(H, SUIT_SENSOR_TRACKING))
				AI.ai_actual_track(H)
		return 1

/datum/nano_module/crew_monitor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "crew_monitor.tmpl", "Crew Monitoring Computer", 900, 800)

		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "crew_monitor_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "crew_monitor_map_header.tmpl")

		ui.open()

		// should make the UI auto-update; doesn't seem to?
		ui.set_auto_update(1)

/datum/nano_module/crew_monitor/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	var/turf/T = get_turf(nano_host())

	data["isAI"] = isAI(user)
	data["crewmembers"] = crew_repository.health_data(T)

	return data
