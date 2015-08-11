var/global/datum/repository/air_alarm/air_alarm_repository = new()

/datum/repository/air_alarm/proc/air_alarm_data(var/list/monitored_alarms)
	var/alarms[0]
	
	var/datum/cache_entry/cache_entry = cache_data
	if(!cache_entry)
		cache_entry = new/datum/cache_entry
		cache_data = cache_entry

	if(world.time < cache_entry.timestamp)
		return cache_entry.data

	for(var/obj/machinery/alarm/alarm in sortAtom((monitored_alarms.len ? monitored_alarms : machines)))
		if(!monitored_alarms.len && alarm.z != ZLEVEL_STATION && alarm.z != ZLEVEL_ASTEROID)
			continue
		alarms[++alarms.len] = alarm.get_nano_data_console()
		
	cache_entry.timestamp = world.time + 10 SECONDS
	cache_entry.data = alarms		
	return alarms

