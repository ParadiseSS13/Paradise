SUBSYSTEM_DEF(alarm)
	name = "Alarm"
	flags = SS_NO_INIT | SS_NO_FIRE
	var/list/alarms = list("Motion" = list(), "Fire" = list(), "Atmosphere" = list(), "Power" = list(), "Camera" = list(), "Burglar" = list())

/datum/controller/subsystem/alarm/proc/triggerAlarm(class, area/A, list/O, obj/alarmsource)
	var/list/L = alarms[class]
	for(var/I in L)
		if(I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if(!(alarmsource.UID() in sources))
				sources += alarmsource.UID()
			return TRUE
	L[A.name] = list(get_area_name(A, TRUE), O, list(alarmsource.UID()))
	SEND_SIGNAL(SSalarm, COMSIG_TRIGGERED_ALARM, class, A, O, alarmsource)
	return TRUE

/datum/controller/subsystem/alarm/proc/cancelAlarm(class, area/A, obj/origin)
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

	SEND_SIGNAL(SSalarm, COMSIG_CANCELLED_ALARM, class, A, origin, cleared)
