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

/mob/living/carbon/slime/hear_say(var/message, var/verb = "says", var/datum/language/language = null, var/alt_name = "", var/italics = 0, var/mob/speaker = null, var/sound/speech_sound, var/sound_vol)
	if(speaker in Friends)
		speech_buffer = list()
		speech_buffer.Add(speaker)
		speech_buffer.Add(lowertext(html_decode(message)))
	..()

/mob/living/carbon/slime/hear_radio(var/message, var/verb="says", var/datum/language/language=null, var/part_a, var/part_b, var/mob/speaker = null, var/hard_to_hear = 0, var/vname ="", var/atom/follow_target)
	if(speaker in Friends)
		speech_buffer = list()
		speech_buffer.Add(speaker)
		speech_buffer.Add(lowertext(html_decode(message)))
	..()
