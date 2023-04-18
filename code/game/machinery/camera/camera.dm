/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "camera"
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 10
	layer = WALL_OBJ_LAYER
	resistance_flags = FIRE_PROOF
	damage_deflection = 12
	armor = list("melee" = 50, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 50)
	var/datum/wires/camera/wires = null // Wires datum
	max_integrity = 100
	integrity_failure = 50
	var/list/network = list("SS13")
	var/c_tag = null
	var/c_tag_order = 999
	var/status = TRUE
	anchored = TRUE
	var/start_active = FALSE //If it ignores the random chance to start broken on round start
	var/invuln = null
	var/obj/item/camera_assembly/assembly = null
	var/list/computers_watched_by = list()

	//OTHER

	var/view_range = 7
	var/short_range = 2

	var/alarm_on = FALSE
	var/busy = FALSE
	var/emped = FALSE  //Number of consecutive EMP's on this camera

	var/in_use_lights = 0 // TO BE IMPLEMENTED
	var/toggle_sound = 'sound/items/wirecutter.ogg'

/obj/machinery/camera/Initialize(mapload)
	. = ..()
	wires = new(src)
	assembly = new(src)
	assembly.state = 4
	assembly.anchored = 1
	assembly.update_icon()

	GLOB.cameranet.cameras += src
	GLOB.cameranet.addCamera(src)
	if(isturf(loc))
		LAZYADD(myArea.cameras, UID())
	if(is_station_level(z) && prob(3) && !start_active)
		toggle_cam(null, FALSE)
		wires.cut_all()

/obj/machinery/camera/proc/set_area_motion(area/A)
	area_motion = A

/obj/machinery/camera/Destroy()
	SStgui.close_uis(wires)
	toggle_cam(null, FALSE) //kick anyone viewing out
	QDEL_NULL(assembly)
	QDEL_NULL(wires)
	GLOB.cameranet.removeCamera(src) //Will handle removal from the camera network and the chunks, so we don't need to worry about that
	GLOB.cameranet.cameras -= src
	if(isarea(myArea))
		LAZYREMOVE(myArea.cameras, UID())
	var/area/ai_monitored/A = get_area(src)
	if(istype(A))
		A.motioncameras -= src
	area_motion = null
	cancelCameraAlarm()
	cancelAlarm()
	LAZYCLEARLIST(computers_watched_by)
	return ..()

/obj/machinery/camera/emp_act(severity)
	if(!status)
		return
	if(!isEmpProof())
		if(prob(150/severity))
			update_icon()
			var/list/previous_network = network
			network = list()
			GLOB.cameranet.removeCamera(src)
			stat |= EMPED
			set_light(0)
			emped = emped+1  //Increase the number of consecutive EMP's
			update_icon()
			var/thisemp = emped //Take note of which EMP this proc is for
			spawn(900)
				if(!QDELETED(src))
					triggerCameraAlarm() //camera alarm triggers even if multiple EMPs are in effect.
					if(emped == thisemp) //Only fix it if the camera hasn't been EMP'd again
						network = previous_network
						stat &= ~EMPED
						update_icon()
						if(can_use())
							GLOB.cameranet.addCamera(src)
						emped = 0 //Resets the consecutive EMP count
						spawn(100)
							if(!QDELETED(src))
								cancelCameraAlarm()
			for(var/mob/M in GLOB.player_list)
				if(M.client && M.client.eye == src)
					M.unset_machine()
					M.reset_perspective(null)
					to_chat(M, "The screen bursts into static.")
			..()

/obj/machinery/camera/tesla_act(power)//EMP proof upgrade also makes it tesla immune
	if(isEmpProof())
		return
	..()
	qdel(src)//to prevent bomb testing camera from exploding over and over forever

/obj/machinery/camera/ex_act(severity)
	if(invuln)
		return
	..()

/obj/machinery/camera/proc/setViewRange(num = 7)
	view_range = num
	GLOB.cameranet.updateVisibility(src, 0)

/obj/machinery/camera/singularity_pull(S, current_size)
	if (status && current_size >= STAGE_FIVE) // If the singulo is strong enough to pull anchored objects and the camera is still active, turn off the camera as it gets ripped off the wall.
		toggle_cam(null, 0)
	..()

/obj/machinery/camera/attackby(obj/item/I, mob/living/user, params)
	var/msg = "<span class='notice'>You attach [I] into the assembly inner circuits.</span>"
	var/msg2 = "<span class='notice'>The camera already has that upgrade!</span>"

	if(istype(I, /obj/item/stack/sheet/mineral/plasma) && panel_open)
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
			return
		if(!isEmpProof())
			var/obj/item/stack/sheet/mineral/plasma/P = I
			upgradeEmpProof()
			to_chat(user, "[msg]")
			P.use(1)
		else
			to_chat(user, "[msg2]")
	else if(istype(I, /obj/item/assembly/prox_sensor) && panel_open)
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
			return
		if(!isMotion())
			upgradeMotion()
			to_chat(user, "[msg]")
			qdel(I)
		else
			to_chat(user, "[msg2]")

	// OTHER
	else if((istype(I, /obj/item/paper) || istype(I, /obj/item/pda)) && isliving(user))
		if (!can_use())
			to_chat(user, "<span class='warning'>You can't show something to a disabled camera!</span>")
			return

		var/mob/living/U = user
		var/obj/item/paper/X = null
		var/obj/item/pda/PDA = null

		var/itemname = ""
		var/info = ""
		if(istype(I, /obj/item/paper))
			X = I
			itemname = X.name
			info = X.info
		else
			PDA = I
			var/datum/data/pda/app/notekeeper/N = PDA.find_program(/datum/data/pda/app/notekeeper)
			if(N)
				itemname = PDA.name
				info = N.note
		to_chat(U, "You hold \the [itemname] up to the camera ...")
		U.changeNext_move(CLICK_CD_MELEE)
		for(var/mob/O in GLOB.player_list)
			if(istype(O, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/AI = O
				if(AI.control_disabled || (AI.stat == DEAD))
					return
				if(U.name == "Unknown")
					to_chat(AI, "<b>[U]</b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ...")
				else
					to_chat(AI, "<b><a href='?src=[AI.UID()];track=[html_encode(U.name)]'>[U]</a></b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ...")
				AI.last_paper_seen = {"<HTML><meta charset="UTF-8"><HEAD><TITLE>[itemname]</TITLE></HEAD><BODY><TT>[info]</TT></BODY></HTML>"}
			else if(O.client && O.client.eye == src)
				to_chat(O, "[U] holds \a [itemname] up to one of the cameras ...")
				O << browse(text({"<HTML><meta charset="UTF-8"><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>"}, itemname, info), text("window=[]", itemname))

	else if(istype(I, /obj/item/laser_pointer))
		var/obj/item/laser_pointer/L = I
		L.laser_act(src, user)
	else
		return ..()


/obj/machinery/camera/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	panel_open = !panel_open
	to_chat(user, "<span class='notice'>You screw [src]'s panel [panel_open ? "open" : "closed"].</span>")

/obj/machinery/camera/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(panel_open)
		wires.Interact(user)

/obj/machinery/camera/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(panel_open)
		wires.Interact(user)

/obj/machinery/camera/welder_act(mob/user, obj/item/I)
	if(!panel_open || !wires.CanDeconstruct())
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_WELD_MESSAGE
	if(I.use_tool(src, user, 100, volume = I.tool_volume))
		visible_message("<span class='warning'>[user] unwelds [src], leaving it as just a frame bolted to the wall.</span>",
						"<span class='warning'>You unweld [src], leaving it as just a frame bolted to the wall</span>")
		deconstruct(TRUE)

/obj/machinery/camera/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(stat & BROKEN)
		return damage_amount
	. = ..()

/obj/machinery/camera/obj_break(damage_flag)
	if(status && !(flags & NODECONSTRUCT))
		triggerCameraAlarm()
		toggle_cam(null, FALSE)
		wires.cut_all()

/obj/machinery/camera/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(disassembled)
			if(!assembly)
				assembly = new()
			assembly.forceMove(drop_location())
			assembly.state = 1
			assembly.setDir(dir)
			assembly.update_icon()
			assembly = null
		else
			var/obj/item/I = new /obj/item/camera_assembly(loc)
			I.obj_integrity = I.max_integrity * 0.5
			new /obj/item/stack/cable_coil(loc, 2)
	qdel(src)

/obj/machinery/camera/update_icon()
	if(!status)
		icon_state = "[initial(icon_state)]1"
	else if(stat & EMPED)
		icon_state = "[initial(icon_state)]emp"
	else
		icon_state = "[initial(icon_state)]"

/obj/machinery/camera/proc/toggle_cam(mob/user, displaymessage = TRUE)
	status = !status
	if(can_use())
		GLOB.cameranet.addCamera(src)
		if(isturf(loc))
			myArea = get_area(src)
			LAZYADD(myArea.cameras, UID())
		else
			myArea = null
	else
		set_light(0)
		GLOB.cameranet.removeCamera(src)
		if(isarea(myArea))
			LAZYREMOVE(myArea.cameras, UID())
	GLOB.cameranet.updateChunk(x, y, z)
	var/change_msg = "deactivates"
	if(status)
		change_msg = "reactivates"
		triggerCameraAlarm()
		spawn(100)
			if(!QDELETED(src))
				cancelCameraAlarm()
	if(displaymessage)
		if(user)
			visible_message("<span class='danger'>[user] [change_msg] [src]!</span>")
			add_hiddenprint(user)
		else
			visible_message("<span class='danger'>\The [src] [change_msg]!</span>")

		playsound(loc, toggle_sound, 100, 1)
	update_icon()

	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/O in GLOB.player_list)
		if(O.client && O.client.eye == src)
			O.unset_machine()
			O.reset_perspective(null)
			to_chat(O, "The screen bursts into static.")

/obj/machinery/camera/proc/triggerCameraAlarm()
	alarm_on = TRUE
	SSalarm.triggerAlarm("Camera", get_area(src), list(UID()), src)

/obj/machinery/camera/proc/cancelCameraAlarm()
	alarm_on = FALSE
	SSalarm.cancelAlarm("Camera", get_area(src), src)

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

/obj/machinery/camera/proc/update_computers_watched_by()
	for(var/obj/machinery/computer/security/computer as anything in computers_watched_by)
		computer.update_camera_view()

/atom/proc/auto_turn()
	//Automatically turns based on nearby walls.
	var/turf/simulated/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(istype(T))
			//If someone knows a better way to do this, let me know. -Giacom
			switch(i)
				if(NORTH)
					setDir(SOUTH)
				if(SOUTH)
					setDir(NORTH)
				if(WEST)
					setDir(EAST)
				if(EAST)
					setDir(WEST)
			break

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C
	return null

/proc/near_range_camera(mob/M)
	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C
	return null

/obj/machinery/camera/proc/Togglelight(on = FALSE)
	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		for(var/obj/machinery/camera/cam in A.lit_cameras)
			if(cam == src)
				return
	if(on)
		set_light(AI_CAMERA_LUMINOSITY)
	else
		set_light(0)

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

/obj/machinery/camera/get_remote_view_fullscreens(mob/user)
	if(view_range == short_range) //unfocused
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)

/obj/machinery/camera/update_remote_sight(mob/living/user)
	if(isXRay() && isAI(user))
		user.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		user.see_in_dark = max(user.see_in_dark, 8)
		user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	else
		user.sight = initial(user.sight)
		user.see_in_dark = initial(user.see_in_dark)
		user.lighting_alpha = initial(user.lighting_alpha)

	..()
	return TRUE

/obj/machinery/camera/portable //Cameras which are placed inside of things, such as helmets.
	var/turf/prev_turf

/obj/machinery/camera/portable/Initialize(mapload)
	. = ..()
	assembly.state = 0 //These cameras are portable, and so shall be in the portable state if removed.
	assembly.anchored = 0
	assembly.update_icon()

/obj/machinery/camera/portable/process() //Updates whenever the camera is moved.
	if(GLOB.cameranet && get_turf(src) != prev_turf)
		GLOB.cameranet.updatePortableCamera(src)
		prev_turf = get_turf(src)
