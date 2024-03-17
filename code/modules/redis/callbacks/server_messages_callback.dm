/datum/redis_callback/server_messages
	channel = SERVER_MESSAGES_REDIS_CHANNEL

/datum/redis_callback/server_messages/on_message(message)
	#ifdef MULTIINSTANCE
	// Decode
	var/list/data = json_decode(message)
	// And fire
	SSinstancing.execute_command(data["src"], data["cmd"], data["args"])
	#endif
	return // we need this so that the proc isnt empty when on non-multi-instance
