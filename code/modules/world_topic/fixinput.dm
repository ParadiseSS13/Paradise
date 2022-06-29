/datum/world_topic_handler/fixinput
	topic_key = "fixinput"
	requires_commskey = TRUE

/datum/world_topic_handler/fixinput/execute(list/input, key_valid)
	log_debug("SSinput.state = [SSinput.state]")
	if(SSinput.state == SS_SLEEPING)
		log_debug("SSinput.state is sleeping")
		SSinput.state = SS_IDLE
		to_chat(world, "<span class='announce'>SERVER: подсистема SSinput была восстановлена!</span>")
		return json_encode(list("success" = "SSinput was resumed"))
	return json_encode(list("error" = "SSinput state is not SS_SLEEPING"))
