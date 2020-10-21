#define AIR_ALARM_DATA_CACHE_DURATION 10 SECONDS

GLOBAL_DATUM_INIT(air_alarm_repository, /datum/repository/air_alarm, new())

/datum/repository/air_alarm/proc/air_alarm_data(list/monitored_alarms, refresh = FALSE, obj/machinery/alarm/passed_alarm, target_z = null)
	var/list/alarms = list()

	var/datum/cache_entry/cache_entry = cache_data
	if(!cache_entry)
		cache_entry = new/datum/cache_entry
		cache_data = cache_entry

	if(!refresh && cache_entry.timestamp + AIR_ALARM_DATA_CACHE_DURATION > world.time)
		return cache_entry.data

	if(SSticker && SSticker.current_state < GAME_STATE_PLAYING && istype(passed_alarm)) // Generating the list for the first time as the game hasn't started - no need to run through the machines list everything every time
		alarms = cache_entry.data // Don't deleate the list
		if(is_station_contact(passed_alarm.z) && passed_alarm.remote_control) // Still need sanity checks
			alarms[++alarms.len] = passed_alarm.get_console_data()
	else
		for(var/obj/machinery/alarm/alarm in (monitored_alarms ? monitored_alarms : GLOB.air_alarms)) // Generating the whole list again is a bad habit but I can't be bothered to fix it right now
			if(!monitored_alarms && !is_station_contact(alarm.z))
				continue
			// We only care about checking target Z if its actually set
			if(target_z && (alarm.z != target_z))
				continue
			if(!alarm.remote_control)
				continue
			alarms[++alarms.len] = alarm.get_console_data()

	cache_entry.timestamp = world.time //+ 10 SECONDS
	cache_entry.data = alarms
	return alarms

/datum/repository/air_alarm/proc/update_cache(obj/machinery/alarm/alarm)
	return air_alarm_data(refresh = 1, passed_alarm = alarm)

#undef AIR_ALARM_DATA_CACHE_DURATION
