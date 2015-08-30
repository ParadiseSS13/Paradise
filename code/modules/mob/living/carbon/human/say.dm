/mob/living/carbon/human/say(var/message)

	var/verb = "says"
	var/alt_name = ""
	var/message_range = world.view
	var/italics = 0

	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (Muted)."
			return

	message = trim_strip_html_properly(message)

	if(stat)
		if(stat == 2)
			return say_dead(message)
		return

	if (is_muzzled())
		src << "<span class='danger'>You're muzzled and cannot speak!</span>"
		return

	var/message_mode = parse_message_mode(message, "headset")

	if(copytext(message,1,2) == "*")
		return emote(copytext(message,2))

	if(name != GetVoice())
		alt_name = " (as [get_id_name("Unknown")])"

	//parse the radio code and consume it
	if (message_mode)
		if (message_mode == "headset")
			message = copytext(message,2)	//it would be really nice if the parse procs could do this for us.
		else
			message = copytext(message,3)

	//parse the language code and consume it
	var/datum/language/speaking = parse_language(message)
	if(speaking)
		message = copytext(message,2+length(speaking.key))
	else
		speaking = get_default_language()

	var/ending = copytext(message, length(message))
	if (speaking)
		// This is broadcast to all mobs with the language,
		// irrespective of distance or anything else.
		if(speaking.flags & HIVEMIND)
			speaking.broadcast(src,trim(message))
			return
		//If we've gotten this far, keep going!
		verb = speaking.get_spoken_verb(ending)
	else
		if(ending=="!")
			verb=pick("exclaims","shouts","yells")
		if(ending=="?")
			verb="asks"

	message = trim(message)

	if(speech_problem_flag)
		var/list/handle_r = handle_speech_problems(message)
		message = handle_r[1]
		verb = handle_r[2]
		speech_problem_flag = handle_r[3]

	if(!message || message == "")
		return

	var/list/obj/item/used_radios = new

	switch (message_mode)
		if("headset")
			if(l_ear && istype(l_ear,/obj/item/device/radio))
				var/obj/item/device/radio/R = l_ear
				R.talk_into(src,message,null,verb,speaking)
				used_radios += l_ear
			else if(r_ear && istype(r_ear,/obj/item/device/radio))
				var/obj/item/device/radio/R = r_ear
				R.talk_into(src,message,null,verb,speaking)
				used_radios += r_ear

		if("right ear")
			var/obj/item/device/radio/R
			var/has_radio = 0
			if(r_ear && istype(r_ear,/obj/item/device/radio))
				R = r_ear
				has_radio = 1
			if(r_hand && istype(r_hand, /obj/item/device/radio))
				R = r_hand
				has_radio = 1
			if(has_radio)
				R.talk_into(src,message,null,verb,speaking)
				used_radios += R


		if("left ear")
			var/obj/item/device/radio/R
			var/has_radio = 0
			if(l_ear && istype(l_ear,/obj/item/device/radio))
				R = l_ear
				has_radio = 1
			if(l_hand && istype(l_hand,/obj/item/device/radio))
				R = l_hand
				has_radio = 1
			if(has_radio)
				R.talk_into(src,message,null,verb,speaking)
				used_radios += R

		if("intercom")
			for(var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, message, verb, speaking)
				used_radios += I
		if("whisper")
			whisper_say(message, speaking, alt_name)
			return
		else
			if(message_mode)
				if(l_ear && istype(l_ear,/obj/item/device/radio))
					l_ear.talk_into(src,message, message_mode, verb, speaking)
					used_radios += l_ear
				else if(r_ear && istype(r_ear,/obj/item/device/radio))
					r_ear.talk_into(src,message, message_mode, verb, speaking)
					used_radios += r_ear

	var/sound/speech_sound
	var/sound_vol
	if(species.speech_sounds && prob(species.speech_chance))
		speech_sound = sound(pick(species.speech_sounds))
		sound_vol = 50

	//speaking into radios
	if(used_radios.len)
		italics = 1
		message_range = 1
		if(speaking)
			message_range = speaking.get_talkinto_msg_range(message)
		var/msg
		if(!speaking || !(speaking.flags & NO_TALK_MSG))
			msg = "<span class='notice'>\The [src] talks into \the [used_radios[1]]</span>"
		for(var/mob/living/M in hearers(5, src))
			if((M != src) && msg)
				M.show_message(msg)
			if (speech_sound)
				sound_vol *= 0.5

	..(message, speaking, verb, alt_name, italics, message_range, speech_sound, sound_vol)	//ohgod we should really be passing a datum here.

/mob/living/carbon/human/proc/forcesay(list/append)
	if(stat == CONSCIOUS)
		if(client)
			var/virgin = 1	//has the text been modified yet?
			var/temp = winget(client, "input", "text")
			if(findtextEx(temp, "Say \"", 1, 7) && length(temp) > 5)	//case sensitive means

				temp = replacetext(temp, ";", "")	//general radio

				if(findtext(trim_left(temp), ":", 6, 7))	//dept radio
					temp = copytext(trim_left(temp), 8)
					virgin = 0

				if(virgin)
					temp = copytext(trim_left(temp), 6)	//normal speech
					virgin = 0

				while(findtext(trim_left(temp), ":", 1, 2))	//dept radio again (necessary)
					temp = copytext(trim_left(temp), 3)

				if(findtext(temp, "*", 1, 2))	//emotes
					return
				temp = copytext(trim_left(temp), 1, rand(5,8))

				var/trimmed = trim_left(temp)
				if(length(trimmed))
					if(append)
						temp += pick(append)

					say(temp)
				winset(client, "input", "text=[null]")

/mob/living/carbon/human/say_understands(var/mob/other,var/datum/language/speaking = null)

	if(has_brain_worms()) //Brain worms translate everything. Even mice and alien speak.
		return 1

	if(species.can_understand(other))
		return 1

	//These only pertain to common. Languages are handled by mob/say_understands()
	if (!speaking)
		if (istype(other, /mob/living/simple_animal/diona))
			if(other.languages.len >= 2) //They've sucked down some blood and can speak common now.
				return 1
		if (istype(other, /mob/living/silicon))
			return 1
		if (istype(other, /mob/living/carbon/brain))
			return 1
		if (istype(other, /mob/living/carbon/slime))
			return 1

	//This is already covered by mob/say_understands()
	//if (istype(other, /mob/living/simple_animal))
	//	if((other.universal_speak && !speaking) || src.universal_speak || src.universal_understand)
	//		return 1
	//	return 0

	return ..()
	
/mob/living/carbon/human/proc/HasVoiceChanger()
	for(var/obj/item/gear in list(wear_mask,wear_suit,head))
		if(!gear)
			continue
		var/obj/item/voice_changer/changer = locate() in gear
		if(changer && changer.active && changer.voice)
			return changer.voice
	return 0
		
/mob/living/carbon/human/GetVoice()
	var/has_changer = HasVoiceChanger()
	if(has_changer)
		return has_changer
	if(mind && mind.changeling && mind.changeling.mimicing)
		return mind.changeling.mimicing
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return real_name

/mob/living/carbon/human/proc/SetSpecialVoice(var/new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice


/*
   ***Deprecated***
   let this be handled at the hear_say or hear_radio proc
   This is left in for robot speaking when humans gain binary channel access until I get around to rewriting
   robot_talk() proc.
   There is no language handling build into it however there is at the /mob level so we accept the call
   for it but just ignore it.
*/

/mob/living/carbon/human/say_quote(var/message, var/datum/language/speaking = null)
	var/verb = "says"
	var/ending = copytext(message, length(message))

	if(speaking)
		verb = speaking.get_spoken_verb(ending)
	else
		if(ending == "!")
			verb = "exclaims"
		else if(ending == "?")
			verb = "asks"

	return verb

/mob/living/carbon/human/proc/handle_speech_problems(var/message)

	var/list/returns[3]
	var/verb = "says"
	var/handled = 0
	if(silent || (sdisabilities & MUTE))
		message = ""
		handled = 1
	if(istype(wear_mask, /obj/item/clothing/mask/horsehead))
		var/obj/item/clothing/mask/horsehead/hoers = wear_mask
		if(hoers.voicechange)
			if(mind && mind.changeling && department_radio_keys[copytext(message, 1, 3)] != "changeling")
				message = pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")
				verb = pick("whinnies","neighs", "says")
				handled = 1

	if(dna)
		for(var/datum/dna/gene/gene in dna_genes)
			if(!gene.block)
				continue
			if(gene.is_active(src))
				message = gene.OnSay(src,message)
				handled = 1

	if(message != "")
		if((HULK in mutations) && health >= 25 && length(message))
			message = "[uppertext(message)]!!!"
			verb = pick("yells","roars","hollers")
			handled = 1
		if(slurring)
			message = slur(message)
			verb = "slurs"
			handled = 1
		if(stuttering)
			message = stutter(message)
			verb = "stammers"
			handled = 1

		var/braindam = getBrainLoss()
		if(braindam >= 60)
			handled = 1
			if(prob(braindam/4))
				message = stutter(message)
				verb = "gibbers"
			if(prob(braindam))
				message = uppertext(message)
				verb = "yells loudly"

		if(COMIC in mutations)
			message = "<span class='sans'>[message]</span>"
	returns[1] = message
	returns[2] = verb
	returns[3] = handled
	return returns
