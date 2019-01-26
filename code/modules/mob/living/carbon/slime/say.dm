/mob/living/carbon/slime/say_quote(var/text, var/datum/language/speaking)
	var/verb = "telepathically chirps"
	var/ending = copytext(text, length(text))

	if(ending == "?")
		verb = "telepathically asks"
	else if(ending == "!")
		verb = "telepathically cries"

	return verb

/mob/living/carbon/slime/say_understands(var/other)
	if(istype(other, /mob/living/carbon/slime))
		return 1
	return ..()

/mob/living/carbon/slime/hear_say(list/message_pieces, var/verb = "says", var/italics = 0, var/mob/speaker = null, var/sound/speech_sound, var/sound_vol)
	if(speaker in Friends)
		speech_buffer = list()
		speech_buffer.Add(speaker)
		speech_buffer.Add(lowertext(html_decode(multilingual_to_message(message_pieces))))
	..()

/mob/living/carbon/slime/hear_radio(list/message_pieces, var/verb="says", var/part_a, var/part_b, var/mob/speaker = null, var/hard_to_hear = 0, var/vname ="", var/atom/follow_target)
	if(speaker in Friends)
		speech_buffer = list()
		speech_buffer.Add(speaker)
		speech_buffer.Add(lowertext(html_decode(multilingual_to_message(message_pieces))))
	..()
