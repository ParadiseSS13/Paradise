/datum/world_topic_handler/status
	topic_key = "status"

/datum/world_topic_handler/status/execute(list/input, key_valid)
	var/list/status_info = list()
	status_info["version"] = GLOB.revision_info.commit_hash
	status_info["mode"] = GLOB.master_mode
	status_info["respawn"] = GLOB.configuration.general.respawn_enabled
	status_info["enter"] = GLOB.enter_allowed
	status_info["ai"] = GLOB.configuration.jobs.allow_ai
	status_info["host"] = world.host ? world.host : null
	status_info["players"] = list()
	status_info["roundtime"] = worldtime2text()
	status_info["stationtime"] = station_time_timestamp()
	status_info["oldstationtime"] = classic_worldtime2text() // more "consistent" indication of the round's running time
	status_info["listed"] = "Public"
	if(!world.hub_password)
		status_info["listed"] = "Invisible"
	var/player_count = 0
	var/admin_count = 0

	for(var/client/C in GLOB.clients)
		if(C.holder)
			if(C.holder.fakekey)
				continue	//so stealthmins aren't revealed by the hub
			admin_count++
		player_count++
	status_info["players"] = player_count
	status_info["admins"] = admin_count
	status_info["map_name"] = SSmapping.map_datum.fluff_name
	status_info["round_id"] = GLOB.round_id

	// Export performance metrics
	status_info["perfmetrics"] = list(
		"td" = list(
			"time_dilation_current" = SStime_track.time_dilation_current,
			"time_dilation_avg_fast" = SStime_track.time_dilation_avg_fast,
			"time_dilation_avg" = SStime_track.time_dilation_avg,
			"time_dilation_avg_slow" = SStime_track.time_dilation_avg_slow
		),
		"mcpu" = world.map_cpu,
		"cpu" = world.cpu
	)


	// Add more info if we are authed
	if(key_valid)
		if(SSticker.mode)
			status_info["real_mode"] = SSticker.mode.name
			status_info["security_level"] = SSsecurity_level.get_current_level_as_text()
			status_info["ticker_state"] = SSticker.current_state

		if(SSshuttle.emergency)
			// Shuttle status, see /__DEFINES/stat.dm
			status_info["shuttle_mode"] = SSshuttle.emergency.mode
			// Shuttle timer, in seconds
			status_info["shuttle_timer"] = SSshuttle.emergency.timeLeft()

	return json_encode(status_info)
