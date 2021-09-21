/datum/world_topic_handler/queue_status
	topic_key = "queue_status"
	requires_commskey = TRUE

// This topic is sent every 10 seconds from the bouncer
/datum/world_topic_handler/queue_status/execute(list/input, key_valid)
	var/ckey_check = input["ckey_check"]

	if(!ckey_check)
		return json_encode(list("error" = "No ckey supplied"))

	var/list/output_data = list()
	output_data["queue_enabled"] = SSqueue.queue_enabled

	// Decide whether we should hold the player in queue
	// NOTE: We only queue never seen before players
	if(SSqueue.queue_enabled)
		// If they are in the bypass list, let em in
		if(ckey_check in SSqueue.queue_bypass_list)
			output_data["allow_player"] = TRUE
		else // Otherwise
			// If we have more than the threshold, queue
			if(length(GLOB.clients) > SSqueue.queue_threshold)
				output_data["allow_player"] = FALSE
			else // We have less than the threshold, allow if were in the timeframe
				if(world.time > (SSqueue.last_letin_time + 3 SECONDS))
					output_data["allow_player"] = TRUE
					SSqueue.last_letin_time = world.time
				else
					output_data["allow_player"] = FALSE

	else
		// We arent enabled. Just let them in anyway.
		output_data["allow_player"] = TRUE

	return json_encode(output_data)
