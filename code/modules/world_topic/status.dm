/datum/world_topic_handler/status
	topic_key = "status"

/datum/world_topic_handler/status/execute(list/input, key_valid)
	var/list/status_info = list()
	var/list/admins = list()
	status_info["version"] = GLOB.revision_info.commit_hash
	status_info["mode"] = GLOB.master_mode
	status_info["respawn"] = GLOB.abandon_allowed
	status_info["enter"] = GLOB.enter_allowed
	status_info["vote"] = config.allow_vote_mode
	status_info["ai"] = config.allow_ai
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
			admins += list(list(C.key, C.holder.rank))
		player_count++
	status_info["players"] = player_count
	status_info["admins"] = admin_count
	status_info["map_name"] = SSmapping.map_datum.fluff_name

	// Add more info if we are authed
	if(key_valid)
		if(SSticker && SSticker.mode)
			status_info["real_mode"] = SSticker.mode.name
			status_info["security_level"] = get_security_level()
			status_info["ticker_state"] = SSticker.current_state

		if(SSshuttle && SSshuttle.emergency)
			// Shuttle status, see /__DEFINES/stat.dm
			status_info["shuttle_mode"] = SSshuttle.emergency.mode
			// Shuttle timer, in seconds
			status_info["shuttle_timer"] = SSshuttle.emergency.timeLeft()

		for(var/i in 1 to admins.len)
			var/list/A = admins[i]
			status_info["admin[i - 1]"] = A[1]
			status_info["adminrank[i - 1]"] = A[2]

	return json_encode(status_info)
