var/global/datum/repository/air_alarm/air_alarm_repository = new()

/datum/repository/air_alarm/proc/air_alarm_data(var/list/monitored_alarms, var/refresh = 0, var/obj/machinery/alarm/passed_alarm)
	var/alarms[0]

	var/datum/cache_entry/cache_entry = cache_data
	if(!cache_entry)
		cache_entry = new/datum/cache_entry
		cache_data = cache_entry

	if(!refresh)
		return cache_entry.data

	if(ticker && ticker.current_state < GAME_STATE_PLAYING && istype(passed_alarm)) // Generating the list for the first time as the game hasn't started - no need to run through the machines list everything every time 
		alarms = cache_entry.data // Don't deleate the list
		if(is_station_contact(passed_alarm.z)) // Still need sanity checks
15 			alarms[++alarms.len] = passed_alarm.get_nano_data_console() 
16 	else 
17 		for(var/obj/machinery/alarm/alarm in (monitored_alarms ? monitored_alarms : air_alarms)) // Generating the whole list again is a bad habit but I can't be bothered to fix it right now
18 			if(!monitored_alarms && !is_station_contact(alarm.z)) 
19 				continue 
20 			alarms[++alarms.len] = alarm.get_nano_data_console() 


	cache_entry.timestamp = world.time //+ 10 SECONDS
	cache_entry.data = alarms
	return alarms

/datum/repository/air_alarm/proc/update_cache(var/obj/machinery/alarm/alarm)
	return air_alarm_data(refresh = 1, passed_alarm = alarm)
