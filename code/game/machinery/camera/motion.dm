/obj/machinery/camera/process()
	// motion camera event loop
	if(!isMotion())
		. = PROCESS_KILL
		return
	if(stat & (EMPED|NOPOWER))
		return
	if(detectTime > 0)
		var/elapsed = world.time - detectTime
		if(elapsed > alarm_delay)
			triggerAlarm()
	else if(detectTime == -1)
		for(var/thing in getTargetList())
			var/mob/target = locateUID(thing)
			if(QDELETED(target) || target.stat == DEAD || (!area_motion && (!(get_dist(src, target) <= view_range) || !(target in hearers(view_range, get_turf(src))))))
				//If not part of a monitored area and the camera is not in range or the target is dead
				lostTargetRef(thing)

/obj/machinery/camera/proc/getTargetList()
	if(area_motion)
		return area_motion.motionTargets
	return localMotionTargets

/obj/machinery/camera/proc/newTarget(mob/target)
	if(is_ai(target))
		return FALSE
	if(isbot(target)) //No armsky, you don't get to set off the motion alarm constantly
		return FALSE
	if(!area_motion && (!(get_dist(src, target) <= view_range) || !(target in hearers(view_range, get_turf(src)))))
		return FALSE
	if(detectTime == 0)
		detectTime = world.time // start the clock
	var/list/targets = getTargetList()
	targets |= target.UID()
	return TRUE

/obj/machinery/camera/proc/lostTargetRef(uid)
	var/list/targets = getTargetList()
	targets -= uid
	if(!length(targets))
		cancelAlarm()

/obj/machinery/camera/proc/cancelAlarm()
	if(detectTime == -1)
		if(status)
			GLOB.alarm_manager.cancel_alarm("Motion", get_area(src), src)
	detectTime = 0
	return TRUE

/obj/machinery/camera/proc/triggerAlarm()
	if(!detectTime)
		return FALSE
	if(status)
		var/area/A = get_area(src)
		GLOB.alarm_manager.trigger_alarm("Motion", A, A.cameras, src)
		visible_message("<span class='warning'>A red light flashes on [src]!</span>")
	detectTime = -1
	return TRUE

/obj/machinery/camera/HasProximity(atom/movable/AM)
	// Motion cameras outside of an "ai monitored" area will use this to detect stuff.
	if(!area_motion)
		if(isliving(AM))
			newTarget(AM)

