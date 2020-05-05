/datum/event/temperature_change
	startWhen = 12
	announceWhen = 3
	endWhen = 160
	var/temperature = 373.15

/datum/event/temperature_change/start()
	alarm_controller()

/datum/event/temperature_change/announce()
	GLOB.event_announcement.Announce("Major failure detected within the ventilation system. Strange temperature changes expected within the next minutes.", "Atmospheric Alert")

/datum/event/temperature_change/end()
	alarm_controller(T20C)
	GLOB.event_announcement.Announce("Temperature failure cleared, report to medbay if you feel unwell.", "Atmospheric Alert")

/datum/event/temperature_change/proc/alarm_controller(var/temp = temperature)
	for(var/obj/machinery/alarm/A in GLOB.air_alarms)
		if(!is_station_contact(A.z))
			continue

		for(var/turf/T in get_area_turfs(A.alarm_area))
			if(istype(T, /turf/simulated))
				var/turf/simulated/S = T
				if(S.air)
					S.air.temperature = temp
					A.target_temperature = S.air.temperature
					S.air_update_turf()
	return
