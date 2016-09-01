/obj/machinery/computer/security
	name = "Camera Monitor"
	desc = "Used to access the various cameras networks on the station."
	icon_keyboard = "security_key"
	icon_screen = "cameras"
	circuit = /obj/item/weapon/circuitboard/camera
	var/obj/machinery/camera/current = null
	var/list/network = list("")
	var/last_pic = 1
	light_color = LIGHT_COLOR_RED
	var/mapping = 0
	var/list/networks[0]
	var/list/data[0]
	var/list/access[0]

/obj/machinery/computer/security/New() // Lists existing networks and their required access. Format: networks[<name>] = list(<access>)
	networks["SS13"] =              list(access_hos,access_captain)
	networks["Telecomms"] =         list(access_hos,access_captain)
	networks["Research Outpost"] =  list(access_rd,access_hos,access_captain)
	networks["Mining Outpost"] =    list(access_qm,access_hop,access_hos,access_captain)
	networks["Research"] =          list(access_rd,access_hos,access_captain)
	networks["Prison"] =            list(access_hos,access_captain)
	networks["Labor"] =             list(access_hos,access_captain)
	networks["Interrogation"] =     list(access_hos,access_captain)
	networks["Atmosphere Alarms"] = list(access_ce,access_hos,access_captain)
	networks["Fire Alarms"] =       list(access_ce,access_hos,access_captain)
	networks["Power Alarms"] =      list(access_ce,access_hos,access_captain)
	networks["Supermatter"] =       list(access_ce,access_hos,access_captain)
	networks["MiniSat"] =           list(access_rd,access_hos,access_captain)
	networks["Singularity"] =       list(access_ce,access_hos,access_captain)
	networks["Anomaly Isolation"] = list(access_rd,access_hos,access_captain)
	networks["Toxins"] =            list(access_rd,access_hos,access_captain)
	networks["Telepad"] =           list(access_rd,access_hos,access_captain)
	networks["TestChamber"] =       list(access_rd,access_hos,access_captain)
	networks["ERT"] =               list(access_cent_specops_commander,access_cent_commander)
	networks["CentComm"] =          list(access_cent_security,access_cent_commander)
	networks["Thunderdome"] =       list(access_cent_thunder,access_cent_commander)

	..()

/obj/machinery/computer/security/attack_ai(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/security/check_eye(var/mob/user as mob)
	if((get_dist(user, src) > 1 || !( user.canmove ) || user.blinded || !( current ) || !( current.status )) && (!istype(user, /mob/living/silicon)))
		return null
	user.reset_view(current)
	return 1

// Network configuration
/obj/machinery/computer/security/attackby(obj/item/I, user as mob, params)
	access = I.GetAccess()
	if(access.len) // If hit by something with access.
		ui_interact(user)
	else
		..()

/obj/machinery/computer/security/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		to_chat(user, "\blue You have authorized full network access!")
		ui_interact(user)
	else
		ui_interact(user)

/obj/machinery/computer/security/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (NOPOWER|BROKEN))
		return
	if(user.stat)
		return

	var/data[0]
	data["current"] = null

	var/list/cameras = list()
	for(var/obj/machinery/camera/C in cameranet.cameras)
		if((is_away_level(src.z) || is_away_level(C.z)) && !atoms_share_level(C, src)) //can only recieve away mission cameras on away missions
			continue
		if(!can_access_camera(C))
			continue

		cameras[++cameras.len] = C.nano_structure()

	for(var/i = cameras.len, i > 0, i--) //based off /proc/camera_sort, sorts cameras alphabetically for the UI
		for(var/j = 1 to i - 1)
			var/a = cameras[j]
			var/b = cameras[j + 1]
			if(sorttext(a["name"], b["name"]) < 0)
				cameras.Swap(j, j + 1)

	data["cameras"] = cameras

	if(emagged)
		access = list(access_captain) // Assume captain level access when emagged
		data["emagged"] = 1

	if(isAI(user) || isrobot(user))
		access = list(access_captain) // Assume captain level access when AI

	var/tempnets[0]
	// Loop through the ID's permission, and check which networks the ID has access to.
	for(var/net in networks) // Loop through networks.
		for(var/req in networks[net]) // Loop through access levels of the networks.
			if(req in access)
				if(net in network) // Checks if the network is currently active.
					tempnets.Add(list(list("name" = net, "active" = 1)))
				else
					tempnets.Add(list(list("name" = net, "active" = 0)))
				break

	if(tempnets.len)
		data["networks"] = tempnets

	if(current)
		data["current"] = current.nano_structure()

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "sec_camera.tmpl", "Camera Console", 900, 800)

		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "sec_camera_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "sec_camera_map_header.tmpl")

		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/security/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["switchTo"])
		if(stat & (NOPOWER|BROKEN))
			return 1
		var/obj/machinery/camera/C = locate(href_list["switchTo"]) in cameranet.cameras
		if(!C)
			return 1
		
		if(!can_access_camera(C))
			return 1 // No href exploits for you.
		
		switch_to_camera(usr, C)

	else if(href_list["reset"])
		if(stat & (NOPOWER|BROKEN))
			return 1
		reset_current()
		usr.check_eye(current)

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
		nanomanager.update_uis(src)


/obj/machinery/computer/security/attack_hand(mob/user)
	access = list()
	if(stat & (NOPOWER|BROKEN))
		return

	if(!isAI(user))
		user.set_machine(src)

	if(ishuman(user))
		access = user.get_access()

	ui_interact(user)

// Check if camera is accessible when jumping
/obj/machinery/computer/security/proc/can_access_camera(var/obj/machinery/camera/C)
	var/list/shared_networks = src.network & C.network
	if(shared_networks.len)
		return 1
	return 0

// Switching to cameras
/obj/machinery/computer/security/proc/switch_to_camera(var/mob/user, var/obj/machinery/camera/C)
	if((get_dist(user, src) > 1 || user.machine != src || user.blinded || !(user.canmove) || !C.can_use()) && !(istype(user, /mob/living/silicon/ai)))
		if(!C.can_use() && !isAI(user))
			current = null
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
			use_power(50)
		return 1

/obj/machinery/computer/security/proc/set_current(var/obj/machinery/camera/C)
	if(current == C)
		return

	if(current)
		reset_current()

	current = C
	if(current)
		use_power = 2

/obj/machinery/computer/security/proc/reset_current()
	current = null
	use_power = 1

//Camera control: moving.
/obj/machinery/computer/security/proc/jump_on_click(var/mob/user,var/A)
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

// Camera control: mouse.
/atom/DblClick()
	..()
	if(istype(usr.machine,/obj/machinery/computer/security))
		var/obj/machinery/computer/security/console = usr.machine
		console.jump_on_click(usr,src)

// Camera control: arrow keys.
/mob/Move(n,direct)
	if(istype(machine,/obj/machinery/computer/security))
		var/obj/machinery/computer/security/console = machine
		var/turf/T = get_turf(console.current)
		for(var/i;i<10;i++)
			T = get_step(T,direct)
		console.jump_on_click(src,T)
		return
	return ..(n,direct)

// Other computer monitors.
/obj/machinery/computer/security/telescreen
	name = "\improper Telescreen"
	desc = "Used for watching camera networks."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	light_range_on = 0
	network = list("SS13")
	density = 0

/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have Paradise TV on these things."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	light_color = "#FFEEDB"
	light_range_on = 0
	network = list("news")
	luminosity = 0

/obj/machinery/computer/security/wooden_tv
	name = "security camera monitor"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "television"
	icon_keyboard = null
	icon_screen = "detective_tv"
	light_color = "#3848B3"
	light_power_on = 0.5
	network = list("SS13")

/obj/machinery/computer/security/mining
	name = "outpost camera monitor"
	desc = "Used to access the various cameras on the outpost."
	icon_keyboard = "mining_key"
	icon_screen = "mining"
	light_color = "#F9BBFC"
	network = list("Mining Outpost")

/obj/machinery/computer/security/engineering
	name = "engineering camera monitor"
	desc = "Used to monitor fires and breaches."
	icon_keyboard = "power_key"
	icon_screen = "engie_cams"
	light_color = "#FAC54B"
	network = list("Power Alarms","Atmosphere Alarms","Fire Alarms")
