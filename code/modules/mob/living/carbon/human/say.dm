/mob/living/carbon/human/say(var/message)
	var/alt_name = ""

	if(name != GetVoice())
		alt_name = " (as [get_id_name("Unknown")])"

	..(message, alt_name = alt_name)	//ohgod we should really be passing a datum here.

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

/mob/living/carbon/human/say_understands(var/mob/other, var/datum/language/speaking = null)
	if(has_brain_worms()) //Brain worms translate everything. Even mice and alien speak.
		return 1

	if(species.can_understand(other))
		return 1

	//These only pertain to common. Languages are handled by mob/say_understands()
	if(!speaking)
		if(istype(other, /mob/living/simple_animal/diona))
			if(other.languages.len >= 2) //They've sucked down some blood and can speak common now.
				return 1
		if(issilicon(other))
			return 1
		if(isbot(other))
			return 1
		if(isbrain(other))
			return 1
		if(isslime(other))
			return 1

	return ..()

/mob/living/carbon/human/proc/HasVoiceChanger()
	if(istype(back,/obj/item/weapon/rig))
		var/obj/item/weapon/rig/rig = back
		if(rig.speech && rig.speech.voice_holder && rig.speech.voice_holder.active && rig.speech.voice_holder.voice)
			return rig.speech.voice_holder.voice

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

/mob/living/carbon/human/IsVocal()
	if(mind)
		return !mind.miming
	return 1

/mob/living/carbon/human/proc/SetSpecialVoice(var/new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice

/mob/living/carbon/human/handle_speech_problems(var/message, var/verb)
	var/list/returns[3]
	var/speech_problem_flag = 0

	if(silent || (disabilities & MUTE))
		message = ""
		speech_problem_flag = 1

	if(istype(wear_mask, /obj/item/clothing/mask/horsehead))
		var/obj/item/clothing/mask/horsehead/hoers = wear_mask
		if(hoers.voicechange)
			message = pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")
			verb = pick("whinnies","neighs", "says")
			speech_problem_flag = 1

	if(dna)
		for(var/datum/dna/gene/gene in dna_genes)
			if(!gene.block)
				continue
			if(gene.is_active(src))
				message = gene.OnSay(src,message)
				speech_problem_flag = 1

	if(message != "")
		var/list/parent = ..()
		message = parent[1]
		verb = parent[2]
		if(parent[3])
			speech_problem_flag = 1

		var/braindam = getBrainLoss()
		if(braindam >= 60)
			speech_problem_flag = 1
			if(prob(braindam/4))
				message = stutter(message)
				verb = "gibbers"
			if(prob(braindam))
				message = uppertext(message)
				verb = "yells loudly"

	if(locate(/obj/item/organ/internal/cyberimp/brain/clown_voice) in internal_organs)
		message = "<span class='sans'>[message]</span>"

	returns[1] = message
	returns[2] = verb
	returns[3] = speech_problem_flag
	return returns

/mob/living/carbon/human/handle_message_mode(var/message_mode, var/message, var/verb, var/speaking, var/used_radios, var/alt_name)
	switch(message_mode)
		if("intercom")
			for(var/obj/item/device/radio/intercom/I in view(1, src))
				spawn(0)
					I.talk_into(src, message, null, verb, speaking)
				used_radios += I

		if("headset")
			var/obj/item/device/radio/R = null
			if(isradio(l_ear))
				R = l_ear
				used_radios += R
				if(R.talk_into(src, message, null, verb, speaking))
					return

			if(isradio(r_ear))
				R = r_ear
				used_radios += R
				if(R.talk_into(src, message, null, verb, speaking))
					return

		if("right ear")
			var/obj/item/device/radio/R
			if(isradio(r_ear))
				R = r_ear
			else if(isradio(r_hand))
				R = r_hand
			if(R)
				used_radios += R
				R.talk_into(src, message, null, verb, speaking)

		if("left ear")
			var/obj/item/device/radio/R
			if(isradio(l_ear))
				R = l_ear
			else if(isradio(l_hand))
				R = l_hand
			if(R)
				used_radios += R
				R.talk_into(src, message, null, verb, speaking)

		if("whisper")
			whisper_say(message, speaking, alt_name)
			return 1
		else
			if(message_mode)
				if(isradio(l_ear))
					used_radios += l_ear
					if(l_ear.talk_into(src, message, message_mode, verb, speaking))
						return

				if(isradio(r_ear))
					used_radios += r_ear
					if(r_ear.talk_into(src, message, message_mode, verb, speaking))
						return

/mob/living/carbon/human/handle_speech_sound()
	var/list/returns[2]
	if(species.speech_sounds && prob(species.speech_chance))
		returns[1] = sound(pick(species.speech_sounds))
		returns[2] = 50
	return returns

/mob/living/carbon/human/binarycheck()
	. = FALSE
	var/obj/item/device/radio/headset/R
	if(istype(l_ear, /obj/item/device/radio/headset))
		R = l_ear
		if(R.translate_binary)
			. = TRUE

	if(istype(r_ear, /obj/item/device/radio/headset))
		R = r_ear
		if(R.translate_binary)
			. = TRUE