/datum/action/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice."
	helptext = "Will turn your voice into the name that you enter."
	button_icon_state = "mimic_voice"
	dna_cost = 2
	req_human = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/utility


// Fake Voice
/datum/action/changeling/mimicvoice/sting_action(mob/user)
	if(cling.mimicking)
		cling.mimicking = ""
		to_chat(user, "<span class='notice'>We return our vocal glands to their original position.</span>")
		return FALSE

	var/mimic_voice = tgui_input_text(user, "Enter a name to mimic.", "Mimic Voice", max_length = MAX_NAME_LEN)
	if(!mimic_voice)
		return FALSE

	cling.mimicking = mimic_voice
	to_chat(user, "<span class='notice'>We shape our glands to take the voice of <b>[mimic_voice]</b>.</span>")
	to_chat(user, "<span class='notice'>Use this power again to return to our original voice.</span>")

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
