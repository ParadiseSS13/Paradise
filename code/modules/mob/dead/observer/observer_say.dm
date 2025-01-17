/mob/dead/observer/say(message)
	message = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	if(GLOB.configuration.general.enable_ooc_emoji)
		message = emoji_parse(message)

	return say_dead(message)

/mob/dead/observer/handle_track(message, verb = "says", atom/movable/speaker = null, speaker_name, atom/follow_target, hard_to_hear)
	return "[speaker_name] ([ghost_follow_link(follow_target, ghost=src)])"

/mob/dead/observer/handle_speaker_name(atom/movable/speaker = null, vname, hard_to_hear, check_name_against)
	var/speaker_name = ..()
	if(!speaker || !ismob(speaker))
		return speaker_name
	var/mob/speaker_mob = speaker
	if(is_ai(speaker_mob))
		//AI's can't pretend to be other mobs.
		return speaker_name
	if(!check_name_against || check_name_against == speaker_mob.real_name)
		return speaker_name
	speaker_name = "[speaker_mob.real_name] ([speaker_name])"
	return speaker_name
