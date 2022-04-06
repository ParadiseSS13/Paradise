/datum/world_topic_handler/announce
	topic_key = "announce"
	requires_commskey = TRUE

/datum/world_topic_handler/announce/execute(list/input, key_valid)
	var/prtext = input["announce"]
	for(var/client/C in GLOB.clients)
		to_chat(C, "<span class='announce'>PR: [prtext]</span>")
