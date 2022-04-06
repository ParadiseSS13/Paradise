/mob/dead/observer/say(message)
	message = sanitize(copytext(message, 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	return say_dead(message)


/mob/dead/observer/emote(act, type, message, force)
	message = sanitize(copytext(message, 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	if(act != "me")
		return

	log_ghostemote(message, src)

	if(src.client)
		if(check_mute(client.ckey, MUTE_DEADCHAT))
			to_chat(src, "<span class='warning'>You cannot emote in deadchat (muted).</span>")
			return

		if(src.client.handle_spam_prevention(message, MUTE_DEADCHAT))
			return

	. = src.emote_dead(message)

/mob/dead/observer/handle_track(message, verb = "says", mob/speaker = null, speaker_name, atom/follow_target, hard_to_hear)
	return "[speaker_name] ([ghost_follow_link(follow_target, ghost=src)])"

/mob/dead/observer/handle_speaker_name(mob/speaker = null, vname, hard_to_hear)
	var/speaker_name = ..()
	if(speaker && (speaker_name != speaker.real_name) && !isAI(speaker) && !istype(speaker, /mob/living/automatedannouncer)) //Announce computer and various stuff that broadcasts doesn't use it's real name but AI's can't pretend to be other mobs.
		speaker_name = "[speaker.real_name] ([speaker_name])"
	return speaker_name
