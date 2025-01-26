/mob/combine_message(list/message_pieces, verb, mob/speaker, always_stars)
	. = ..()
	return replace_characters(., list("+"))

/mob/hear_say(list/message_pieces, verb, italics, mob/speaker, sound/speech_sound, sound_vol, sound_frequency, use_voice)
	. = ..()
	if(!speaker)
		return
	speaker.cast_tts(src, message_pieces)

/mob/hear_radio(list/message_pieces, verb, part_a, part_b, mob/speaker, hard_to_hear = 0, vname, atom/follow_target, check_name_against)
	. = ..()
	if(hard_to_hear || !speaker)
		return
	speaker.cast_tts(src, message_pieces, src, FALSE, SOUND_EFFECT_RADIO, postSFX = 'modular_ss220/text_to_speech/code/sound/radio_chatter.ogg')

/mob/hear_holopad_talk(list/message_pieces, verb, mob/speaker, obj/effect/overlay/holo_pad_hologram/H)
	. = ..()
	speaker.cast_tts(src, message_pieces, H, TRUE, SOUND_EFFECT_RADIO)

/atom/atom_say(message)
	. = ..()
	if(!message)
		return
	for(var/mob/M in get_mobs_in_view(7, src))
		cast_tts(M, message)
