/datum/action/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice. Maintaining this power slows chemical production."
	helptext = "Will turn your voice into the name that you enter. We must constantly expend chemicals to maintain our form like this."
	button_icon_state = "mimic_voice"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 0	//constant chemical drain hardcoded
	req_human = TRUE


/datum/action/changeling/mimicvoice/sting_action(mob/user)
	if(cling.mimicking)
		cling.mimicking = ""
		cling.tts_mimicking = ""
		cling.chem_recharge_slowdown -= 0.5
		to_chat(user, span_notice("We return our vocal glands to their original position."))
		return FALSE

	var/mimic_voice
	var/mimic_voice_tts

	var/mimic_option = alert(user, "What voice do you want to mimic?", "Mimic Voice", "Real Voice", "Custom Voice", "Cancel")
	switch(mimic_option)
		if("Real Voice")
			var/mob/living/carbon/human/human = input(user, "Select a voice to copy from.", "Mimic Voice") in GLOB.human_list
			mimic_voice = human.real_name
			mimic_voice_tts = human.dna.tts_seed_dna

		if("Custom Voice")
			mimic_voice = reject_bad_name(stripped_input(user, "Enter a name to mimic.", "Mimic Voice", null, MAX_NAME_LEN), TRUE)
			if(!mimic_voice)
				to_chat(user, span_warning("Invalid name, try again."))
				return FALSE

			mimic_voice_tts = user.select_voice(user, override = TRUE)

		if("Cancel")
			return FALSE

	cling.mimicking = mimic_voice
	cling.tts_mimicking = mimic_voice_tts
	cling.chem_recharge_slowdown += 0.5
	to_chat(user, span_notice("We shape our glands to take the voice of <b>[mimic_voice]</b>."))
	to_chat(user, span_notice("Use this power again to return to our original voice."))

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

