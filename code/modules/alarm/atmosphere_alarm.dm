/datum/alarm_handler/atmosphere
	category = "Atmosphere Alarms"

/datum/alarm_handler/atmosphere/triggerAlarm(var/atom/origin, var/atom/source, var/duration = 0, var/severity = 1)
	..()

/datum/alarm_handler/atmosphere/major_alarms()
	var/list/major_alarms = new()
	for(var/datum/alarm/A in alarms)
		if(A.max_severity() > 1)
			major_alarms.Add(A)
	return major_alarms

/datum/alarm_handler/atmosphere/minor_alarms()
	var/list/minor_alarms = new()
	for(var/datum/alarm/A in alarms)
		if(A.max_severity() == 1)
			minor_alarms.Add(A)
	return minor_alarms
