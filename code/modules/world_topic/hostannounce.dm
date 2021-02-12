/datum/world_topic_handler/hostannounce
	topic_key = "hostannounce"
	requires_commskey = TRUE

/datum/world_topic_handler/hostannounce/execute(list/input, key_valid)
	GLOB.pending_server_update = TRUE
	to_chat(world, "<hr><span style='color: #12A5F4'><b>Server Announcement:</b> [input["message"]]</span><hr>")
