/datum/nano_module/camera_monitor
	name = "Camera Monitor"
	var/obj/machinery/camera/current = null
	var/list/network = list("SS13")
	var/cache_id = 0
	var/list/networks = list(
		"SS13",
		"Telecomms",
		"Research Outpost",
		"Mining Outpost",
		"Research",
		"Prison",
		"Labor",
		"Interrogation",
		"Atmosphere Alarms",
		"Fire Alarms",
		"Power Alarms",
		"Supermatter",
		"MiniSat",
		"Singularity",
		"Anomaly Isolation",
		"Toxins",
		"Telepad",
		"TestChamber"
	)
	var/list/tempnets[0]
	var/list/data[0]
	var/camera_cache = null
	
/datum/nano_module/camera_monitor/New()
	..()

	
/datum/nano_module/camera_monitor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	var/data[0]

	data["current"] = null

	if(camera_cache_id != cache_id)
		cache_id = camera_cache_id
		cameranet.process_sort()

		var/cameras[0]
		for(var/obj/machinery/camera/C in cameranet.cameras)
			if(!can_access_camera(C))
				continue

			var/cam = C.nano_structure()
			cameras[++cameras.len] = cam

		camera_cache=list2json(cameras)

	tempnets.Cut()

	for(var/l in networks) // Loop through networks.
		if(l in network) // Checks if the network is currently active.
			tempnets.Add(list(list("name" = l, "active" = 1)))
		else
			tempnets.Add(list(list("name" = l, "active" = 0)))
	if(tempnets.len)
		data["networks"] = tempnets

	if(current)
		data["current"] = current.nano_structure()
	data["cameras"] = list("__json_cache" = camera_cache)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "sec_camera.tmpl", "Camera Console", 650, 550)

		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "sec_camera_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "sec_camera_map_header.tmpl")

		ui.set_initial_data(data)
		ui.open()
		//ui.set_auto_update(1)
		
/datum/nano_module/camera_monitor/Topic(href, href_list)
	if(..()) 
		return 1

	if(href_list["switchTo"])
		var/obj/machinery/camera/C = locate(href_list["switchTo"]) in cameranet.cameras
		if(!C) return

		switch_to_camera(usr, C)
		return 1
	else if(href_list["activate"]) // Activate: enable or disable networks
		var/net = href_list["activate"]	// Network to be enabled or disabled.
		var/active = href_list["active"] // Is the network currently active.
		if(text2num(active) == 1)
			src.network -= net
		else
			src.network += net
		invalidateCameraCache()
		nanomanager.update_uis(src)


// Check if camera is accessible when jumping
/datum/nano_module/camera_monitor/proc/can_access_camera(var/obj/machinery/camera/C)
	var/list/shared_networks = src.network & C.network
	if(shared_networks.len)
		return 1
	return 0

// Switching to cameras
/datum/nano_module/camera_monitor/proc/switch_to_camera(var/mob/user, var/obj/machinery/camera/C)
	var/mob/living/silicon/ai/A = user
	// Only allow non-carded AIs to view because the interaction with the eye gets all wonky otherwise.
	if(!A.is_in_chassis())
		return 0
	A.eyeobj.setLoc(get_turf(C))
	A.client.eye = A.eyeobj
	return 1
