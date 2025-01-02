/mob/living/carbon/human/say(message, sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE)
	..(message, sanitize = sanitize, ignore_speech_problems = ignore_speech_problems, ignore_atmospherics = ignore_atmospherics)	//ohgod we should really be passing a datum here.

/mob/living/carbon/human/GetAltName()
	if(name != GetVoice())
		return " (as [get_id_name("Unknown")])"
	return ..()

/mob/living/carbon/human/say_understands(atom/movable/other, datum/language/speaking = null)
	if(dna.species.can_understand(other))
		return TRUE

	//These only pertain to common. Languages are handled by mob/say_understands()
	if(!speaking && ismob(other))
		if(isnymph(other))
			var/mob/nymph = other
			if(length(nymph.languages) >= 2) //They've sucked down some blood and can speak common now.
				return TRUE
		if(issilicon(other))
			return TRUE
		if(isbot(other))
			return TRUE
		if(isbrain(other))
			return TRUE
		if(isslime(other))
			return TRUE

	return ..()

/mob/living/carbon/human/proc/HasVoiceChanger()
	var/datum/status_effect/magic_disguise/S = has_status_effect(/datum/status_effect/magic_disguise)
	if(S && S.disguise && S.disguise.name)
		return S.disguise.name
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
	if(HAS_TRAIT(src, TRAIT_UNKNOWN))
		return "Unknown"

	var/has_changer = HasVoiceChanger()

	if(has_changer)
		return has_changer

	if(mind)
		var/datum/antagonist/antagonist_status = mind.has_antag_datum(/datum/antagonist)
		if(antagonist_status?.mimicking)
			return antagonist_status.mimicking

	if(GetSpecialVoice())
		return GetSpecialVoice()

	return real_name

/mob/living/carbon/human/IsVocal()
	var/obj/item/organ/internal/cyberimp/brain/speech_translator/translator = locate(/obj/item/organ/internal/cyberimp/brain/speech_translator) in internal_organs
	if(translator && translator.active)
		return TRUE
	// how do species that don't breathe talk? magic, that's what.
	var/breathes = (!HAS_TRAIT(src, TRAIT_NOBREATH))
	var/datum/organ/lungs/L = get_int_organ_datum(ORGAN_DATUM_LUNGS)
	if(HAS_TRAIT(src, TRAIT_MUTE))
		return FALSE
	if(breathes && (!L || L.linked_organ.status & ORGAN_DEAD))
		return FALSE
	if(mind)
		return !mind.miming
	return TRUE

/mob/living/carbon/human/cannot_speak_loudly()
	return getOxyLoss() > 10 || AmountLoseBreath() >= 8 SECONDS

/mob/living/carbon/human/proc/SetSpecialVoice(new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice

GLOBAL_LIST_INIT(soapy_words, list(
	"shit" = "shoot",
	"shitter" = "toilet",
	"fuck" = "phooey",
	"fucking" = "flipping",
	"fucker" = "individual dedicated to the continuation of their species",
	"motherfucker" = "family time enjoyer",
	"balls" = "baloney",
	"whore" = "overly experienced individual",
	"dumbass" = "sweet, misunderstood person",
	"ass" = "backside",
	"bastard" = "individual born out of wedlock",
	"bitch" = "female dog",
	"cock" = "chicken",
	"cunt" = "countryman",
	"damn" = "beaver-constructed river-blockade",
	"dick" = "detective",
	"hell" = "HFIL",
	"jesus" = "jesús",
	"pussy" = "pusillanimous",
	"twat" = "honorable and esteemed individual",
	"wanker" = "sanguine individual"
	))

/mob/living/carbon/human/handle_speech_problems(list/message_pieces, verb)
	var/span = ""
	var/obj/item/organ/internal/cyberimp/brain/speech_translator/translator = locate(/obj/item/organ/internal/cyberimp/brain/speech_translator) in internal_organs

	if(translator && !HAS_TRAIT(src, TRAIT_MUTE))
		if(translator.active)
			span = translator.speech_span
			for(var/datum/multilingual_say_piece/S in message_pieces)
				S.message = "<span class='[span]'>[S.message]</span>"
			verb = translator.speech_verb
			return list("verb" = verb)
	if(HAS_TRAIT(src, TRAIT_COMIC_SANS))
		span = "sans"

	if(HAS_TRAIT(src, TRAIT_WINGDINGS))
		span = "wingdings"

	var/list/parent = ..()
	verb = parent["verb"]

	for(var/datum/multilingual_say_piece/S in message_pieces)
		if(S.speaking && S.speaking.flags & NO_STUTTER)
			continue

		if(HAS_TRAIT(src, TRAIT_MUTE))
			S.message = ""

		if(istype(wear_mask, /obj/item/clothing/mask/horsehead))
			var/obj/item/clothing/mask/horsehead/hoers = wear_mask
			if(hoers.voicechange)
				S.message = pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")

		if(HAS_TRAIT(src, TRAIT_SOAPY_MOUTH))
			var/static/regex/R = regex("\\b([GLOB.soapy_words.Join("|")])\\b", "gi")
			S.message = R.Replace(S.message, /mob/living/carbon/human/proc/replace_speech)

		if(dna)
			for(var/mutation_type in active_mutations)
				var/datum/mutation/mutation = GLOB.dna_mutations[mutation_type]
				S.message = mutation.on_say(src, S.message)

		var/braindam = getBrainLoss()
		if(braindam >= 60)
			if(prob(braindam / 4))
				S.message = stutter(S.message, getStaminaLoss(), ismachineperson(src))
				verb = "gibbers"
			else if(prob(braindam / 2))
				S.message = uppertext(S.message)
				verb = "yells loudly"

		if(span && !speaks_ooc)
			S.message = "<span class='[span]'>[S.message]</span>"

	if(wear_mask)
		var/speech_verb_when_masked = wear_mask.change_speech_verb()
		if(speech_verb_when_masked)
			verb = speech_verb_when_masked

	return list("verb" = verb)

/mob/living/carbon/human/proc/replace_speech(matched)
	REGEX_REPLACE_HANDLER
	return GLOB.soapy_words[lowertext(matched)]

/mob/living/carbon/human/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
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
			if(isradio(r_hand))
				R = r_hand
			else if(isradio(r_ear))
				R = r_ear
			if(R)
				used_radios += R
				R.talk_into(src, message_pieces, null, verb)

		if("left ear")
			var/obj/item/radio/R
			if(isradio(l_hand))
				R = l_hand
			else if(isradio(l_ear))
				R = l_ear
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
		returns[3] = get_age_pitch(dna.species.max_age)
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
