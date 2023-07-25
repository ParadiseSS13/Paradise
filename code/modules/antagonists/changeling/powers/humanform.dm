/datum/action/changeling/humanform
	name = "Human form"
	desc = "We change into a human. Costs 5 chemicals."
	button_icon_state = "human_form"
	req_dna = 1
	genetic_damage = 3
	max_genetic_damage = 3
	chemical_cost = 5


/**
 * Transform into a human.
 */
/datum/action/changeling/humanform/sting_action(mob/living/carbon/human/user)

	var/datum/dna/chosen_dna = cling.select_dna("Select the target DNA: ", "Target DNA")
	if(!chosen_dna || !user)
		return FALSE

	// Notify players about transform.
	user.visible_message(span_warning("[user] transforms!"), span_notice("We transform our appearance."))

	user.dna.SetSEState(GLOB.monkeyblock, FALSE, TRUE)
	genemutcheck(user, GLOB.monkeyblock, null, MUTCHK_FORCED)

	if(istype(user))
		user.set_species(chosen_dna.species.type)

	user.dna = chosen_dna.Clone()
	user.real_name = chosen_dna.real_name
	domutcheck(user, null, MUTCHK_FORCED)
	user.flavor_text = ""
	user.dna.UpdateSE()
	user.dna.UpdateUI()
	user.sync_organ_dna(TRUE)
	user.UpdateAppearance()

	cling.acquired_powers -= src
	Remove(user)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

