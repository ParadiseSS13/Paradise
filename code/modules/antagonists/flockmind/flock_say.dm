/mob/camera/flock/say(message)
	if(!message)
		return
	flock_talk(src, message, flock)

/proc/flock_talk(atom/speaker, message, datum/flock/flock)

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if (!message)
		return

	var/datum/language/symphonic = GLOB.all_languages["Symphonic"]
	symphonic.broadcast(speaker, message)
