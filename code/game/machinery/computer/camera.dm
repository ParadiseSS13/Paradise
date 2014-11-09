/obj/machinery/computer/security
	name = "Camera Monitor"
	desc = "Used to access the various cameras networks on the station."
	icon_state = "cameras"
	circuit = "/obj/item/weapon/circuitboard/camera"
	var/obj/machinery/camera/current = null
	var/list/network = list("")
	var/last_pic = 1.0
	l_color = "#B40000"
	var/mapping = 0 
	var/list/networks[0]
	var/list/tempnets[0]
	var/list/data[0]
	var/list/access[0]
	var/emag = 0

	New() // Lists existing networks and their required access. Format: networks[<name>] = list(<access>)
		networks["SS13"] = list(access_hos,access_captain)
		networks["Telecomms"] = list(access_hos,access_captain)
		networks["Research Outpost"] = list(access_rd,access_hos,access_captain)
		networks["Mining Outpost"] = list(access_qm,access_hop,access_hos,access_captain)	
		networks["Research"] = list(access_rd,access_hos,access_captain)
		networks["Prison"] = list(access_hos,access_captain)
		networks["Interrogation"] = list(access_hos,access_captain)		
		networks["Supermatter"] = list(access_ce,access_hos,access_captain)	
		networks["Singularity"] = list(access_ce,access_hos,access_captain)		
		networks["Anomaly Isolation"] = list(access_rd,access_hos,access_captain)
		networks["Toxins"] = list(access_rd,access_hos,access_captain)
		networks["Telepad"] = list(access_rd,access_hos,access_captain)
		networks["CentCom"] = list(access_cent_captain)
		networks["Thunderdome"] = list(access_cent_captain)	
		
	attack_ai(var/mob/user as mob)
		return ui_interact(user) 

	attack_paw(var/mob/user as mob)
		return attack_hand(user)

	check_eye(var/mob/user as mob)
		if ((get_dist(user, src) > 1 || !( user.canmove ) || user.blinded || !( current ) || !( current.status )) && (!istype(user, /mob/living/silicon)))
			return null
		user.reset_view(current)
		return 1
		
	// Network configuration
	attackby(I as obj, user as mob)
		if(istype(I,/obj/item/weapon/card/emag)) // If hit by an emag.
			var/obj/item/weapon/card/emag/E = I
			if(!emag)
				if(E.uses)
					E.uses--
					emag = 1
					user << "\blue You have authorized full network access!"
					ui_interact(user)
				else
					ui_interact(user)
			else
				ui_interact(user)
		else if(istype(I,/obj/item/weapon/card/id)) // If hit by a regular ID card.
			var/obj/item/weapon/card/id/E = I	
			access = E.access
			ui_interact(user)
		else
			..()
			
	ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
		if(..())
			return
		if(stat & (NOPOWER|BROKEN))
			return						
		
		data.Cut()
		tempnets.Cut()
		if(emag)
			access = list(access_captain) // Assume captain level access when emagged
			data["emagged"] = 1
		if(isAI(user))
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
		data["networks"] = tempnets
		ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
		if(!ui)
			ui = new(user, src, ui_key, "camera_console.tmpl", "Camera Monitor UI", 660, 280)
			ui.set_initial_data(data)
			ui.open()

	Topic(href, href_list)
		if(..())
			return	
		if(href_list["activate"]) // Activate: enable or disable networks
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
						
	attack_hand(var/mob/user as mob)
		if(src.z > 6)
			user << "\red <b>Unable to establish a connection:</b> \black You're too far away from the station!"
			return
		if(stat & (NOPOWER|BROKEN))	
			return

		if(!isAI(user))
			user.set_machine(src)
			
		if(network.len == 0)
			user << "\red No networks configured! Swipe the monitor with an authorized ID to configure them."
			return
			
		// Camera listing
		var/list/L = list()
		for (var/obj/machinery/camera/C in cameranet.viewpoints)
			L.Add(C)
		camera_sort(L)

		var/list/D = list()
		D["Cancel"] = "Cancel"
		for(var/obj/machinery/camera/C in L)
			if(can_access_camera(C))
				D[text("[][]", C.c_tag, (C.status ? null : " (Deactivated)"))] = C
				C.watcherslist -= user
		var/t = input(user, "Which camera should you change to?") as null|anything in D
		if(!t)
			user.unset_machine()
			return 0

		var/obj/machinery/camera/C = D[t]
		
		if(t == "Cancel")
			user.unset_machine()
			return 0

		if(C)
			C.watcherslist += user
			switch_to_camera(user, C)
			spawn(5)
				attack_hand(user)
		return
	
	// Check if camera is accessible when jumping
	proc/can_access_camera(var/obj/machinery/camera/C)
		var/list/shared_networks = src.network & C.network
		if(shared_networks.len)
			return 1
		return 0
	
	// Switching to cameras
	proc/switch_to_camera(var/mob/user, var/obj/machinery/camera/C)
		if ((get_dist(user, src) > 1 || user.machine != src || user.blinded || !( user.canmove ) || !( C.can_use() )) && (!istype(user, /mob/living/silicon/ai)))
			if(!C.can_use() && !isAI(user))
				src.current = null
			return 0
		else
			if(isAI(user))
				var/mob/living/silicon/ai/A = user
				A.eyeobj.setLoc(get_turf(C))
				A.client.eye = A.eyeobj
			else
				src.current = C
				use_power(50)
			return 1

	//Camera control: moving.
	proc/jump_on_click(var/mob/user,var/A)
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
	name = "Telescreen"
	desc = "Used for watching camera networks."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	network = list("SS13")
	density = 0

/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/security/telescreen/entertainment
	name = "Entertainment Monitor"
	desc = "Damn, they better have Paradise TV on these things."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	network = list("news")

/obj/machinery/computer/security/wooden_tv
	name = "Security Camera Monitor"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "security_det"
	network = list("SS13")

/obj/machinery/computer/security/mining
	name = "Outpost Camera Monitor"
	desc = "Used to access the various cameras on the outpost."
	icon_state = "miningcameras"
	network = list("Mining Outpost")

/obj/machinery/computer/security/engineering
	name = "Engineering Camera Monitor"
	desc = "Used to monitor fires and breaches."
	icon_state = "engineeringcameras"
	network = list("Engineering","Power Alarms","Atmosphere Alarms","Fire Alarms")