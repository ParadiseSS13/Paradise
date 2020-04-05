/mob/living/silicon/robot/drone/say(var/message)
	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

	return ..()

/mob/living/silicon/robot/drone/whisper_say(list/message_pieces)
	say(multilingual_to_message(message_pieces)) //drones do not get to whisper, only speak normally
	return 1

/mob/living/silicon/robot/drone/get_default_language()
	if(default_language)
		return default_language
	return GLOB.all_languages["Drone"]
