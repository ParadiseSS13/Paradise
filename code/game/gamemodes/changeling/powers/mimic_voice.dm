/datum/action/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice. Maintaining this power slows chemical production."
	helptext = "Will turn your voice into the name that you enter. We must constantly expend chemicals to maintain our form like this."
	button_icon_state = "mimic_voice"
	chemical_cost = 0 //constant chemical drain hardcoded
	dna_cost = 1
	req_human = 1


// Fake Voice
/datum/action/changeling/mimicvoice/sting_action(var/mob/user)
	var/datum/changeling/changeling=user.mind.changeling
	if(changeling.mimicking)
		changeling.mimicking = ""
		changeling.tts_mimicking = ""
		changeling.chem_recharge_slowdown -= 0.5
		to_chat(user, "<span class='notice'>We return our vocal glands to their original position.</span>")
		return

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
				return
			mimic_voice_tts = user.select_voice(user, override = TRUE)
		if("Cancel")
			return

	changeling.mimicking = mimic_voice
	changeling.tts_mimicking = mimic_voice_tts

	changeling.chem_recharge_slowdown += 0.5
	to_chat(user, "<span class='notice'>We shape our glands to take the voice of <b>[mimic_voice]</b>, this will stop us from regenerating chemicals while active.</span>")
	to_chat(user, "<span class='notice'>Use this power again to return to our original voice and reproduce chemicals again.</span>")

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
