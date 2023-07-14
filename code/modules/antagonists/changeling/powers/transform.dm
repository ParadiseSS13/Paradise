/datum/action/changeling/transform
	name = "Transform"
	desc = "We take on the appearance and voice of one we have absorbed. Costs 5 chemicals."
	button_icon_state = "transform"
	chemical_cost = 5
	power_type = CHANGELING_INNATE_POWER
	req_dna = 1
	req_human = TRUE

//Change our DNA to that of somebody we've absorbed.
/datum/action/changeling/transform/sting_action(mob/living/carbon/human/user)
	var/datum/dna/chosen_dna = cling.select_dna("Select the target DNA: ", "Target DNA")

	if(!chosen_dna)
		return FALSE

	var/keep_cuffs
	if(user.handcuffed)
		keep_cuffs = user.handcuffed
		user.handcuffed = FALSE
	else
		keep_cuffs = FALSE
	transform_dna(user, chosen_dna)
	if(keep_cuffs)
		user.handcuffed = keep_cuffs
		user.update_handcuffed()
	cling.update_languages()
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
