/mob/living/simple_animal/slime/say_quote(text, datum/language/speaking)
	var/verb = "blorbles"
	var/ending = copytext(text, length(text))

	if(ending == "?")
		verb = "inquisitively blorbles"
	else if(ending == "!")
		verb = "loudly blorbles"

	return verb

/mob/living/simple_animal/slime/hear_say(list/message_pieces, verb = "says", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol)
	if(speaker != src && !stat)
		if(speaker in Friends)
			speech_buffer = list()
			speech_buffer.Add(speaker)
			speech_buffer.Add(lowertext(html_decode(multilingual_to_message(message_pieces))))
	..()
