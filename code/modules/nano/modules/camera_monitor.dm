/datum/nano_module/camera_monitor
	name = "Camera Monitor"
	var/obj/machinery/camera/current = null
	var/list/network = list("")
	var/cache_id = 0
	var/list/networks[0]
	var/list/tempnets[0]
	var/list/data[0]
	var/list/access[0]
	var/camera_cache = null
	
/datum/nano_module/camera_monitor/New()
	..()
	networks["SS13"] = list(access_hos,access_captain)
	networks["Telecomms"] = list(access_hos,access_captain)
	networks["Research Outpost"] = list(access_rd,access_hos,access_captain)
	networks["Mining Outpost"] = list(access_qm,access_hop,access_hos,access_captain)
	networks["Research"] = list(access_rd,access_hos,access_captain)
	networks["Prison"] = list(access_hos,access_captain)
	networks["Labor"] = list(access_hos,access_captain)
	networks["Interrogation"] = list(access_hos,access_captain)
	networks["Atmosphere Alarms"] = list(access_ce,access_hos,access_captain)
	networks["Fire Alarms"] = list(access_ce,access_hos,access_captain)
	networks["Power Alarms"] = list(access_ce,access_hos,access_captain)
	networks["Supermatter"] = list(access_ce,access_hos,access_captain)
	networks["MiniSat"] = list(access_rd,access_hos,access_captain)
	networks["Singularity"] = list(access_ce,access_hos,access_captain)
	networks["Anomaly Isolation"] = list(access_rd,access_hos,access_captain)
	networks["Toxins"] = list(access_rd,access_hos,access_captain)
	networks["Telepad"] = list(access_rd,access_hos,access_captain)
	networks["TestChamber"] = list(access_rd,access_hos,access_captain)
	
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
	access = list(access_captain) // Assume captain level access when AI

	// Loop through the ID's permission, and check which networks the ID has access to.
	for(var/l in networks) // Loop through networks.
		for(var/m in networks[l]) // Loop through access levels of the networks.
			if(m in access)
				if(l in network) // Checks if the network is currently active.
					tempnets.Add(list(list("name" = l, "active" = 1)))
				else
					tempnets.Add(list(list("name" = l, "active" = 0)))
				break
	if(tempnets.len)
		data["networks"] = tempnets

	if(current)
		data["current"] = current.nano_structure()
	data["cameras"] = list("__json_cache" = camera_cache)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "sec_camera.tmpl", "Camera Console", 900, 800)

		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "sec_camera_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "sec_camera_map_header.tmpl")

		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
		
/datum/nano_module/camera_monitor/Topic(href, href_list)
	if(..()) 
		return 1

	if(href_list["switchTo"])
		if(usr.stat || ((get_dist(usr, src) > 1 || !( usr.canmove ) || usr.blinded) && !istype(usr, /mob/living/silicon))) return
		var/obj/machinery/camera/C = locate(href_list["switchTo"]) in cameranet.cameras
		if(!C) return

		switch_to_camera(usr, C)
		return 1
	else if(href_list["reset"])
		if(usr.stat || ((get_dist(usr, src) > 1 || !( usr.canmove ) || usr.blinded) && !istype(usr, /mob/living/silicon))) return
		reset_current()
		usr.check_eye(current)
		return 1
	else if(href_list["activate"]) // Activate: enable or disable networks
		var/net = href_list["activate"]	// Network to be enabled or disabled.
		var/active = href_list["active"] // Is the network currently active.
		for(var/a in networks[net])
			if(a in access) // Re-check for authorization.
				if(text2num(active) == 1)
					src.network -= net
					break
				else
					src.network += net
					break
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
	if ((get_dist(user, src) > 1 || user.machine != src || user.blinded || !( user.canmove ) || !( C.can_use() )) && (!istype(user, /mob/living/silicon/ai)))
		if(!C.can_use() && !isAI(user))
			src.current = null
		return 0
	else
		if(isAI(user))
			var/mob/living/silicon/ai/A = user
			// Only allow non-carded AIs to view because the interaction with the eye gets all wonky otherwise.
			if(!A.is_in_chassis())
				return 0
			A.eyeobj.setLoc(get_turf(C))
			A.client.eye = A.eyeobj
		else
			set_current(C)
		return 1

/datum/nano_module/camera_monitor/proc/set_current(var/obj/machinery/camera/C)
	if(current == C)
		return

	if(current)
		reset_current()

	src.current = C
	if(current)
		var/mob/living/L = current.loc
		if(istype(L))
			L.tracking_initiated()

/datum/nano_module/camera_monitor/proc/reset_current()
	if(current)
		var/mob/living/L = current.loc
		if(istype(L))
			L.tracking_cancelled()
	current = null

//Camera control: moving.
/datum/nano_module/camera_monitor/proc/jump_on_click(var/mob/user,var/A)
	if(user.machine != src)
		return
	var/obj/machinery/camera/jump_to
	if(istype(A,/obj/machinery/camera))
		jump_to = A
	else if(ismob(A))
		if(ishuman(A))
			jump_to = locate() in A:head
		else if(isrobot(A))
			jump_to = A:camera
	else if(isobj(A))
		jump_to = locate() in A
	else if(isturf(A))
		var/best_dist = INFINITY
		for(var/obj/machinery/camera/camera in get_area(A))
			if(!camera.can_use())
				continue
			if(!can_access_camera(camera))
				continue
			var/dist = get_dist(camera,A)
			if(dist < best_dist)
				best_dist = dist
				jump_to = camera
	if(isnull(jump_to))
		return
	if(can_access_camera(jump_to))
		switch_to_camera(user,jump_to)
