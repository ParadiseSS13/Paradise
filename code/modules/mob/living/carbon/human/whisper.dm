//Lallander was here
/mob/living/carbon/human/whisper(message as text)
	message = trim_strip_html_properly(message) //bit of duplicate code, acceptable because the workaround would be annoying

	//parse the language code and consume it
	var/list/message_pieces = parse_languages(message)
	if(istype(message_pieces, /datum/multilingual_say_piece)) // Little quirk to just easily deal with HIVEMIND languages
		var/datum/multilingual_say_piece/S = message_pieces // Yay BYOND's hilarious typecasting
		S.speaking.broadcast(src, S.message)
		return 1

	message = trim_left(message)
	whisper_say(message, message_pieces)