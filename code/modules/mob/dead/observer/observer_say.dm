/mob/dead/observer/say(message)
	message = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	if(GLOB.configuration.general.enable_ooc_emoji)
		message = emoji_parse(message)

	return say_dead(message)

/mob/dead/observer/handle_track(message, verb = "says", mob/speaker = null, speaker_name, atom/follow_target, hard_to_hear)
	return "[speaker_name] ([ghost_follow_link(follow_target, ghost=src)])"

/mob/dead/observer/handle_speaker_name(mob/speaker = null, vname, hard_to_hear, check_name_against)
	var/speaker_name = ..()
	if(!speaker)
		return speaker_name
	//Announce computer and various stuff that broadcasts doesn't use it's real name but AI's can't pretend to be other mobs.
	if(isAI(speaker) || isAutoAnnouncer(speaker))
		return speaker_name
	if(!check_name_against)
		check_name_against = speaker_name
	if(check_name_against == speaker.real_name)
		return speaker_name
	speaker_name = "[speaker.real_name] ([speaker_name])"
	return speaker_name
