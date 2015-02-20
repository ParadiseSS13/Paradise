/mob/living/carbon/slime/say(var/message)
	var/verb = say_quote(message)

	if(copytext(message,1,2) == "*")
		return emote(copytext(message,2))

	return ..(message, null, verb)

/mob/living/carbon/slime/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "telepathically asks";
	else if (ending == "!")
		return "telepathically cries";

	return "telepathically chirps";

/mob/living/carbon/slime/say_understands(var/other)
	if (istype(other, /mob/living/carbon/slime))
		return 1
	return ..()

