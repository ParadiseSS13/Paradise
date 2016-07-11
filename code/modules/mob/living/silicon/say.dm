/mob/living/silicon/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	log_say("[key_name(src)] : [message]")
	if(..())
		return 1

/mob/living/silicon/robot/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	if(..())
		return 1
	if(message_mode)
		if(!is_component_functioning("radio"))
			to_chat(src, "<span class='warning'>Your radio isn't functional at this time.</span>")
			return 0
		if(message_mode == "general")
			message_mode = null
		return radio.talk_into(src,message,message_mode,verb,speaking)

/mob/living/silicon/ai/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	if(..())
		return 1
	if(message_mode == "department")
		return holopad_talk(message, verb, speaking)
	else if(message_mode)
		if(aiRadio.disabledAi || aiRestorePowerRoutine || stat)
			to_chat(src, "<span class='danger'>System Error - Transceiver Disabled.</span>")
			return 0
		if(message_mode == "general")
			message_mode = null
		return aiRadio.talk_into(src,message,message_mode,verb,speaking)

/mob/living/silicon/pai/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	if(..())
		return 1
	else if(message_mode == "whisper")
		whisper_say(message, speaking, alt_name)
		return 1
	else if(message_mode)
		if(message_mode == "general")
			message_mode = null
		return radio.talk_into(src,message,message_mode,verb,speaking)

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
/mob/living/silicon/ai/proc/holopad_talk(var/message, verb, datum/language/speaking)

	log_say("[key_name(src)] : [message]")

	message = trim(message)

	if(!message)
		return

	var/obj/machinery/hologram/holopad/T = src.holo
	if(T && T.hologram && T.master == src)//If there is a hologram and its master is the user.

		//Human-like, sorta, heard by those who understand humans.
		var/rendered_a
		//Speach distorted, heard by those who do not understand AIs.
		var/message_stars = stars(message)
		var/rendered_b

		if(speaking)
			rendered_a = "<span class='game say'><span class='name'>[name]</span> [speaking.format_message(message, verb)]</span>"
			rendered_b = "<span class='game say'><span class='name'>[voice_name]</span> [speaking.format_message(message_stars, verb)]</span>"
			to_chat(src, "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> [speaking.format_message(message, verb)]</span></i>")//The AI can "hear" its own message.

		else
			rendered_a = "<span class='game say'><span class='name'>[name]</span> [verb], <span class='message'>\"[message]\"</span></span>"
			rendered_b = "<span class='game say'><span class='name'>[voice_name]</span> [verb], <span class='message'>\"[message_stars]\"</span></span>"
			to_chat(src, "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> [verb], <span class='message'><span class='body'>\"[message]\"</span></span></span></i>")//The AI can "hear" its own message.


		for(var/mob/M in hearers(T.loc))//The location is the object, default distance.
			if(M.say_understands(src))//If they understand AI speak. Humans and the like will be able to.
				M.show_message(rendered_a, 2)
			else//If they do not.
				M.show_message(rendered_b, 2)
		/*Radios "filter out" this conversation channel so we don't need to account for them.
		This is another way of saying that we won't bother dealing with them.*/
	else
		to_chat(src, "No holopad connected.")
		return
	return 1

/mob/living/silicon/ai/proc/holopad_emote(var/message) //This is called when the AI uses the 'me' verb while using a holopad.

	log_emote("[key_name(src)] : [message]")

	message = trim(message)

	if(!message)
		return

	var/obj/machinery/hologram/holopad/T = src.holo
	if(T && T.hologram && T.master == src)
		var/rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message]</span></span>"
		to_chat(src, "<i><span class='game say'>Holopad action relayed, <span class='name'>[real_name]</span> <span class='message'>[message]</span></span></i>")

		for(var/mob/M in viewers(T.loc))
			M.show_message(rendered, 2)
	else //This shouldn't occur, but better safe then sorry.
		to_chat(src, "No holopad connected.")
		return
	return 1

/mob/living/silicon/ai/emote(var/act, var/type, var/message)
	var/obj/machinery/hologram/holopad/T = src.holo
	if(T && T.hologram && T.master == src) //Is the AI using a holopad?
		src.holopad_emote(message)
	else //Emote normally, then.
		..()

#undef IS_AI
#undef IS_ROBOT
#undef IS_PAI
