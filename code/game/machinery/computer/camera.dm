/obj/machinery/computer/security
	name = "security camera console"
	desc = "Used to access the various cameras networks on the station."

	icon_keyboard = "security_key"
	icon_screen = "cameras"
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/camera

	var/mapping = 0 // For the overview file (overview.dm), not used on this page

	var/list/network = list()
	var/list/available_networks = list()
	var/list/watchers = list() //who's using the console, associated with the camera they're on.

/obj/machinery/computer/security/New() // Lists existing networks and their required access. Format: available_networks[<name>] = list(<access>)
	generate_network_access()
	..()

/obj/machinery/computer/security/proc/generate_network_access()
	available_networks["SS13"] =              list(access_hos,access_captain)
	available_networks["Telecomms"] =         list(access_hos,access_captain)
	available_networks["Research Outpost"] =  list(access_rd,access_hos,access_captain)
	available_networks["Mining Outpost"] =    list(access_qm,access_hop,access_hos,access_captain)
	available_networks["Research"] =          list(access_rd,access_hos,access_captain)
	available_networks["Prison"] =            list(access_hos,access_captain)
	available_networks["Labor"] =             list(access_hos,access_captain)
	available_networks["Interrogation"] =     list(access_hos,access_captain)
	available_networks["Atmosphere Alarms"] = list(access_ce,access_hos,access_captain)
	available_networks["Fire Alarms"] =       list(access_ce,access_hos,access_captain)
	available_networks["Power Alarms"] =      list(access_ce,access_hos,access_captain)
	available_networks["Supermatter"] =       list(access_ce,access_hos,access_captain)
	available_networks["MiniSat"] =           list(access_rd,access_hos,access_captain)
	available_networks["Singularity"] =       list(access_ce,access_hos,access_captain)
	available_networks["Anomaly Isolation"] = list(access_rd,access_hos,access_captain)
	available_networks["Toxins"] =            list(access_rd,access_hos,access_captain)
	available_networks["Telepad"] =           list(access_rd,access_hos,access_captain)
	available_networks["TestChamber"] =       list(access_rd,access_hos,access_captain)
	available_networks["ERT"] =               list(access_cent_specops_commander,access_cent_commander)
	available_networks["CentComm"] =          list(access_cent_security,access_cent_commander)
	available_networks["Thunderdome"] =       list(access_cent_thunder,access_cent_commander)

/obj/machinery/computer/security/Destroy()
	if(watchers.len)
		for(var/mob/M in watchers)
			M.unset_machine() //to properly reset the view of the users if the console is deleted.
	return ..()

/obj/machinery/computer/security/proc/isCameraFarAway(obj/machinery/camera/C)
	var/turf/consoleturf = get_turf(src)
	var/turf/cameraturf = get_turf(C)
	if((is_away_level(cameraturf.z) || is_away_level(consoleturf.z)) && !atoms_share_level(cameraturf, consoleturf)) //can only recieve away mission cameras on away missions
		return TRUE

/obj/machinery/computer/security/check_eye(mob/user)
	if(!(user in watchers))
		user.unset_machine()
		return
	if(!watchers[user])
		user.unset_machine()
		return
	var/obj/machinery/camera/C = watchers[user]
	if(isCameraFarAway(C))
		user.unset_machine()
		return
	if(!can_access_camera(C, user))
		user.unset_machine()
		return
	return 1

/obj/machinery/computer/security/on_unset_machine(mob/user)
	watchers.Remove(user)
	user.reset_perspective(null)

/obj/machinery/computer/security/attack_hand(mob/user)
	if(stat || ..())
		user.unset_machine()
		return

	ui_interact(user)

/obj/machinery/computer/security/attackby(obj/item/I, user as mob, params)
	if(isscrewdriver(I))
		..()
	else if(I.GetAccess()) // If hit by something with access.
		attack_hand(user)
	else
		..()

/obj/machinery/computer/security/telescreen/attackby(obj/item/I, mob/user, params)
	if(ismultitool(I))
		var/direction = input(user, "Which direction?", "Select direction!") as null|anything in list("North", "East", "South", "West", "Centre")
		if(!direction || !Adjacent(user))
			return
		pixel_x = 0
		pixel_y = 0
		switch(direction)
			if("North")
				pixel_y = 32
			if("East")
				pixel_x = 32
			if("South")
				pixel_y = -32
			if("West")
				pixel_x = -32
	else
		..()

/obj/machinery/computer/security/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		to_chat(user, "<span class='notice'>You have authorized full network access!</span>")
		attack_hand(user)
	else
		attack_hand(user)

/obj/machinery/computer/security/proc/get_user_access(mob/user)
	var/list/access = list()
	
	if(emagged)
		access = get_all_accesses() // Assume captain level access when emagged
	else if(ishuman(user))
		access = user.get_access()
	else if((isAI(user) || isrobot(user)) && CanUseTopic(user, default_state) == STATUS_INTERACTIVE)
		access = get_all_accesses() // Assume captain level access when AI
	else if(user.can_admin_interact())
		access = get_all_accesses()
	return access

/obj/machinery/computer/security/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "sec_camera.tmpl", "Camera Console", 900, 800)

		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "sec_camera_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "sec_camera_map_header.tmpl")

		ui.open()

/obj/machinery/computer/security/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]

	var/list/cameras = list()
	for(var/obj/machinery/camera/C in cameranet.cameras)
		if(isCameraFarAway(C))
			continue
		if(!can_access_camera(C, user))
			continue

		cameras[++cameras.len] = C.nano_structure()

	for(var/i = cameras.len, i > 0, i--) //based off /proc/camera_sort, sorts cameras alphabetically for the UI
		for(var/j = 1 to i - 1)
			var/a = cameras[j]
			var/b = cameras[j + 1]
			if(sorttext(a["name"], b["name"]) < 0)
				cameras.Swap(j, j + 1)

	data["cameras"] = cameras

	var/list/access = get_user_access(user)
	if(emagged)
		data["emagged"] = 1

	var/list/networks_list = list()
	// Loop through the ID's permission, and check which networks the ID has access to.
	for(var/net in available_networks) // Loop through networks.
		for(var/req in available_networks[net]) // Loop through access levels of the networks.
			if(req in access)
				if(net in network) // Checks if the network is currently active.
					networks_list.Add(list(list("name" = net, "active" = 1)))
				else
					networks_list.Add(list(list("name" = net, "active" = 0)))
				break

	if(networks_list.len)
		data["networks"] = networks_list

	data["current"] = null
	if(watchers[user])
		var/obj/machinery/camera/watched = watchers[user]
		data["current"] = watched.nano_structure()

	return data

/obj/machinery/computer/security/Topic(href, href_list)
	if(..())
		usr.unset_machine()
		return 1

	if(href_list["switchTo"])
		var/obj/machinery/camera/C = locate(href_list["switchTo"]) in cameranet.cameras
		if(!C)
			return 1

		switch_to_camera(usr, C)

	else if(href_list["reset"])
		usr.unset_machine()

	else if(href_list["activate"]) // Activate: enable or disable networks
		var/net = href_list["activate"]	// Network to be enabled or disabled.
		var/active = href_list["active"] // Is the network currently active.
		var/list/access = get_user_access(usr)
		for(var/a in available_networks[net])
			if(a in access) // Re-check for authorization.
				if(text2num(active) == 1)
					network -= net
					break
				else
					network += net
					break

	SSnanoui.update_uis(src)

// Check if camera is accessible when jumping
/obj/machinery/computer/security/proc/can_access_camera(var/obj/machinery/camera/C, var/mob/M)
	if(CanUseTopic(M, default_state) != STATUS_INTERACTIVE || M.incapacitated() || !M.has_vision())
		return 0

	if(isrobot(M))
		var/list/viewing = viewers(src)
		if(!viewing.Find(M))
			return 0

	if(isAI(M))
		var/mob/living/silicon/ai/A = M
		if(!A.is_in_chassis())
			return 0

	if(!issilicon(M) && !Adjacent(M))
		return 0

	var/list/shared_networks = network & C.network
	if(!shared_networks.len || !C.can_use())
		return 0

	return 1

// Switching to cameras
/obj/machinery/computer/security/proc/switch_to_camera(var/mob/user, var/obj/machinery/camera/C)
	if(!can_access_camera(C, user))
		user.unset_machine()
		return 1

	if(isAI(user))
		var/mob/living/silicon/ai/A = user
		A.eyeobj.setLoc(get_turf(C))
		A.client.eye = A.eyeobj
	else
		user.reset_perspective(C)
	watchers[user] = C
	use_power(50)

//Camera control: moving.
/obj/machinery/computer/security/proc/jump_on_click(var/mob/user, var/A)
	if(user.machine != src)
		return

	var/obj/machinery/camera/jump_to

	if(istype(A, /obj/machinery/camera))
		jump_to = A

	else if(ismob(A))
		if(ishuman(A))
			var/mob/living/carbon/human/H = A
			jump_to = locate() in H.head
		else if(isrobot(A))
			var/mob/living/silicon/robot/R = A
			jump_to = R.camera

	else if(isobj(A))
		var/obj/O = A
		jump_to = locate() in O

	else if(isturf(A))
		var/best_dist = INFINITY
		for(var/obj/machinery/camera/camera in get_area(A))
			if(!camera.can_use())
				continue
			if(!can_access_camera(camera, user))
				continue
			var/dist = get_dist(camera,A)
			if(dist < best_dist)
				best_dist = dist
				jump_to = camera

	if(isnull(jump_to))
		return

	if(can_access_camera(jump_to, user))
		switch_to_camera(user, jump_to)

// Camera control: mouse.
/atom/DblClick()
	..()
	if(istype(usr.machine, /obj/machinery/computer/security))
		var/obj/machinery/computer/security/console = usr.machine
		console.jump_on_click(usr, src)

// Camera control: arrow keys.
/mob/Move(n, direct)
	if(istype(machine, /obj/machinery/computer/security))
		var/obj/machinery/computer/security/console = machine
		var/turf/T = get_turf(console.watchers[src])
		for(var/i; i < 10; i++)
			T = get_step(T, direct)
		console.jump_on_click(src, T)
		return
	return ..(n,direct)

// Other computer monitors.
/obj/machinery/computer/security/telescreen
	name = "telescreen"
	desc = "Used for watching camera networks."
	icon_state = "telescreen_console"
	icon_screen = "telescreen"
	icon_keyboard = null
	light_range_on = 0
	density = 0
	circuit = /obj/item/circuitboard/camera/telescreen

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have Paradise TV on these things."
	icon_state = "entertainment_console"
	icon_screen = "entertainment"
	light_color = "#FFEEDB"
	light_range_on = 0
	network = list("news")
	luminosity = 0
	circuit = /obj/item/circuitboard/camera/telescreen/entertainment

/obj/machinery/computer/security/wooden_tv
	name = "security camera monitor"
	desc = "An old TV hooked into the station's camera network."
	icon_state = "television"
	icon_keyboard = null
	icon_screen = "detective_tv"
	light_color = "#3848B3"
	light_power_on = 0.5
	network = list("SS13")
	circuit = /obj/item/circuitboard/camera/wooden_tv

/obj/machinery/computer/security/mining
	name = "outpost camera monitor"
	desc = "Used to access the various cameras on the outpost."
	icon_keyboard = "mining_key"
	icon_screen = "mining"
	light_color = "#F9BBFC"
	network = list("Mining Outpost")
	circuit = /obj/item/circuitboard/camera/mining

/obj/machinery/computer/security/engineering
	name = "engineering camera monitor"
	desc = "Used to monitor fires and breaches."
	icon_keyboard = "power_key"
	icon_screen = "engie_cams"
	light_color = "#FAC54B"
	network = list("Power Alarms","Atmosphere Alarms","Fire Alarms")
	circuit = /obj/item/circuitboard/camera/engineering
