/datum/event/prison_break
	startWhen		= 40
	announceWhen	= 75

	var/releaseWhen = 60
	var/list/area/areas = list()		//List of areas to affect. Filled by start()

	var/eventDept = "Security"			//Department name in announcement
	var/list/areaName = list("Brig")	//Names of areas mentioned in AI and Engineering announcements
	var/list/areaType = list(/area/station/security/prison, /area/station/security/brig, /area/station/security/permabrig)	//Area types to include.
	var/list/areaNotType = list()		//Area types to specifically exclude.

/datum/event/prison_break/virology
	eventDept = "Medical"
	areaName = list("Virology")
	areaType = list(/area/station/medical/virology)

/datum/event/prison_break/xenobiology
	eventDept = "Science"
	areaName = list("Xenobiology")
	areaType = list(/area/station/science/xenobiology)

/datum/event/prison_break/station
	eventDept = "Station"
	areaName = list("Brig","Virology","Xenobiology")
	areaType = list(/area/station/security/prison, /area/station/security/brig, /area/station/security/permabrig, /area/station/medical/virology, /area/station/medical/virology/lab, /area/station/science/xenobiology)


/datum/event/prison_break/setup()
	announceWhen = rand(75, 105)
	releaseWhen = rand(60, 90)

	src.endWhen = src.releaseWhen+2


/datum/event/prison_break/announce(false_alarm)
	if(length(areas) || false_alarm)
		GLOB.minor_announcement.Announce("[pick("Gr3y.T1d3 virus", "S.E.L.F program", "Malignant trojan", "Runtime error", "Unidentified hostile worm", "[pick("Castle", "Felix", "Fractal", "Paradox", "Rubiks", "Portcullis", "Hammer", "Lockpick", "Faust", "Dream")][pick(" 2.0","")] Daemon")] detected in [station_name()] [(eventDept == "Security")? "imprisonment":"containment"] subroutines. Secure any compromised areas immediately. Station AI involvement is recommended.", "[eventDept] Alert")

/datum/event/prison_break/start()
	for(var/area/A in world)
		if(is_type_in_list(A,areaType) && !is_type_in_list(A,areaNotType))
			areas += A

	if(areas && length(areas) > 0)
		var/my_department = "[station_name()] firewall subroutines"
		var/rc_message = "An unknown malicious program has been detected in the [english_list(areaName)] lighting and airlock control systems at [station_time_timestamp()]. Systems will be fully compromised within approximately one minute. Direct intervention is required immediately.<br>"
		for(var/obj/machinery/message_server/MS in SSmachines.get_by_type(/obj/machinery/message_server))
			MS.send_rc_message("Engineering", my_department, rc_message, "", "", RQ_HIGHPRIORITY)
	else
		stack_trace("Could not initiate grey-tide. Unable to find suitable containment area.")
		kill()

/datum/event/prison_break/tick()
	if(activeFor == releaseWhen)
		if(areas && length(areas) > 0)
			for(var/area/A in areas)
				for(var/obj/machinery/light/L in A)
					L.forced_flicker(10)

/datum/event/prison_break/end()
	for(var/area/A in shuffle(areas))
		A.prison_break()
