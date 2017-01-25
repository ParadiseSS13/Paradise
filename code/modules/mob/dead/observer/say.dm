/mob/dead/observer/say(var/message)
	message = sanitize(copytext(message, 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	log_say("Ghost/[src.key] : [message]")

	if(src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, "\red You cannot talk in deadchat (muted).")
			return

		if(src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	. = src.say_dead(message)


/mob/dead/observer/emote(var/act, var/type, var/message)
	message = sanitize(copytext(message, 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	if(act != "me")
		return

	log_emote("Ghost/[src.key] : [message]")

	if(src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, "\red You cannot emote in deadchat (muted).")
			return

		if(src.client.handle_spam_prevention(message, MUTE_DEADCHAT))
			return

	. = src.emote_dead(message)
