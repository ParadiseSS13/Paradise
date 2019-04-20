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

/obj/machinery/door/airlock/onShuttleMove()
	. = ..()
	if(!.)
		return
	INVOKE_ASYNC(src, .proc/close, 0, 1)
	// Close any nearby airlocks as well
	for(var/obj/machinery/door/airlock/D in orange(1, src))
		INVOKE_ASYNC(D, .proc/close, 0, 1)

/obj/machinery/door/airlock/onShuttleMove()
	. = ..()
	if(id_tag == "s_docking_airlock")
		INVOKE_ASYNC(src, .proc/lock)

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
		queue_smooth(src)

/obj/machinery/door/airlock/postDock(obj/docking_port/stationary/S1)
	. = ..()
	if(!S1.lock_shuttle_doors && id_tag == "s_docking_airlock")
		INVOKE_ASYNC(src, .proc/unlock)