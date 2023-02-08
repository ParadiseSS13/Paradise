/mob/living/silicon/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	add_say_logs(src, multilingual_to_message(message_pieces))
	if(..())
		return 1

/mob/living/silicon/robot/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(..())
		return 1
	if(message_mode)
		used_radios += radio
		if(!is_component_functioning("radio"))
			to_chat(src, "<span class='warning'>Your radio isn't functional at this time.</span>")
			return 0
		if(message_mode == "general")
			message_mode = null
		return radio.talk_into(src,message_pieces,message_mode,verb)

/mob/living/silicon/ai/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(..())
		return 1
	if(message_mode == "department")
		used_radios += aiRadio
		return holopad_talk(message_pieces, verb)
	else if(message_mode)
		used_radios += aiRadio
		if(aiRadio.disabledAi || aiRestorePowerRoutine || stat)
			to_chat(src, "<span class='danger'>System Error - Transceiver Disabled.</span>")
			return 0
		if(message_mode == "general")
			message_mode = null
		return aiRadio.talk_into(src, message_pieces, message_mode, verb)

/mob/living/silicon/pai/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(..())
		return 1
	else if(message_mode == "whisper")
		whisper_say(message_pieces)
		return 1
	else if(message_mode)
		if(message_mode == "general")
			message_mode = null
		used_radios += radio
		return radio.talk_into(src, message_pieces, message_mode, verb)

/mob/living/silicon/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if(ending == "?")
		return speak_query
	else if(ending == "!")
		return speak_exclamation

	return speak_statement

#define IS_AI 1
#define IS_ROBOT 2
#define IS_PAI 3

/mob/living/silicon/say_understands(var/other,var/datum/language/speaking = null)
	//These only pertain to common. Languages are handled by mob/say_understands()
	if(!speaking)
		if(istype(other, /mob/living/carbon))
			return 1
		if(istype(other, /mob/living/silicon))
			return 1
		if(istype(other, /mob/living/simple_animal/bot))
			return 1
		if(istype(other, /mob/living/carbon/brain))
			return 1
	return ..()

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(list/message_pieces, verb)
	add_say_logs(src, multilingual_to_message(message_pieces), language = "HPAD")

	var/obj/machinery/hologram/holopad/T = current
	if(istype(T) && T.masters[src])
		var/obj/effect/overlay/holo_pad_hologram/H = T.masters[src]
		var/message = combine_message(message_pieces, null, src)
		var/message_verbed = combine_message(message_pieces, verb, src)
		var/message_tts = message
		message = replace_characters(message, list("+"))
		message_verbed = replace_characters(message_verbed, list("+"))
		if ((client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT) && can_hear())
			create_chat_message(H, message, TRUE, FALSE)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, H, src, message_tts, tts_seed, FALSE, SOUND_EFFECT_NONE)
		log_debug("holopad_talk(): [message]")
		for(var/mob/M in hearers(T.loc))//The location is the object, default distance.
			M.hear_holopad_talk(message_pieces, verb, src, H)
		to_chat(src, "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> [message_verbed]</span></i>")
	else
		to_chat(src, "No holopad connected.")
		return
	return 1

/mob/living/silicon/ai/proc/holopad_emote(var/message) //This is called when the AI uses the 'me' verb while using a holopad.
	message = trim(message)

	if(!message)
		return

	var/obj/machinery/hologram/holopad/T = current
	if(istype(T) && T.masters[src])
		var/rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message]</span></span>"
		to_chat(src, "<i><span class='game say'>Holopad action relayed, <span class='name'>[real_name]</span> <span class='message'>[message]</span></span></i>")

		for(var/mob/M in viewers(T.loc))
			M.show_message(rendered, 2)

		add_emote_logs(src, "(HPAD) [message]")
	else //This shouldn't occur, but better safe then sorry.
		to_chat(src, "No holopad connected.")
		return
	return 1

/mob/living/silicon/ai/emote(act, type, message, force)
	var/obj/machinery/hologram/holopad/T = current
	if(istype(T) && T.masters[src])//Is the AI using a holopad?
		src.holopad_emote(message)
	else //Emote normally, then.
		..()

#undef IS_AI
#undef IS_ROBOT
#undef IS_PAI
