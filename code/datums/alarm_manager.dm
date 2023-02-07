GLOBAL_DATUM_INIT(alarm_manager, /datum/alarm_manager, new())

/datum/alarm_manager
	var/list/alarms = list(
		"Motion" = list(),
		"Fire" = list(),
		"Atmosphere" = list(),
		"Power" = list(),
		"Burglar" = list()
	)

/datum/alarm_manager/proc/trigger_alarm(class, area/A, list/O, obj/alarmsource)
	var/list/L = alarms[class]
	for(var/I in L)
		if(I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if(!(alarmsource.UID() in sources))
				sources += alarmsource.UID()
			return TRUE
	L[A.name] = list(get_area_name(A, TRUE), O, list(alarmsource.UID()))
	SEND_SIGNAL(GLOB.alarm_manager, COMSIG_TRIGGERED_ALARM, class, A, O, alarmsource)
	return TRUE

/datum/alarm_manager/proc/cancel_alarm(class, area/A, obj/origin)
	var/list/L = alarms[class]
	var/cleared = FALSE
	for(var/I in L)
		if(I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			srcs -= origin.UID()
			if(!length(srcs))
				cleared = TRUE
				L -= I

	SEND_SIGNAL(GLOB.alarm_manager, COMSIG_CANCELLED_ALARM, class, A, origin, cleared)
