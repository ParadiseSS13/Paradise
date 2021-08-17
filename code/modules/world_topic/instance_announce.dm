/datum/world_topic_handler/instance_announce
	topic_key = "instance_announce"
	requires_commskey = TRUE

/datum/world_topic_handler/instance_announce/execute(list/input, key_valid)
	var/msg = input["msg"]
	if(input["repoll"]) // Repoll peers
		UNTIL(!SSinstancing.check_running) // If we are running, wait
		SSinstancing.check_peers(TRUE) // Manually check, with FORCE
		UNTIL(!SSinstancing.check_running) // Wait for completion

	// Now that we repolled, we can tell the playerbase
	to_chat(world, "<center><span class='boldannounce'><big>Attention</big></span></center><hr>[msg]<hr>")
	SEND_SOUND(world, sound('sound/misc/notice2.ogg')) // Same as captains priority announce
