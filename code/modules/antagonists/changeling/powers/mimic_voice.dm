/datum/action/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice."
	helptext = "Will turn your voice into the name that you enter."
	button_icon_state = "mimic_voice"
	chemical_cost = 0
	dna_cost = 1
	req_human = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER


// Fake Voice
/datum/action/changeling/mimicvoice/sting_action(mob/user)
	if(cling.mimicing)
		cling.mimicing = ""
		to_chat(user, "<span class='notice'>We return our vocal glands to their original position.</span>")
		return FALSE

	var/mimic_voice = stripped_input(user, "Enter a name to mimic.", "Mimic Voice", null, MAX_NAME_LEN)
	if(!mimic_voice)
		return FALSE

	cling.mimicing = mimic_voice
	to_chat(user, "<span class='notice'>We shape our glands to take the voice of <b>[mimic_voice]</b>.</span>")
	to_chat(user, "<span class='notice'>Use this power again to return to our original voice.</span>")

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
