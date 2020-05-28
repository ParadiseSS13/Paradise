/mob/living/carbon/human/say(var/message, var/sanitize = TRUE, var/ignore_speech_problems = FALSE, var/ignore_atmospherics = FALSE)
	..(message, sanitize = sanitize, ignore_speech_problems = ignore_speech_problems, ignore_atmospherics = ignore_atmospherics)	//ohgod we should really be passing a datum here.

/mob/living/carbon/human/GetAltName()
	if(name != GetVoice())
		return " (as [get_id_name("Unknown")])"
	return ..()

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

	if(dna.species.can_understand(other))
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
	if(istype(back, /obj/item/rig))
		var/obj/item/rig/rig = back
		if(rig.speech && rig.speech.voice_holder && rig.speech.voice_holder.active && rig.speech.voice_holder.voice)
			return rig.speech.voice_holder.voice

	for(var/obj/item/gear in list(wear_mask, wear_suit, head))
		if(!gear)
			continue

		var/obj/item/voice_changer/changer = locate() in gear
		if(changer && changer.active)
			if(changer.voice)
				return changer.voice
			else if(wear_id)
				var/obj/item/card/id/idcard = wear_id.GetID()
				if(istype(idcard))
					return idcard.registered_name

	return FALSE

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
	var/obj/item/organ/internal/cyberimp/brain/speech_translator/translator = locate(/obj/item/organ/internal/cyberimp/brain/speech_translator) in internal_organs
	if(translator && translator.active)
		return TRUE
	// how do species that don't breathe talk? magic, that's what.
	var/breathes = (!(NO_BREATHE in dna.species.species_traits))
	var/obj/item/organ/internal/L = get_organ_slot("lungs")
	if((breathes && !L) || breathes && L && (L.status & ORGAN_DEAD))
		return FALSE
	if(getOxyLoss() > 10 || losebreath >= 4)
		emote("gasp")
		return FALSE
	if(mind)
		return !mind.miming
	return TRUE

/mob/living/carbon/human/proc/SetSpecialVoice(var/new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice

/mob/living/carbon/human/handle_speech_problems(list/message_pieces, var/verb)
	var/span = ""
	var/obj/item/organ/internal/cyberimp/brain/speech_translator/translator = locate(/obj/item/organ/internal/cyberimp/brain/speech_translator) in internal_organs
	if(translator)
		if(translator.active)
			span = translator.speech_span
			for(var/datum/multilingual_say_piece/S in message_pieces)
				S.message = "<span class='[span]'>[S.message]</span>"
			verb = translator.speech_verb
			return list("verb" = verb)
	if(mind)
		span = mind.speech_span
	if((COMIC in mutations) \
		|| (locate(/obj/item/organ/internal/cyberimp/brain/clown_voice) in internal_organs) \
		|| GetComponent(/datum/component/jestosterone))
		span = "sans"

	if(WINGDINGS in mutations)
		span = "wingdings"

	var/list/parent = ..()
	verb = parent["verb"]

	for(var/datum/multilingual_say_piece/S in message_pieces)
		if(S.speaking && S.speaking.flags & NO_STUTTER)
			continue

		if(silent || (disabilities & MUTE))
			S.message = ""

		if(istype(wear_mask, /obj/item/clothing/mask/horsehead))
			var/obj/item/clothing/mask/horsehead/hoers = wear_mask
			if(hoers.voicechange)
				S.message = pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")
				verb = pick("whinnies", "neighs", "says")

		if(dna)
			for(var/datum/dna/gene/gene in GLOB.dna_genes)
				if(!gene.block)
					continue
				if(gene.is_active(src))
					S.message = gene.OnSay(src, S.message)

		var/braindam = getBrainLoss()
		if(braindam >= 60)
			if(prob(braindam / 4))
				S.message = stutter(S.message)
				verb = "gibbers"
			if(prob(braindam))
				S.message = uppertext(S.message)
				verb = "yells loudly"

		if(span)
			S.message = "<span class='[span]'>[S.message]</span>"
	return list("verb" = verb)

/mob/living/carbon/human/handle_message_mode(var/message_mode, list/message_pieces, var/verb, var/used_radios)
	switch(message_mode)
		if("intercom")
			for(var/obj/item/radio/intercom/I in view(1, src))
				spawn(0)
					I.talk_into(src, message_pieces, null, verb)
				used_radios += I

		if("headset")
			var/obj/item/radio/R = null
			if(isradio(l_ear))
				R = l_ear
				used_radios += R
				if(R.talk_into(src, message_pieces, null, verb))
					return

			if(isradio(r_ear))
				R = r_ear
				used_radios += R
				if(R.talk_into(src, message_pieces, null, verb))
					return

		if("right ear")
			var/obj/item/radio/R
			if(isradio(r_ear))
				R = r_ear
			else if(isradio(r_hand))
				R = r_hand
			if(R)
				used_radios += R
				R.talk_into(src, message_pieces, null, verb)

		if("left ear")
			var/obj/item/radio/R
			if(isradio(l_ear))
				R = l_ear
			else if(isradio(l_hand))
				R = l_hand
			if(R)
				used_radios += R
				R.talk_into(src, message_pieces, null, verb)

		if("whisper")
			whisper_say(message_pieces)
			return 1
		else
			if(message_mode)
				if(isradio(l_ear))
					used_radios += l_ear
					if(l_ear.talk_into(src, message_pieces, message_mode, verb))
						return

				if(isradio(r_ear))
					used_radios += r_ear
					if(r_ear.talk_into(src, message_pieces, message_mode, verb))
						return

/mob/living/carbon/human/handle_speech_sound()
	var/list/returns[3]
	if(dna.species.speech_sounds && prob(dna.species.speech_chance))
		returns[1] = sound(pick(dna.species.speech_sounds))
		returns[2] = 50
		returns[3] = get_age_pitch()
	return returns

/mob/living/carbon/human/binarycheck()
	. = FALSE
	var/obj/item/radio/headset/R
	if(istype(l_ear, /obj/item/radio/headset))
		R = l_ear
		if(R.translate_binary)
			. = TRUE

	if(istype(r_ear, /obj/item/radio/headset))
		R = r_ear
		if(R.translate_binary)
			. = TRUE
