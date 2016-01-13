//Lallander was here
/mob/living/carbon/human/whisper(message as text)
	var/alt_name = ""

	if(name != GetVoice())
		alt_name = "(as [get_id_name("Unknown")])"

	message = trim_strip_html_properly(message) //bit of duplicate code, acceptable because the workaround would be annoying

	//parse the language code and consume it
	var/datum/language/speaking = parse_language(message)
	if(speaking)
		message = copytext(message, 2 + length(speaking.key))
	else
		speaking = get_default_language()

	// This is broadcast to all mobs with the language,
	// irrespective of distance or anything else.
	if(speaking && (speaking.flags & HIVEMIND))
		speaking.broadcast(src,trim(message))
		return 1

	message = trim_left(message)
	message = handle_autohiss(message, speaking)

	whisper_say(message, speaking, alt_name)