/mob/proc/combine_message_tts(list/message_pieces, mob/speaker, always_stars = FALSE)
	var/iteration_count = 0
	var/msg = ""
	for(var/datum/multilingual_say_piece/say_piece in message_pieces)
		iteration_count++
		var/piece = say_piece.message
		if(piece == "")
			continue

		if(say_piece.speaking?.flags & INNATE) // TTS should not read emotes like "laughts"
			return ""

		if(always_stars)
			continue

		if(iteration_count == 1)
			piece = capitalize(piece)

		if(!say_understands(speaker, say_piece.speaking))
			if(isanimal(speaker))
				var/mob/living/simple_animal/S = speaker
				if(!LAZYLEN(S.speak))
					continue
				piece = pick(S.speak)
			else if(say_piece.speaking)
				piece = say_piece.speaking.scramble(piece)
			else
				continue
		msg += (piece + " ")
	return trim(msg)


/mob/combine_message(list/message_pieces, verb, mob/speaker, always_stars)
	. = ..()
	return replace_characters(., list("+"))

/mob/hear_say(list/message_pieces, verb, italics, mob/speaker, sound/speech_sound, sound_vol, sound_frequency, use_voice)
	. = ..()
	if(!can_hear())
		return

	var/message_tts = combine_message_tts(message_pieces, speaker)
	var/effect = isrobot(speaker) ? SOUND_EFFECT_ROBOT : SOUND_EFFECT_NONE
	var/traits = TTS_TRAIT_RATE_FASTER
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), speaker, src, message_tts, speaker.tts_seed, TRUE, effect, traits)

/mob/hear_radio(list/message_pieces, verb = "says", part_a, part_b, mob/speaker = null, hard_to_hear = 0, vname = "", atom/follow_target, check_name_against)
	. = ..()
	if(!can_hear())
		return

	if(src != speaker || isrobot(src) || isAI(src))
		var/effect = isrobot(speaker) ? SOUND_EFFECT_RADIO_ROBOT : SOUND_EFFECT_RADIO
		var/message_tts = combine_message_tts(message_pieces, speaker, always_stars = hard_to_hear)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), src, src, message_tts, speaker.tts_seed, FALSE, effect, null, null, 'modular_ss220/text_to_speech/code/sound/radio_chatter.ogg')

/mob/hear_holopad_talk(list/message_pieces, verb, mob/speaker, obj/effect/overlay/holo_pad_hologram/H)
	. = ..()
	if(!can_hear())
		return
	var/message_tts = combine_message_tts(message_pieces, speaker)
	var/effect = isrobot(speaker) ? SOUND_EFFECT_RADIO_ROBOT : SOUND_EFFECT_RADIO
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), H, src, message_tts, speaker.tts_seed, TRUE, effect)

/datum/announcer/Message(message, garbled_message, receivers, garbled_receivers)
	var/tts_seed = "Glados"
	if(GLOB.ai_list.len)
		var/mob/living/silicon/ai/AI = pick(GLOB.ai_list)
		tts_seed = AI.tts_seed
	var/message_tts = message
	var/garbled_message_tts = garbled_message
	message = replace_characters(message, list("+"))
	garbled_message = replace_characters(garbled_message, list("+"))
	. = ..()
	for(var/mob/M in receivers)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, M, message_tts, tts_seed, FALSE, SOUND_EFFECT_NONE, TTS_TRAIT_RATE_MEDIUM)
	for(var/mob/M in garbled_receivers)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, M, garbled_message_tts, tts_seed, FALSE, SOUND_EFFECT_NONE, TTS_TRAIT_RATE_MEDIUM)

