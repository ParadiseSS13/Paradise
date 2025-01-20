// Signals for /mob/living

/mob/living/CanPass(atom/movable/mover, border_dir)
	if(SEND_SIGNAL(src, COMSIG_LIVING_CAN_PASS, mover, border_dir) & COMPONENT_LIVING_PASSABLE)
		return TRUE
	return ..()

/mob/living/Life(seconds, times_fired)
	SEND_SIGNAL(src, COMSIG_LIVING_LIFE, seconds, times_fired)
	. = ..()

/mob/living/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(SEND_SIGNAL(src, COMSIG_LIVING_HANDLE_MESSAGE_MODE, message_mode, message_pieces, verb, used_radios) & COMPONENT_FORCE_WHISPER)
		whisper_say(message_pieces)
		return TRUE
	. = ..()

/mob/living/carbon/human/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(SEND_SIGNAL(src, COMSIG_LIVING_HANDLE_MESSAGE_MODE, message_mode, message_pieces, verb, used_radios) & COMPONENT_FORCE_WHISPER)
		whisper_say(message_pieces)
		return TRUE
	. = ..()

// Да, костыльно, но модульно по другому не вижу как - PIXEL_SHIFT
/mob/living/Process_Spacemove(movement_dir)
	if(SEND_SIGNAL(src, COMSIG_LIVING_PROCESS_SPACEMOVE, movement_dir) & COMPONENT_BLOCK_SPACEMOVE)
		return FALSE
	. = ..()

/mob/living/say(message, verb, sanitize, ignore_speech_problems, ignore_atmospherics, ignore_languages, automatic)
	SEND_SIGNAL(src, COMSIG_MOB_SAY, args)
	. = ..()
