/datum/event/door_runtime

/datum/event/door_runtime/announce()
	GLOB.minor_announcement.Announce("Hostile runtime detected in door controllers. Isolation lockdown protocols are now in effect. Please remain calm.", "Network Alert", 'sound/AI/door_runtimes.ogg')

/datum/event/door_runtime/start()
	for(var/obj/machinery/door/D as anything in SSmachines.get_machinery_of_type(/obj/machinery/door))
		if(!is_station_level(D.z))
			continue
		INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door, hostile_lockdown))
		addtimer(CALLBACK(D, TYPE_PROC_REF(/obj/machinery/door, disable_lockdown)), 90 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 SECONDS)
	post_status(STATUS_DISPLAY_ALERT, "lockdown")

/datum/event/door_runtime/proc/reboot()
	GLOB.minor_announcement.Announce("Automatic system reboot complete. Have a secure day.","Network reset:", 'sound/AI/door_runtimes_fix.ogg')
