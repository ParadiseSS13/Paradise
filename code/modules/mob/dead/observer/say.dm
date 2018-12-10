/mob/dead/observer/say(var/message)
	message = sanitize(copytext(message, 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	log_ghostsay(message, src)

	if(src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, "<span class='warning'>You cannot talk in deadchat (muted).</span>")
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

	log_ghostemote(message, src)

	if(src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, "<span class='warning'>You cannot emote in deadchat (muted).</span>")
			return

		if(src.client.handle_spam_prevention(message, MUTE_DEADCHAT))
			return

	. = src.emote_dead(message)

/mob/dead/observer/handle_track(var/message, var/verb = "says", var/mob/speaker = null, var/speaker_name, var/atom/follow_target, var/hard_to_hear)
	return "[speaker_name] ([ghost_follow_link(follow_target, ghost=src)])"

/mob/dead/observer/handle_speaker_name(var/mob/speaker = null, var/vname, var/hard_to_hear)
	var/speaker_name = ..()
	if(speaker && (speaker_name != speaker.real_name) && !isAI(speaker)) //Announce computer and various stuff that broadcasts doesn't use it's real name but AI's can't pretend to be other mobs.
		speaker_name = "[speaker.real_name] ([speaker_name])"
	return speaker_name