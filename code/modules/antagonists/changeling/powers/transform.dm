/datum/action/changeling/transform
	name = "Transform"
	desc = "We take on the appearance and voice of one we have absorbed. Costs 5 chemicals."
	button_icon_state = "transform"
	chemical_cost = 5
	power_type = CHANGELING_INNATE_POWER
	req_dna = 1
	req_human = TRUE
	max_genetic_damage = 3

//Change our DNA to that of somebody we've absorbed.
/datum/action/changeling/transform/sting_action(mob/living/carbon/human/user)
	var/datum/dna/chosen_dna = cling.select_dna("Select the target DNA: ", "Target DNA")

	if(!chosen_dna)
		return FALSE

	transform_dna(user, chosen_dna)
	cling.update_languages()
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
