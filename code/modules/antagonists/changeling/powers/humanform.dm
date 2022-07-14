/datum/action/changeling/humanform
	name = "Human form"
	desc = "We change into a human. Costs 5 chemicals."
	button_icon_state = "human_form"
	chemical_cost = 5
	genetic_damage = 3
	req_dna = 1
	max_genetic_damage = 3

//Transform into a human.
/datum/action/changeling/humanform/sting_action(mob/living/carbon/human/user)
	var/datum/dna/chosen_dna = cling.select_dna("Select the target DNA: ", "Target DNA")
	if(!chosen_dna || !user)
		return FALSE
	to_chat(user, "<span class='notice'>We transform our appearance.</span>")
	user.dna.SetSEState(GLOB.monkeyblock,0,1)
	singlemutcheck(user,GLOB.monkeyblock, MUTCHK_FORCED)
	if(istype(user))
		user.set_species(chosen_dna.species.type)
	user.dna = chosen_dna.Clone()
	user.real_name = chosen_dna.real_name
	domutcheck(user, MUTCHK_FORCED)
	user.flavor_text = ""
	user.dna.UpdateSE()
	user.dna.UpdateUI()
	user.sync_organ_dna(1)
	user.UpdateAppearance()

	cling.acquired_powers -= src
	Remove(user)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
