// At minimum every mob has a hear_say proc.

/mob/proc/combine_message(var/list/message_pieces, var/verb, var/mob/speaker, always_stars = FALSE)
	var/iteration_count = 0
	var/msg = "" // This is to make sure that the pieces have actually added something
	. = "[verb], \""
	for(var/datum/multilingual_say_piece/SP in message_pieces)
		iteration_count++
		var/piece = SP.message
		if(piece == "")
			continue

		if(SP.speaking && SP.speaking.flags & INNATE) // Fucking snowflake noise lang
			return SP.speaking.format_message(piece)

		if(iteration_count == 1)
			piece = capitalize(piece)

		if(SP.speaking)
			if(!say_understands(speaker, SP.speaking))
				if(isanimal(speaker))
					var/mob/living/simple_animal/S = speaker
					if(LAZYLEN(S.speak))
						piece = pick(S.speak)
					else
						piece = stars(piece)
				else
					piece = SP.speaking.scramble(piece)
			if(always_stars)
				piece = stars(piece)
			piece = SP.speaking.format_message(piece)
		else
			if(!say_understands(speaker, null))
				piece = stars(piece)
				if(isanimal(speaker))
					var/mob/living/simple_animal/S = speaker
					if(LAZYLEN(S.speak))
						piece = pick(S.speak)
				if(always_stars)
					piece = stars(piece)
			piece = "<span class='message'><span class='body'>[piece]</span></span>"
		msg += (piece + " ")
	if(msg == "")
		// There is literally no content left in this message, we need to shut this shit down
		. = "" // hear_say will suppress it
	else
		. = trim(. + trim(msg))
		. += "\""

/mob/proc/hear_say(var/list/message_pieces, var/verb = "says", var/italics = 0, var/mob/speaker = null, var/sound/speech_sound, var/sound_vol)
	if(!client)
		return 0

	if(isobserver(src) && client.prefs.toggles & CHAT_GHOSTEARS)
		if(speaker && !speaker.client && !(speaker in view(src)))
			//Does the speaker have a client?  It's either random stuff that observers won't care about (Experiment 97B says, 'EHEHEHEHEHEHEHE')
			//Or someone snoring.  So we make it where they won't hear it.
			return 0

	//make sure the air can transmit speech - hearer's side
	var/turf/T = get_turf(src)
	if(T && !isobserver(src))
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = environment ? environment.return_pressure() : 0
		if(pressure < SOUND_MINIMUM_PRESSURE && get_dist(speaker, src) > 1)
			return 0

		if(pressure < ONE_ATMOSPHERE * 0.4) //sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
			italics = 1
			sound_vol *= 0.5

	if(sleeping || stat == UNCONSCIOUS)
		hear_sleep(multilingual_to_message(message_pieces))
		return 0

	var/speaker_name = speaker.name
	if(ishuman(speaker))
		var/mob/living/carbon/human/H = speaker
		speaker_name = H.GetVoice()

	var/message = combine_message(message_pieces, verb, speaker)
	if(message == "")
		return

	if(italics)
		message = "<i>[message]</i>"

	var/track = null
	if(isobserver(src))
		if(italics && client.prefs.toggles & CHAT_GHOSTRADIO)
			return
		if(speaker_name != speaker.real_name && speaker.real_name)
			speaker_name = "[speaker.real_name] ([speaker_name])"
		track = "([ghost_follow_link(speaker, ghost=src)]) "
		if(client.prefs.toggles & CHAT_GHOSTEARS && speaker in view(src))
			message = "<b>[message]</b>"

	if(!can_hear())
		// INNATE is the flag for audible-emote-language, so we don't want to show an "x talks but you cannot hear them" message if it's set
		// if(!language || !(language.flags & INNATE))
		if(speaker == src)
			to_chat(src, "<span class='warning'>You cannot hear yourself speak!</span>")
		else
			to_chat(src, "<span class='name'>[speaker_name]</span>[speaker.GetAltName()] talks but you cannot hear [speaker.p_them()].")
	else
		to_chat(src, "<span class='game say'><span class='name'>[speaker_name]</span>[speaker.GetAltName()] [track][message]</span>")
		if(speech_sound && (get_dist(speaker, src) <= world.view && src.z == speaker.z))
			var/turf/source = speaker? get_turf(speaker) : get_turf(src)
			src.playsound_local(source, speech_sound, sound_vol, 1)


/mob/proc/hear_radio(list/message_pieces, verb = "says", part_a, part_b, mob/speaker = null, hard_to_hear = 0, vname = "", atom/follow_target)
	if(!client)
		return

	if(sleeping || stat == UNCONSCIOUS) //If unconscious or sleeping
		hear_sleep(multilingual_to_message(message_pieces))
		return

	var/message = combine_message(message_pieces, verb, speaker, always_stars = hard_to_hear)
	if(message == "")
		return

	var/track = null
	if(!follow_target)
		follow_target = speaker

	var/speaker_name = handle_speaker_name(speaker, vname, hard_to_hear)
	track = handle_track(message, verb, speaker, speaker_name, follow_target, hard_to_hear)

	if(!can_hear())
		if(prob(20))
			to_chat(src, "<span class='warning'>You feel your headset vibrate but can hear nothing from it!</span>")
	else if(track)
		to_chat(src, "[part_a][track][part_b][message]</span></span>")
	else
		to_chat(src, "[part_a][speaker_name][part_b][message]</span></span>")

/mob/proc/handle_speaker_name(mob/speaker = null, vname, hard_to_hear)
	var/speaker_name = "unknown"
	if(speaker)
		speaker_name = speaker.name

	if(vname)
		speaker_name = vname

	if(hard_to_hear)
		speaker_name = "unknown"

	return speaker_name

/mob/proc/handle_track(message, verb = "says", mob/speaker = null, speaker_name, atom/follow_target, hard_to_hear)
	return

/mob/proc/hear_sleep(message)
	var/heard = ""
	if(prob(15))
		message = strip_html_properly(message)
		var/list/punctuation = list(",", "!", ".", ";", "?")
		var/list/messages = splittext(message, " ")
		if(messages.len > 0)
			var/R = rand(1, messages.len)
			var/heardword = messages[R]
			if(copytext(heardword,1, 1) in punctuation)
				heardword = copytext(heardword,2)
			if(copytext(heardword,-1) in punctuation)
				heardword = copytext(heardword,1,lentext(heardword))
			heard = "<span class='game say'>...<i>You hear something about<i>... '[heardword]'...</span>"
		else
			heard = "<span class='game say'>...<i>You almost hear something...</i>...</span>"
	else
		heard = "<span class='game say'>...<i>You almost hear someone talking</i>...</span>"

	to_chat(src, heard)

/mob/proc/hear_holopad_talk(list/message_pieces, var/verb = "says", var/mob/speaker = null)
	var/message = combine_message(message_pieces, verb, speaker)

	var/name = speaker.name
	if(!say_understands(speaker))
		name = speaker.voice_name

	var/rendered = "<span class='game say'><span class='name'>[name]</span> [message]</span>"
	to_chat(src, rendered)