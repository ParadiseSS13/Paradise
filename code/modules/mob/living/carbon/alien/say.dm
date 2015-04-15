/mob/living/carbon/alien/say(var/message)
	var/verb = "says"
	var/message_range = world.view

	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (Muted)."
			return

	message = trim_strip_html_properly(message)

	if(stat == 2)
		return say_dead(message)

	if(copytext(message,1,2) == "*")
		return emote(copytext(message,2))

	var/needtohack = 1 //hacky way to get around stupid byond shit
	var/datum/language/speaking = parse_language(message)

	if(speaking == null)
		var/quickcheck = get_default_language()
		if(quickcheck == null)
			speaking = all_languages["Xenomorph"] //this is the hackiest thing, no clue how to avoid it
			needtohack = 0
		else
			speaking = get_default_language()
			needtohack = 0

	if(speaking)
		if(needtohack)
			message = copytext(message,2+length(speaking.key))

	var/ending = copytext(message, length(message))
	if (speaking)
		// This is broadcast to all mobs with the language,
		// irrespective of distance or anything else.
		if(speaking.flags & HIVEMIND)
			speaking.broadcast(src,trim(message))
			return
		//If we've gotten this far, keep going!
		verb = speaking.get_spoken_verb(ending)

	message = trim(message)

	if(!message || stat)
		return

	..(message, speaking, verb, null, null, message_range, null)