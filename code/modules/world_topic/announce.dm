/datum/world_topic_handler/announce
	topic_key = "announce"
	requires_commskey = TRUE

/datum/world_topic_handler/announce/execute(list/input, key_valid)
	var/prtext = input["announce"]
	var/pr_substring = copytext(prtext, 1, 23)
	if(pr_substring == "Pull Request merged by")
		GLOB.pending_server_update = TRUE
	for(var/client/C in GLOB.clients)
		to_chat(C, "<span class='announce'>PR: [prtext]</span>")
