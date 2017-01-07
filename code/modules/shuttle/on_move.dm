// Shuttle on-movement //
/atom/movable/proc/onShuttleMove(turf/T1, rotation)
    if(rotation)
        shuttleRotate(rotation)
    forceMove(T1)
    return 1

/atom/movable/lighting_overlay/onShuttleMove()
    return 0

/obj/effect/landmark/shuttle_import/onShuttleMove()
    // Used for marking where to preview/load shuttles
    return 0

/obj/docking_port/onShuttleMove()
    // Stationary ports shouldn't move, mobile ones move themselves
    return 0

/obj/machinery/door/onShuttleMove()
    . = ..()
    if(!.)
        return
    addtimer(src, "close", 0, TRUE, 0, 1)
    // Close any nearby airlocks as well
    for(var/obj/machinery/door/D in orange(1, src))
        addtimer(D, "close", 0, TRUE, 0, 1)

/obj/machinery/door/airlock/onShuttleMove()
    . = ..()
    if(id_tag == "s_docking_airlock")
        addtimer(src, "lock", 0, TRUE)

/mob/onShuttleMove()
    if(!move_on_shuttle)
        return 0
    . = ..()
    if(!.)
        return
    if(client)
        if(buckled)
            shake_camera(src, 2, 1) // turn it down a bit come on
        else
            shake_camera(src, 7, 1)

/mob/living/carbon/onShuttleMove()
    . = ..()
    if(!.)
        return
    if(!buckled)
        Weaken(3)

// After docking //
/atom/proc/postDock(obj/docking_port/S1)
	if(smooth)
		smooth_icon(src)

/obj/machinery/door/airlock/postDock(obj/docking_port/stationary/S1)
	. = ..()
	if(!S1.lock_shuttle_doors && id_tag == "s_docking_airlock")
		addtimer(src, "unlock", 0, TRUE)

// Shuttle Rotation //
/atom/proc/shuttleRotate(rotation)
	//rotate our direction
	dir = angle2dir(rotation+dir2angle(dir))

	//rotate the pixel offsets too.
	if(pixel_x || pixel_y)
		if(rotation < 0)
			rotation += 360
		for(var/turntimes=rotation/90;turntimes>0;turntimes--)
			var/oldPX = pixel_x
			var/oldPY = pixel_y
			pixel_x = oldPY
			pixel_y = (oldPX*(-1))
