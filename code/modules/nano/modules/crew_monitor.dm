/datum/nano_module/crew_monitor
	name = "Crew monitor"
	var/list/tracked = new

/datum/nano_module/crew_monitor/Topic(href, href_list)
	if(..()) 
		return 1
	var/turf/T = get_turf(nano_host())
	if (!T || !(T.z in config.player_levels))
		usr << "<span class='warning'>Unable to establish a connection<span>: You're too far away from the station!"
		return 0
	if(href_list["track"])
		if(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			var/mob/living/carbon/human/H = locate(href_list["track"]) in mob_list
			if(hassensorlevel(H, SUIT_SENSOR_TRACKING))
				AI.ai_actual_track(H)
		return 1

/datum/nano_module/crew_monitor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	src.scan()

	var/data[0]
	var/turf/T = get_turf(nano_host())
	var/list/crewmembers = list()
	for(var/obj/item/clothing/under/C in src.tracked)

		var/turf/pos = get_turf(C)

		if((C) && (C.has_sensor) && (pos) && (T && pos.z == T.z) && (C.sensor_mode != SUIT_SENSOR_OFF))
			if(istype(C.loc, /mob/living/carbon/human))

				var/mob/living/carbon/human/H = C.loc
				if(H.w_uniform != C)
					continue

				var/list/crewmemberData = list("dead"=0, "oxy"=-1, "tox"=-1, "fire"=-1, "brute"=-1, "area"="", "x"=-1, "y"=-1)
	
				crewmemberData["reference"] = "\ref[H]"
				crewmemberData["sensor_type"] = C.sensor_mode
				crewmemberData["name"] = H.get_authentification_name(if_no_id="Unknown")
				crewmemberData["rank"] = H.get_authentification_rank(if_no_id="Unknown", if_no_job="No Job")
				crewmemberData["assignment"] = H.get_assignment(if_no_id="Unknown", if_no_job="No Job")

				if(C.sensor_mode >= SUIT_SENSOR_BINARY)
					crewmemberData["dead"] = H.stat > 1

				if(C.sensor_mode >= SUIT_SENSOR_VITAL)
					crewmemberData["oxy"] = round(H.getOxyLoss(), 1)
					crewmemberData["tox"] = round(H.getToxLoss(), 1)
					crewmemberData["fire"] = round(H.getFireLoss(), 1)
					crewmemberData["brute"] = round(H.getBruteLoss(), 1)

				if(C.sensor_mode >= SUIT_SENSOR_TRACKING)
					var/area/A = get_area(H)
					crewmemberData["area"] = sanitize(A.name)
					crewmemberData["x"] = pos.x
					crewmemberData["y"] = pos.y

				crewmembers[++crewmembers.len] = crewmemberData

	crewmembers = sortByKey(crewmembers, "name")

	data["isAI"] = isAI(user)
	data["crewmembers"] = crewmembers

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "crew_monitor.tmpl", "Crew Monitoring Computer", 900, 800)

		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "crew_monitor_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "crew_monitor_map_header.tmpl")

		ui.set_initial_data(data)
		ui.open()

		// should make the UI auto-update; doesn't seem to?
		ui.set_auto_update(1)

/datum/nano_module/crew_monitor/proc/scan()
	for(var/mob/living/carbon/human/H in mob_list)
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/C = H.w_uniform
			if (C.has_sensor)
				tracked |= C
	return 1
