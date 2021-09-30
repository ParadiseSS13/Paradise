/datum/world_topic_handler/ping
	topic_key = "ping"

/datum/world_topic_handler/ping/execute(list/input, key_valid)
	/*
		Basically a more efficient version of

		if("ping" in input)
			var/x = 1
			for(var/client/C)
				x++
			return x
	*/
	return length(GLOB.clients) + 1
