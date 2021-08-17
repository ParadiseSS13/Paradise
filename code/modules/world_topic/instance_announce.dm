/datum/world_topic_handler/instance_announce
	topic_key = "instance_announce"
	requires_commskey = TRUE

/datum/world_topic_handler/instance_announce/execute(list/input, key_valid)
	var/msg = input["msg"]
	to_chat(world, "<span class='boldannounce'>Attention:</span> [msg]")
