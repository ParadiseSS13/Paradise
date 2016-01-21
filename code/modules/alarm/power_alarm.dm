/datum/alarm_handler/power
	category = "Power Alarms"

/datum/alarm_handler/power/on_alarm_change(var/datum/alarm/alarm, var/was_raised)
	var/area/A = alarm.origin
	if(istype(A))
		A.power_alert(was_raised)
	..()

/area/proc/power_alert(var/alarming)
