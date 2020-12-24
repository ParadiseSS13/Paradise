/datum/event/door_runtime

/datum/event/door_runtime/announce()
	GLOB.minor_announcement.Announce("Hostile runtime detected in door controllers. Isolation lockdown protocols are now in effect. Please remain calm.", "Network Alert")

/datum/event/door_runtime/start()
	for(var/obj/machinery/door/D in GLOB.airlocks)
		if(!is_station_level(D.z))
			continue
		INVOKE_ASYNC(D, /obj/machinery/door.proc/hostile_lockdown)
		addtimer(CALLBACK(D, /obj/machinery/door.proc/disable_lockdown), 900)

	post_status("alert", "lockdown")
	spawn(900)
		GLOB.minor_announcement.Announce("Automatic system reboot complete. Have a secure day.","Network reset:")
