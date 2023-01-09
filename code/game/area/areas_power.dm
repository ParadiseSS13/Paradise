///**ALL POWER RELATED PROCS AND CODE DEFINED ON THE /area LEVEL**///

/**
  * Generate a power alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  */
/area/proc/poweralert(state, obj/source)
	if(state == poweralm)
		return
	poweralm = state
	if(!istype(source))	//Only report power alarms on the z-level where the source is located.
		return
	for(var/thing in cameras)
		var/obj/machinery/camera/C = locateUID(thing)
		if(!QDELETED(C) && is_station_level(C.z))
			if(state)
				C.network -= "Power Alarms"
			else
				C.network |= "Power Alarms"

	if(state)
		SSalarm.cancelAlarm("Power", src, source)
	else
		SSalarm.triggerAlarm("Power", src, cameras, source)


/**
  * Called when the area power status changes
  *
  * Updates the area icon
  */

