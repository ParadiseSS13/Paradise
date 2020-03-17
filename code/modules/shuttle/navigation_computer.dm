/obj/machinery/computer/camera_advanced/shuttle_docker
	name = "navigation computer"
	desc = "Used to designate a precise transit location for a spacecraft."
	icon_screen = "navigation"
	icon_keyboard = "med_key"
	jump_action = null
	var/datum/action/innate/shuttledocker_rotate/rotate_action = new
	var/datum/action/innate/shuttledocker_place/place_action = new
	var/shuttleId = ""
	var/shuttlePortId = ""
	var/shuttlePortName = "custom location"
	var/list/jumpto_ports = list() //list of ports to jump to
	var/access_station = TRUE //can we park near X?
	var/access_tcomms = TRUE
	var/access_construction = TRUE
	var/access_mining = TRUE
	var/access_derelict = FALSE
	var/obj/docking_port/stationary/my_port //the custom docking port placed by this console
	var/obj/docking_port/mobile/shuttle_port //the mobile docking port of the connected shuttle
	var/view_range = 7
	var/x_offset = 0
	var/y_offset = 0
	var/space_turfs_only = TRUE
	var/see_hidden = FALSE
	var/designate_time = 0
	var/turf/designating_target_loc

/obj/machinery/computer/camera_advanced/shuttle_docker/Initialize()
	. = ..()
	GLOB.navigation_computers += src
	if(access_station)
		jumpto_ports += list("nav_z1" = 1)
	if(access_tcomms)
		jumpto_ports += list("nav_z3" = 1)
	if(ACCESS_CONSTRUCTION)
		jumpto_ports += list("nav_z4" = 1)
	if(ACCESS_MINING)
		jumpto_ports += list("nav_z5" = 1)
	if(access_derelict)
		jumpto_ports += list("nav_z6" = 1)

/obj/machinery/computer/camera_advanced/shuttle_docker/Destroy()
	. = ..()
	GLOB.navigation_computers -= src

/obj/machinery/computer/camera_advanced/shuttle_docker/attack_hand(mob/user)
	if(!shuttle_port && !SSshuttle.getShuttle(shuttleId))
		to_chat(user,"<span class='warning'>Warning: Shuttle connection severed!</span>")
		return
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/GrantActions(mob/living/user)
	if(jumpto_ports.len)
		jump_action = new /datum/action/innate/camera_jump/shuttle_docker
	..()
	/* 	//technically working but some icons are buggy as shit and either don't rotate or rotate wrong :
		//namely shuttle walls, shuttle windows, shuttle engines and buckled mobs
	if(rotate_action)
		rotate_action.target = user
		rotate_action.Grant(user)
		actions += rotate_action
	*/
	if(place_action)
		place_action.target = user
		place_action.Grant(user)
		actions += place_action

/obj/machinery/computer/camera_advanced/shuttle_docker/CreateEye()
	shuttle_port = SSshuttle.getShuttle(shuttleId)
	if(QDELETED(shuttle_port))
		shuttle_port = null
		return

	eyeobj = new /mob/camera/aiEye/remote/shuttle_docker(null, src)
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	the_eye.setDir(shuttle_port.dir)
	var/turf/origin = locate(shuttle_port.x + x_offset, shuttle_port.y + y_offset, shuttle_port.z)
	for(var/V in shuttle_port.shuttle_areas)
		var/area/A = V
		for(var/turf/T in A)
			if(T.z != origin.z)
				continue
			var/image/I = image('icons/effects/alphacolors.dmi', origin, "red")
			var/x_off = T.x - origin.x
			var/y_off = T.y - origin.y
			I.loc = locate(origin.x + x_off, origin.y + y_off, origin.z) //we have to set this after creating the image because it might be null, and images created in nullspace are immutable.
			I.layer = ABOVE_NORMAL_TURF_LAYER
			I.plane = 0
			I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			the_eye.placement_images[I] = list(x_off, y_off)

/obj/machinery/computer/camera_advanced/shuttle_docker/give_eye_control(mob/user)
	..()
	if(!QDELETED(user) && user.client)
		var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
		var/list/to_add = list()
		to_add += the_eye.placement_images
		to_add += the_eye.placed_images
		if(!see_hidden)
			to_add += SSshuttle.hidden_shuttle_turf_images

		user.client.images += to_add
		user.client.SetView(view_range)

/obj/machinery/computer/camera_advanced/shuttle_docker/remove_eye_control(mob/living/user)
	..()
	if(!QDELETED(user) && user.client)
		var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
		var/list/to_remove = list()
		to_remove += the_eye.placement_images
		to_remove += the_eye.placed_images
		if(!see_hidden)
			to_remove += SSshuttle.hidden_shuttle_turf_images

		user.client.images -= to_remove
		user.client.SetView(7)

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/placeLandingSpot()
	if(designating_target_loc || !current_user)
		return

	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	var/landing_clear = checkLandingSpot()
	if(designate_time && (landing_clear != SHUTTLE_DOCKER_BLOCKED))
		to_chat(current_user, "<span class='warning'>Targeting transit location, please wait [DisplayTimeText(designate_time)]...</span>")
		designating_target_loc = the_eye.loc
		var/wait_completed = do_after(current_user, designate_time, FALSE, designating_target_loc, TRUE, CALLBACK(src, /obj/machinery/computer/camera_advanced/shuttle_docker/proc/canDesignateTarget))
		designating_target_loc = null
		if(!current_user)
			return
		if(!wait_completed)
			to_chat(current_user, "<span class='warning'>Operation aborted.</span>")
			return
		landing_clear = checkLandingSpot()

	if(landing_clear != SHUTTLE_DOCKER_LANDING_CLEAR)
		switch(landing_clear)
			if(SHUTTLE_DOCKER_BLOCKED)
				to_chat(current_user, "<span class='warning'>Invalid transit location</span>")
			if(SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT)
				to_chat(current_user, "<span class='warning'>Unknown object detected in landing zone. Please designate another location.</span>")
		return

	if(!my_port)
		my_port = new()
		my_port.name = shuttlePortName
		my_port.id = shuttlePortId
		my_port.height = shuttle_port.height
		my_port.width = shuttle_port.width
		my_port.dheight = shuttle_port.dheight
		my_port.dwidth = shuttle_port.dwidth
		my_port.hidden = shuttle_port.hidden
		my_port.register()
	my_port.setDir(the_eye.dir)
	my_port.forceMove(locate(eyeobj.x - x_offset, eyeobj.y - y_offset, eyeobj.z))
	if(current_user.client)
		current_user.client.images -= the_eye.placed_images

	QDEL_LIST(the_eye.placed_images)

	for(var/V in the_eye.placement_images)
		var/image/I = V
		var/image/newI = image('icons/effects/alphacolors.dmi', the_eye.loc, "blue")
		newI.loc = I.loc //It is highly unlikely that any landing spot including a null tile will get this far, but better safe than sorry.
		newI.layer = ABOVE_OPEN_TURF_LAYER
		newI.plane = 0
		newI.mouse_opacity = 0
		the_eye.placed_images += newI

	if(current_user.client)
		current_user.client.images += the_eye.placed_images
		to_chat(current_user, "<span class='notice'>Transit location designated</span>")
	return

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/canDesignateTarget()
	if(!designating_target_loc || !current_user || (eyeobj.loc != designating_target_loc) || (stat & (NOPOWER|BROKEN)) )
		return FALSE
	return TRUE

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/rotateLandingSpot()
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	var/list/image_cache = the_eye.placement_images
	the_eye.setDir(turn(the_eye.dir, -90))
	for(var/i in 1 to image_cache.len)
		var/image/pic = image_cache[i]
		var/list/coords = image_cache[pic]
		var/Tmp = coords[1]
		coords[1] = coords[2]
		coords[2] = -Tmp
		pic.loc = locate(the_eye.x + coords[1], the_eye.y + coords[2], the_eye.z)
	var/Tmp = x_offset
	x_offset = y_offset
	y_offset = -Tmp
	checkLandingSpot()

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/checkLandingSpot()
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	var/turf/eyeturf = get_turf(the_eye)
	if(!eyeturf)
		return SHUTTLE_DOCKER_BLOCKED

	. = SHUTTLE_DOCKER_LANDING_CLEAR
	var/list/bounds = shuttle_port.return_coords(the_eye.x - x_offset, the_eye.y - y_offset, the_eye.dir)
	var/list/overlappers = SSshuttle.get_dock_overlap(bounds[1], bounds[2], bounds[3], bounds[4], the_eye.z)
	var/list/image_cache = the_eye.placement_images
	for(var/i in 1 to image_cache.len)
		var/image/I = image_cache[i]
		var/list/coords = image_cache[I]
		var/turf/T = locate(eyeturf.x + coords[1], eyeturf.y + coords[2], eyeturf.z)
		I.loc = T
		switch(checkLandingTurf(T, overlappers))
			if(SHUTTLE_DOCKER_LANDING_CLEAR)
				I.icon_state = "green"
			if(SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT)
				I.icon_state = "green"
				if(. == SHUTTLE_DOCKER_LANDING_CLEAR)
					. = SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT
			else
				I.icon_state = "red"
				. = SHUTTLE_DOCKER_BLOCKED

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/checkLandingTurf(turf/T, list/overlappers)
	// Too close to the map edge is never allowed
	if(!T || T.x <= 10 || T.y <= 10 || T.x >= world.maxx - 10 || T.y >= world.maxy - 10)
		return SHUTTLE_DOCKER_BLOCKED
	// If it's one of our shuttle areas assume it's ok to be there
	if(shuttle_port.shuttle_areas[T.loc])
		return SHUTTLE_DOCKER_LANDING_CLEAR
	. = SHUTTLE_DOCKER_LANDING_CLEAR
	// See if the turf is hidden from us
	var/list/hidden_turf_info
	if(!see_hidden)
		hidden_turf_info = SSshuttle.hidden_shuttle_turfs[T]
		if(hidden_turf_info)
			. = SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT

	if(space_turfs_only)
		var/turf_type = hidden_turf_info ? hidden_turf_info[2] : T.type
		if(!ispath(turf_type, /turf/space))
			return SHUTTLE_DOCKER_BLOCKED

	if(istype(T.loc.type, /area/syndicate_depot))
		return SHUTTLE_DOCKER_BLOCKED

	// Checking for overlapping dock boundaries
	for(var/i in 1 to overlappers.len)
		var/obj/docking_port/port = overlappers[i]
		if(port == my_port || locate(port) in jumpto_ports)
			continue
		var/port_hidden = !see_hidden && port.hidden
		var/list/overlap = overlappers[port]
		var/list/xs = overlap[1]
		var/list/ys = overlap[2]
		if(xs["[T.x]"] && ys["[T.y]"])
			if(port_hidden)
				. = SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT
			else
				return SHUTTLE_DOCKER_BLOCKED

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/update_hidden_docking_ports(list/remove_images, list/add_images)
	if(!see_hidden && current_user && current_user.client)
		current_user.client.images -= remove_images
		current_user.client.images += add_images

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(port && (shuttleId == initial(shuttleId) || override))
		shuttleId = port.id
		shuttlePortId = "[port.id]_custom"
	if(dock)
		jumpto_ports[dock.id] = TRUE

/mob/camera/aiEye/remote/shuttle_docker
	visible_icon = FALSE
	use_static = FALSE
	simulated = FALSE
	var/list/placement_images = list()
	var/list/placed_images = list()

/mob/camera/aiEye/remote/shuttle_docker/Initialize(mapload, obj/machinery/computer/camera_advanced/origin)
	src.origin = origin
	return ..()

/mob/camera/aiEye/remote/shuttle_docker/setLoc(T)
	if(istype(get_turf(T), /turf/space) || istype(get_area(T), /area/space) || istype(get_area(T), /area/shuttle))
		..()
		var/obj/machinery/computer/camera_advanced/shuttle_docker/console = origin
		console.checkLandingSpot()
		return
	else
		return

/mob/camera/aiEye/remote/shuttle_docker/update_remote_sight(mob/living/user)
	user.sight = SEE_TURFS

	..()
	return TRUE

/datum/action/innate/shuttledocker_rotate
	name = "Rotate"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_cycle_equip_off"

/datum/action/innate/shuttledocker_rotate/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_docker/origin = remote_eye.origin
	origin.rotateLandingSpot()

/datum/action/innate/shuttledocker_place
	name = "Place"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_zoom_off"

/datum/action/innate/shuttledocker_place/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_docker/origin = remote_eye.origin
	origin.placeLandingSpot(target)

/datum/action/innate/camera_jump/shuttle_docker
	name = "Jump to Location"
	button_icon_state = "camera_jump"

/datum/action/innate/camera_jump/shuttle_docker/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_docker/console = remote_eye.origin

	playsound(console, 'sound/machines/terminal_prompt_deny.ogg', 25, 0)

	var/list/L = list()
	for(var/V in SSshuttle.stationary)
		if(!V)
			continue
		var/obj/docking_port/stationary/S = V
		if(console.jumpto_ports[S.id])
			L[S.name] = S

	playsound(console, 'sound/machines/terminal_prompt.ogg', 25, 0)
	var/selected = input("Choose location to jump to", "Locations", null) as null|anything in L
	if(QDELETED(src) || QDELETED(target) || !isliving(target))
		return
	playsound(src, "terminal_type", 25, 0)
	if(selected)
		var/turf/T = get_turf(L[selected])
		if(T)
			playsound(console, 'sound/machines/terminal_prompt_confirm.ogg', 25, 0)
			remote_eye.setLoc(T)
			to_chat(target, "<span class='notice'>Jumped to [selected]</span>")
	else
		playsound(console, 'sound/machines/terminal_prompt_deny.ogg', 25, 0)
