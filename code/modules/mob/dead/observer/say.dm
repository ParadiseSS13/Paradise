/mob/dead/observer/say(var/message)
	message = sanitize(copytext(message, 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	log_say("Ghost/[src.key] : [message]")

	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, "\red You cannot talk in deadchat (muted).")
			return

		if (src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	if(copytext(message,1,2) == "*")
		return emote(copytext(message,2))

	. = src.say_dead(message)

