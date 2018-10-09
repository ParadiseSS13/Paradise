/mob/living/silicon/robot/drone/say(var/message, var/datum/language/speaking = null)
	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

	if(!speaking)
		speaking = parse_language(message)
		if(!speaking)
			speaking = istype(get_default_language(), /datum/language) ? get_default_language() : all_languages[get_default_language()]
			message = speaking.key + " " + message; // Prepend key to prevent the message from getting trimmed
	if(speaking)
		return ..()

/mob/living/silicon/robot/drone/whisper_say(var/message, var/datum/language/speaking = null, var/verb="whispers")
	say(message) //drones do not get to whisper, only speak normally
	return 1