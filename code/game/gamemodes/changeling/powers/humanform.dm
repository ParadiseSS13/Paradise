/datum/action/changeling/humanform
	name = "Human form"
	desc = "We change into a human. Costs 5 chemicals."
	button_icon_state = "human_form"
	chemical_cost = 5
	genetic_damage = 3
	req_dna = 1
	max_genetic_damage = 3

// Transform into a human.
/datum/action/changeling/humanform/sting_action(var/mob/living/carbon/human/user)
	if(!user)
		return 0

	var/datum/changeling/changeling = user.mind.changeling

	// If you're human already, you can't use it.
	if(!istype(user) || !user.dna.species.greater_form)
		to_chat(user, "<span class='warning'>We cannot perform this ability in this form!</span>")
		return

	// DNA Selector
	var/datum/dna/chosen_dna = changeling.select_dna("Select the target DNA: ", "Target DNA")

	if(!chosen_dna)
		return

	// Notify players about transform.
	user.visible_message("<span class='warning'>[user] transforms!</span>")

	to_chat(user, "<span class='notice'>We transform our appearance.</span>")

	user.dna.SetSEState(GLOB.monkeyblock,0,1)
	genemutcheck(user,GLOB.monkeyblock,null,MUTCHK_FORCED)
	if(istype(user))
		user.set_species(chosen_dna.species.type)
	user.dna = chosen_dna.Clone()
	user.real_name = chosen_dna.real_name
	domutcheck(user,null,MUTCHK_FORCED)
	user.flavor_text = ""
	user.dna.UpdateSE()
	user.dna.UpdateUI()
	user.sync_organ_dna(1)
	user.UpdateAppearance()

	//changeling.purchasedpowers -= src // no longer needed as humanform now persistent.
	//O.mind.changeling.purchasedpowers += new /datum/action/changeling/lesserform(null)
	//src.Remove(user) // no longer needed as humanform now persistent.
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return 1
