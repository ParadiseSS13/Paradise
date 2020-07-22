/obj/machinery/camera

	var/list/motionTargets = list()
	var/detectTime = 0
	var/area/ai_monitored/area_motion = null
	var/alarm_delay = 100


/obj/machinery/camera/process()
	// motion camera event loop
	if(stat & (EMPED|NOPOWER))
		return
	if(!isMotion())
		. = PROCESS_KILL
		return
	if(detectTime > 0)
		var/elapsed = world.time - detectTime
		if(elapsed > alarm_delay)
			triggerAlarm()
	else if(detectTime == -1)
		for(var/mob/target in motionTargets)
			if(target.stat == 2) lostTarget(target)
			// If not detecting with motion camera...
			if(!area_motion)
				// See if the camera is still in range
				if(!in_range(src, target))
					// If they aren't in range, lose the target.
					lostTarget(target)

/obj/machinery/camera/proc/newTarget(var/mob/target)
	if(istype(target, /mob/living/silicon/ai)) return 0
	if(detectTime == 0)
		detectTime = world.time // start the clock
	if(!(target in motionTargets))
		motionTargets += target
	return 1

/obj/machinery/camera/proc/lostTarget(var/mob/target)
	if(target in motionTargets)
		motionTargets -= target
	if(motionTargets.len == 0)
		cancelAlarm()

/obj/machinery/camera/proc/cancelAlarm()
	if(!status || (stat & NOPOWER))
		return FALSE
	if(detectTime == -1 && is_station_contact(z))
		SSalarms.motion_alarm.clearAlarm(loc, src)
	detectTime = 0
	return TRUE

/obj/machinery/camera/proc/triggerAlarm()
	if(!status || (stat & NOPOWER))
		return FALSE
	if(!detectTime || !is_station_contact(z))
		return FALSE
	SSalarms.motion_alarm.triggerAlarm(loc, src)
	detectTime = -1
	return TRUE

/obj/machinery/camera/HasProximity(atom/movable/AM as mob|obj)
	// Motion cameras outside of an "ai monitored" area will use this to detect stuff.
	if(!area_motion)
		if(isliving(AM))
			newTarget(AM)

