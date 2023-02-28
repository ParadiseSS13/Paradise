/datum/world_topic_handler/fixtts
	topic_key = "fixtts"
	requires_commskey = TRUE

/datum/world_topic_handler/fixtts/execute(list/input, key_valid)
	var/datum/tts_provider/silero = SStts.tts_providers["Silero"]
	log_debug("SStts.tts_providers\[Silero].is_enabled = [silero.is_enabled]")

	if(!silero.is_enabled)
		silero.is_enabled = TRUE
		silero.failed_requests_limit += initial(silero.failed_requests_limit)
		to_chat(world, "<span class='announce'>SERVER: провайдер Silero в подсистеме SStts принудительно включен!</span>")
		return json_encode(list("success" = "SStts\[Silero] was force enabled"))
	return json_encode(list("error" = "SStts\[Silero] is already enabled"))
