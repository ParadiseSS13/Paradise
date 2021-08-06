/datum/world_topic_handler/fixticker
	topic_key = "fixticker"
	requires_commskey = TRUE

/datum/world_topic_handler/fixticker/execute(list/input, key_valid)
	log_debug("SStimer.state = [SSticker.state]")
	if(SSticker.state == SS_SLEEPING)
		log_debug("SStimer.state is sleeping")
		SSticker.state = SS_IDLE
		to_chat(world, "<span class='announce'>SERVER: подсистема SSticker была восстановлена!</span>")
		return json_encode(list("success" = "SSticker was resumed"))
	return json_encode(list("error" = "SSticker state is not SS_SLEEPING"))
