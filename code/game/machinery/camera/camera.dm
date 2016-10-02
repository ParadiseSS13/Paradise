/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	use_power = 2
	idle_power_usage = 5
	active_power_usage = 10
	layer = 5

	var/datum/wires/camera/wires = null // Wires datum
	var/list/network = list("SS13")
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1
	anchored = 1
	var/start_active = 0 //If it ignores the random chance to start broken on round start
	var/invuln = null
	var/obj/item/device/camera_bug/bug = null
	var/obj/item/weapon/camera_assembly/assembly = null

	//OTHER

	var/view_range = 7
	var/short_range = 2

	var/light_disabled = 0
	var/alarm_on = 0
	var/busy = 0
	var/emped = 0  //Number of consecutive EMP's on this camera

/obj/machinery/camera/New()
	..()
	wires = new(src)

	assembly = new(src)
	assembly.state = 4
	assembly.anchored = 1
	assembly.update_icon()

	cameranet.cameras += src
	cameranet.addCamera(src)

/obj/machinery/camera/initialize()
	..()
	if(is_station_level(z) && prob(3) && !start_active)
		toggle_cam()

/obj/machinery/camera/Destroy()
	toggle_cam(null, 0) //kick anyone viewing out
	if(assembly)
		qdel(assembly)
		assembly = null
	if(istype(bug))
		bug.bugged_cameras -= src.c_tag
		if(bug.current == src)
			bug.current = null
		bug = null
	qdel(wires)
	wires = null
	cameranet.removeCamera(src) //Will handle removal from the camera network and the chunks, so we don't need to worry about that
	cameranet.cameras -= src
	return ..()

/obj/machinery/camera/emp_act(severity)
	if(!status)
		return
	if(!isEmpProof())
		if(prob(150/severity))
			icon_state = "[initial(icon_state)]emp"
			var/list/previous_network = network
			network = list()
			cameranet.removeCamera(src)
			stat |= EMPED
			set_light(0)
			emped = emped+1  //Increase the number of consecutive EMP's
			var/thisemp = emped //Take note of which EMP this proc is for
			spawn(900)
				if(loc) //qdel limbo
					triggerCameraAlarm() //camera alarm triggers even if multiple EMPs are in effect.
					if(emped == thisemp) //Only fix it if the camera hasn't been EMP'd again
						network = previous_network
						icon_state = initial(icon_state)
						stat &= ~EMPED
						cancelCameraAlarm()
						if(can_use())
							cameranet.addCamera(src)
						emped = 0 //Resets the consecutive EMP count
						spawn(100)
							if(!qdeleted(src))
								cancelCameraAlarm()
			for(var/mob/O in mob_list)
				if(O.client && O.client.eye == src)
					O.unset_machine()
					O.reset_view(null)
					to_chat(O, "The screen bursts into static.")
			..()


/obj/machinery/camera/ex_act(severity, target)
	if(src.invuln)
		return
	else
		..()
	return

/obj/machinery/camera/blob_act()
	qdel(src)
	return

/obj/machinery/camera/attack_alien(mob/living/carbon/alien/humanoid/user as mob)
	if(!istype(user))
		return
	user.do_attack_animation(src)
	add_hiddenprint(user)
	status = 0
	visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	toggle_cam(user, 0)


/obj/machinery/camera/proc/setViewRange(num = 7)
	src.view_range = num
	cameranet.updateVisibility(src, 0)

/obj/machinery/camera/attackby(W as obj, mob/living/user as mob, params)
	var/msg = "<span class='notice'>You attach [W] into the assembly inner circuits.</span>"
	var/msg2 = "<span class='notice'>The camera already has that upgrade!</span>"

	// DECONSTRUCTION
	if(istype(W, /obj/item/weapon/screwdriver))
//		to_chat(user, "<span class='notice'>You start to [panel_open ? "close" : "open"] the camera's panel.</span>")
		//if(toggle_panel(user)) // No delay because no one likes screwdrivers trying to be hip and have a duration cooldown
		panel_open = !panel_open
		user.visible_message("<span class='warning'>[user] screws the camera's panel [panel_open ? "open" : "closed"]!</span>",
		"<span class='notice'>You screw the camera's panel [panel_open ? "open" : "closed"].</span>")
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

	else if((istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/device/multitool)) && panel_open)
		wires.Interact(user)

	else if(istype(W, /obj/item/weapon/weldingtool) && wires.CanDeconstruct())
		if(weld(W, user))
			to_chat(user, "You unweld the camera leaving it as just a frame screwed to the wall.")
			if(!assembly)
				assembly = new()
			assembly.loc = src.loc
			assembly.state = 1
			assembly.dir = src.dir
			assembly.update_icon()
			assembly = null
			qdel(src)
			return
	else if(istype(W, /obj/item/device/analyzer) && panel_open) //XRay
		if(!user.unEquip(W))
			to_chat(user, "<span class='warning'>[W] is stuck!</span>")
			return
		if(!isXRay())
			upgradeXRay()
			qdel(W)
			to_chat(user, "[msg]")
		else
			to_chat(user, "[msg2]")

	else if(istype(W, /obj/item/stack/sheet/mineral/plasma) && panel_open)
		if(!user.unEquip(W))
			to_chat(user, "<span class='warning'>[W] is stuck!</span>")
			return
		if(!isEmpProof())
			upgradeEmpProof()
			to_chat(user, "[msg]")
			qdel(W)
		else
			to_chat(user, "[msg2]")
	else if(istype(W, /obj/item/device/assembly/prox_sensor) && panel_open)
		if(!user.unEquip(W))
			return
		if(!isMotion())
			upgradeMotion()
			to_chat(user, "[msg]")
			qdel(W)
		else
			to_chat(user, "[msg2]")

	// OTHER
	else if((istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/device/pda)) && isliving(user))
		var/mob/living/U = user
		var/obj/item/weapon/paper/X = null
		var/obj/item/device/pda/P = null

		var/itemname = ""
		var/info = ""
		if(istype(W, /obj/item/weapon/paper))
			X = W
			itemname = X.name
			info = X.info
		else
			P = W
			var/datum/data/pda/app/notekeeper/N = P.find_program(/datum/data/pda/app/notekeeper)
			if(N)
				itemname = P.name
				info = N.notehtml
		to_chat(U, "You hold \the [itemname] up to the camera ...")
		U.changeNext_move(CLICK_CD_MELEE)
		for(var/mob/O in player_list)
			if(istype(O, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/AI = O
				if(AI.control_disabled || (AI.stat == DEAD))
					return
				if(U.name == "Unknown")
					to_chat(AI, "<b>[U]</b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ...")
				else
					to_chat(AI, "<b><a href='?src=[AI.UID()];track=[html_encode(U.name)]'>[U]</a></b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ...")
				AI.last_paper_seen = "<HTML><HEAD><TITLE>[itemname]</TITLE></HEAD><BODY><TT>[info]</TT></BODY></HTML>"
			else if(O.client && O.client.eye == src)
				to_chat(O, "[U] holds \a [itemname] up to one of the cameras ...")
				O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))

	else if(istype(W, /obj/item/device/camera_bug))
		if(!src.can_use())
			to_chat(user, "<span class='notice'>Camera non-functional.</span>")
			return
		if(istype(src.bug))
			to_chat(user, "<span class='notice'>Camera bug removed.</span>")
			src.bug.bugged_cameras -= src.c_tag
			src.bug = null
		else
			to_chat(user, "<span class='notice'>Camera bugged.</span>")
			src.bug = W
			src.bug.bugged_cameras[src.c_tag] = src

	else if(istype(W, /obj/item/weapon/melee/energy/blade))//Putting it here last since it's a special case. I wonder if there is a better way to do these than type casting.
		toggle_cam(user, 1)
		var/datum/effect/system/spark_spread/spark_system = new /datum/effect/system/spark_spread()
		spark_system.set_up(5, 0, loc)
		spark_system.start()
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(loc, "sparks", 50, 1)
		visible_message("<span class='notice'>[user] has sliced the camera apart with an energy blade!</span>")
		qdel(src)

	else if(istype(W, /obj/item/device/laser_pointer))
		var/obj/item/device/laser_pointer/L = W
		L.laser_act(src, user)
	else
		..()
	return

/obj/machinery/camera/proc/toggle_cam(mob/user, displaymessage = 1)
	status = !status
	if(can_use())
		cameranet.addCamera(src)
	else
		set_light(0)
		cameranet.removeCamera(src)
	cameranet.updateChunk(x, y, z)
	var/change_msg = "deactivates"
	if(!status)
		icon_state = "[initial(icon_state)]1"
	else
		icon_state = initial(icon_state)
		change_msg = "reactivates"
		triggerCameraAlarm()
		spawn(100)
			if(!qdeleted(src))
				cancelCameraAlarm()
	if(displaymessage)
		if(user)
			visible_message("<span class='danger'>[user] [change_msg] [src]!</span>")
			add_hiddenprint(user)
		else
			visible_message("<span class='danger'>\The [src] [change_msg]!</span>")

		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)

	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/O in player_list)
		if(O.client && O.client.eye == src)
			O.unset_machine()
			O.reset_view(null)
			to_chat(O, "The screen bursts into static.")

/obj/machinery/camera/proc/triggerCameraAlarm(var/duration = 0)
	alarm_on = 1
	motion_alarm.triggerAlarm(loc, src)

/obj/machinery/camera/proc/cancelCameraAlarm()
	if(wires.IsIndexCut(CAMERA_WIRE_ALARM))
		return

	alarm_on = 0
	motion_alarm.clearAlarm(loc, src)

/obj/machinery/camera/proc/can_use()
	if(!status)
		return 0
	if(stat & EMPED)
		return 0
	return 1

/obj/machinery/camera/proc/can_see()
	var/list/see = null
	var/turf/pos = get_turf(src)
	if(isXRay())
		see = range(view_range, pos)
	else
		see = hear(view_range, pos)
	return see

/atom/proc/auto_turn()
	//Automatically turns based on nearby walls.
	var/turf/simulated/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(istype(T))
			//If someone knows a better way to do this, let me know. -Giacom
			switch(i)
				if(NORTH)
					src.dir = SOUTH
				if(SOUTH)
					src.dir = NORTH
				if(WEST)
					src.dir = EAST
				if(EAST)
					src.dir = WEST
			break

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(var/mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break
	return null

/proc/near_range_camera(var/mob/M)
	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break

	return null

/obj/machinery/camera/proc/weld(var/obj/item/weapon/weldingtool/WT, var/mob/user)
	if(busy)
		return 0
	if(!WT.remove_fuel(0, user))
		return 0

	to_chat(user, "<span class='notice'>You start to weld [src]...</span>")
	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	busy = 1
	if(do_after(user, 100, target = src))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
	return 0

/obj/machinery/camera/proc/Togglelight(on=0)
	for(var/mob/living/silicon/ai/A in ai_list)
		for(var/obj/machinery/camera/cam in A.lit_cameras)
			if(cam == src)
				return
	if(on)
		src.set_light(AI_CAMERA_LUMINOSITY)
	else
		src.set_light(0)

/obj/machinery/camera/proc/nano_structure()
	var/cam[0]
	var/turf/T = get_turf(src)
	cam["name"] = sanitize(c_tag)
	cam["deact"] = !can_use()
	cam["camera"] = "\ref[src]"
	if(T)
		cam["x"] = T.x
		cam["y"] = T.y
		cam["z"] = T.z
	else
		cam["x"] = 0
		cam["y"] = 0
		cam["z"] = 0
	return cam

/obj/machinery/camera/portable //Cameras which are placed inside of things, such as helmets.
	var/turf/prev_turf

/obj/machinery/camera/portable/New()
	..()
	assembly.state = 0 //These cameras are portable, and so shall be in the portable state if removed.
	assembly.anchored = 0
	assembly.update_icon()

/obj/machinery/camera/portable/process() //Updates whenever the camera is moved.
	if(cameranet && get_turf(src) != prev_turf)
		cameranet.updatePortableCamera(src)
		prev_turf = get_turf(src)
