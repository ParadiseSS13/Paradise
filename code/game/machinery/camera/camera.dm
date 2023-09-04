/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	power_state = ACTIVE_POWER_USE
	idle_power_consumption = 5
	active_power_consumption = 10
	layer = WALL_OBJ_LAYER
	resistance_flags = FIRE_PROOF
	damage_deflection = 12
	armor = list(MELEE = 50, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, RAD = 0, FIRE = 90, ACID = 50)
	var/datum/wires/camera/wires = null // Wires datum
	max_integrity = 100
	integrity_failure = 50
	var/list/network = list("SS13")
	var/list/previous_network
	var/c_tag = null
	var/c_tag_order = 999
	var/status = TRUE
	anchored = TRUE
	var/start_active = FALSE //If it ignores the random chance to start broken on round start
	var/invuln = null
	var/obj/item/camera_assembly/assembly = null
	/// If this camera should be added to the camera network and update the camera network when it moves around
	var/part_of_camera_network

	//OTHER

	var/view_range = CAMERA_VIEW_DISTANCE
	var/short_range = 2

	var/alarm_on = FALSE
	var/busy = FALSE
	var/emped = FALSE  //Number of consecutive EMP's on this camera

	var/toggle_sound = 'sound/items/wirecutter.ogg'
	blocks_emissive = EMISSIVE_BLOCK_GENERIC

/obj/machinery/camera/Initialize(mapload, should_add_to_cameranet = TRUE)
	. = ..()
	wires = new(src)
	assembly = new(src)
	assembly.state = 4
	assembly.anchored = TRUE
	assembly.update_icon()

	GLOB.cameranet.cameras += src
	part_of_camera_network = should_add_to_cameranet
	if(part_of_camera_network)
		GLOB.cameranet.addCamera(src)
	if(isturf(loc))
		LAZYADD(get_area(src).cameras, UID())
	if(is_station_level(z) && prob(3) && !start_active)
		turn_off(null, FALSE)
		wires.cut_all()

/obj/machinery/camera/proc/set_area_motion(area/A)
	area_motion = A

/obj/machinery/camera/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	SEND_SIGNAL(src, COMSIG_CAMERA_MOVED, OldLoc)

/obj/machinery/camera/Destroy()
	SStgui.close_uis(wires)
	kick_out_watchers()
	QDEL_NULL(assembly)
	QDEL_NULL(wires)
	GLOB.cameranet.cameras -= src
	if(isarea(get_area(src)))
		LAZYREMOVE(get_area(src).cameras, UID())
	var/area/ai_monitored/A = get_area(src)
	if(istype(A))
		A.motioncameras -= src
	area_motion = null
	cancelAlarm()
	return ..()

/obj/machinery/camera/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src]'s maintenance panel can be <b>screwed [panel_open ? "closed" : "open"]</b>.</span>"
	if(panel_open)
		. += "<span class='notice'>Upgrades can be added to [src] or <b>pried out</b>.</span>"
		if(!wires.CanDeconstruct())
			. += "<span class='notice'>[src]'s <b>internal wires</b> are preventing you from cutting it free.</span>"
		else
			. += "<span class='notice'>[src]'s <i>internal wires</i> are disconnected, but it can be <b>cut free</b>.</span>"


/obj/machinery/camera/emp_act(severity)
	if(!status)
		return
	if(!isEmpProof())
		if(prob(150/severity))
			if(!(stat & EMPED))
				previous_network = network
				network = list()
				stat |= EMPED
				turn_off(null, FALSE, TRUE)
			addtimer(CALLBACK(src, PROC_REF(reactivate_after_emp)), 90 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
			..()

/obj/machinery/camera/proc/reactivate_after_emp()
	network = previous_network
	previous_network = null
	stat &= ~EMPED
	turn_on(null, FALSE, TRUE)

/obj/machinery/camera/ex_act(severity)
	if(invuln)
		return
	..()

/obj/machinery/camera/proc/setViewRange(num = CAMERA_VIEW_DISTANCE)
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
			if(isAI(O))
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

/obj/machinery/camera/update_icon_state()
	if(!status)
		icon_state = "[initial(icon_state)]1"
	else if(stat & EMPED)
		icon_state = "[initial(icon_state)]emp"
	else
		icon_state = "[initial(icon_state)]"

/obj/machinery/camera/proc/toggle_cam(mob/user, display_message = TRUE)
	if(status)
		turn_off(user, display_message)
		return

	turn_on(user, display_message)

/obj/machinery/camera/proc/turn_on(mob/user, display_message = TRUE, emp_recover = FALSE)
	if(status && !emp_recover)
		return
	status = TRUE
	if(!emp_recover && isturf(loc))
		LAZYADD(get_area(src).cameras, UID())

	if(display_message)
		if(user)
			visible_message("<span class='danger'>[user] reactivates [src]!</span>")
			add_hiddenprint(user)
		else
			visible_message("<span class='danger'>\The [src] reactivates!</span>")
		playsound(loc, toggle_sound, 100, TRUE)
	update_icon(UPDATE_ICON_STATE)
	SEND_SIGNAL(src, COMSIG_CAMERA_ON, user, display_message)

/obj/machinery/camera/proc/turn_off(mob/user, display_message = TRUE, emped = FALSE)
	if(!status && !emped)
		return

	if(!emped)
		status = FALSE
		if(isarea(get_area(src)))
			LAZYREMOVE(get_area(src).cameras, UID())

	set_light(0)

	if(display_message)
		if(user)
			visible_message("<span class='danger'>[user] deactivates [src]!</span>")
			add_hiddenprint(user)
		else
			visible_message("<span class='danger'>\The [src] deactivates!</span>")
		playsound(loc, toggle_sound, 100, 1)

	update_icon(UPDATE_ICON_STATE)

	kick_out_watchers()

	SEND_SIGNAL(src, COMSIG_CAMERA_OFF, user, display_message, emped)

/obj/machinery/camera/proc/kick_out_watchers()
	for(var/mob/O in GLOB.player_list)
		if(O.client && O.client.eye == src)
			O.reset_perspective(null)
			to_chat(O, "The screen bursts into static.")

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
	start_active = TRUE // theres no real way to reactivate these, so never break them when they init
	var/turf/prev_turf

/obj/machinery/camera/portable/Initialize(mapload)
	. = ..()
	assembly.state = 0 //These cameras are portable, and so shall be in the portable state if removed.
	assembly.anchored = FALSE
	assembly.update_icon()

/obj/machinery/camera/portable/process() //Updates whenever the camera is moved.
	if(!part_of_camera_network)
		return PROCESS_KILL // Stop wasting performance

	if(get_turf(src) == prev_turf)
		return

	SEND_SIGNAL(src, COMSIG_CAMERA_MOVED, prev_turf)
	GLOB.cameranet.updatePortableCamera(src, prev_turf)
	prev_turf = get_turf(src)
