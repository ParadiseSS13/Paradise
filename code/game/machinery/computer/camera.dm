//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31


/obj/machinery/computer/security
	name = "Security Cameras"
	desc = "Used to access the various cameras on the station."
	icon_state = "cameras"
	var/obj/machinery/camera/current = null
	var/last_pic = 1.0
	var/list/network = list("SS13")
	var/mapping = 0//For the overview file, interesting bit of code.

	l_color = "#B40000"
	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)))
			SetLuminosity(2)
		else
			SetLuminosity(0)


	attack_ai(var/mob/user as mob)
		return attack_hand(user)


	attack_paw(var/mob/user as mob)
		return attack_hand(user)


	check_eye(var/mob/user as mob)
		if ((get_dist(user, src) > 1 || !( user.canmove ) || user.blinded || !( current ) || !( current.status )) && (!istype(user, /mob/living/silicon)))
			return null
		user.reset_view(current)
		return 1


	attack_hand(var/mob/user as mob)
		if (src.z > 6)
			user << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
			return
		if(stat & (NOPOWER|BROKEN))	return

		if(!isAI(user))
			user.set_machine(src)

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

	proc/can_access_camera(var/obj/machinery/camera/C)
		var/list/shared_networks = src.network & C.network
		if(shared_networks.len)
			return 1
		return 0

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

	attackby(I as obj, user as mob)
		if(istype(I, /obj/item/weapon/screwdriver))
			playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				if (stat & BROKEN)
					user << "\blue The broken glass falls out."
					var/obj/structure/computerframe/CF = new /obj/structure/computerframe(loc)
					new /obj/item/weapon/shard(loc)
					var/obj/item/weapon/circuitboard/security/CB = new /obj/item/weapon/circuitboard/security(CF)
					CB.network = network
					for (var/obj/C in src)
						C.loc = loc
					CF.circuit = CB
					CF.state = 3
					CF.icon_state = "3"
					CF.anchored = 1
					del(src)
				else
					user << "\blue You disconnect the monitor."
					var/obj/structure/computerframe/CF = new /obj/structure/computerframe( loc )
					var/obj/item/weapon/circuitboard/security/CB = new /obj/item/weapon/circuitboard/security(CF)
					CB.network = network
					for (var/obj/C in src)
						C.loc = loc
					CF.circuit = CB
					CF.state = 4
					CF.icon_state = "4"
					CF.anchored = 1
					del(src)
		else
			attack_hand(user)
		return

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
//Camera control: mouse.
/atom/DblClick()
	..()
	if(istype(usr.machine,/obj/machinery/computer/security))
		var/obj/machinery/computer/security/console = usr.machine
		console.jump_on_click(usr,src)
//Camera control: arrow keys.
/mob/Move(n,direct)
	if(istype(machine,/obj/machinery/computer/security))
		var/obj/machinery/computer/security/console = machine
		var/turf/T = get_turf(console.current)
		for(var/i;i<10;i++)
			T = get_step(T,direct)
		console.jump_on_click(src,T)
		return
	return ..(n,direct)

/obj/machinery/computer/security/telescreen
	name = "Telescreen"
	desc = "Used for watching an empty arena."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	network = list("thunder")
	density = 0

/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have /tg/thechannel on these things."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	network = list("news")

/obj/machinery/computer/security/wooden_tv
	name = "Security Cameras"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "security_det"
	network = list("news")


/obj/machinery/computer/security/mining
	name = "Outpost Cameras"
	desc = "Used to access the various cameras on the outpost."
	icon_state = "miningcameras"
	network = list("MINE")

/obj/machinery/computer/security/engineering
	name = "Engineering Cameras"
	desc = "Used to monitor fires and breaches."
	icon_state = "engineeringcameras"
	network = list("Engineering","Power Alarms","Atmosphere Alarms","Fire Alarms")
