/mob/camera/flock/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, range)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, span_boldwarning("You cannot send IC messages (muted)."))
			return
		if (!(ignore_spam || forced) && src.client.handle_spam_prevention(message,MUTE_IC))
			return

	flock_talk(src, message, flock)

/mob/camera/flock/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, atom/sound_loc, message_range)
	. = ..()

	var/translated_message = translate_speech(speaker, message_language, raw_message, spans, message_mods)

	// Create map text prior to modifying message for goonchat
	if (client?.prefs.read_preference(/datum/preference/toggle/enable_runechat) && (client.prefs.read_preference(/datum/preference/toggle/enable_runechat_non_mobs) || ismob(speaker)))
		create_chat_message(speaker, message_language, translated_message, spans, sound_loc = sound_loc)

	// A little hack, if the speaker is a flock drone from our flock, we just assume we heard their message in flocksay too.
	// So we wont output their message.
	if(isflockdrone(speaker))
		var/mob/living/basic/flock/drone/bird = speaker
		if(bird.flock == flock)
			return

	// Recompose the message, because it's scrambled by default
	message = compose_message(speaker, message_language, translated_message, radio_freq, spans, message_mods)
	to_chat(src,
		html = "[message]",
		avoid_highlighting = speaker == src
	)

/proc/flock_talk(atom/speaker, message, datum/flock/flock, involuntary, list/inner_spans)

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if (!message)
		return

	if(inner_spans)
		message = attach_spans(message, inner_spans)

	var/used_name = ""
	var/list/spans = list("flocksay")

	var/mob/mob_speaker
	if(ismob(speaker))
		mob_speaker = speaker

	// Get spans
	if(istype(speaker, /mob/camera/flock))
		spans += "sentient"
		if(istype(speaker, /mob/camera/flock/overmind))
			spans += "flockmind"

	else if(istype(speaker, /mob/living/basic/flock/drone))
		var/mob/living/basic/flock/drone/bird_drone = speaker
		if(!bird_drone.controlled_by)
			spans += "flocknpc"

	else
		spans += "bold"
		spans += "italics"

	// Get name
	if(isnull(mob_speaker))
		used_name = "\[SYSTEM\]"

	else if(istype(speaker, /mob/living/basic/flock/drone))
		var/mob/living/basic/flock/drone/bird_drone = speaker
		if(!bird_drone.controlled_by)
			used_name = "Drone [bird_drone.real_name]"
		else
			used_name = "[bird_drone.controlled_by.real_name] as [bird_drone]"

	else if(istype(speaker, /mob/camera/flock))
		var/mob/camera/flock/overmind/ghost_bird = speaker
		used_name = ghost_bird.real_name

	var/silicon_message = stars(message, 50)
	if(mob_speaker)
		var/say_verb = pick("sings", "clicks", "whistles", "intones", "transmits", "submits", "uploads")
		message = "[say_verb], \"[message]\""
		silicon_message = "[say_verb], \"[silicon_message]\""
	else
		message = "alerts, [gradient_text(message, "#3cb5a3", "#124e43")]"
		silicon_message = "alerts, [gradient_text(silicon_message, "#3cb5a3", "#124e43")]"

	var/flock_message = "<span class='game say [jointext(spans, " ")]'><span class='bold'>\[[flock ? flock.name : "--.--"]\]</span> [span_name("[used_name]")] <span class='message'>[message]</span></span>"
	silicon_message = "<span class='game say [jointext(spans, " ")]'><span class='bold'>\[?????\]</span> [span_name("[used_name]")] <span class='message'>[silicon_message]</span></span>"

	for(var/mob/player as anything in GLOB.player_list)
		if(isflockmob(player))
			to_chat(player, flock_message)
			continue

		if(isobserver(player) && !involuntary)
			to_chat(player, flock_message)
			continue

		if(player.can_hear() && player.binarycheck() && (!involuntary && speaker || prob(30)))
			to_chat(player, silicon_message)
			continue
