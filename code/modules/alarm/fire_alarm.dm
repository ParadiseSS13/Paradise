/datum/alarm_handler/fire
	category = "Fire Alarms"

/datum/alarm_handler/fire/on_alarm_change(var/datum/alarm/alarm, var/was_raised)
	var/area/A = alarm.origin
	if(istype(A))
		if(was_raised)
			A.fire_alert()
		else
			A.fire_reset()
	..()
