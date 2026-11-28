/datum/world_topic_handler/playerlist
	topic_key = "playerlist"

/datum/world_topic_handler/playerlist/execute(list/input, key_valid)
	var/list/keys = list()
	for(var/I in GLOB.clients)
		var/client/C = I
		if(C.holder && C.holder.fakekey)
			continue
		keys += C.key

	return json_encode(keys)
