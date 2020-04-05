/datum/action/changeling/humanform
	name = "Human form"
	desc = "We change into a human. Costs 5 chemicals."
	button_icon_state = "human_form"
	chemical_cost = 5
	genetic_damage = 3
	req_dna = 1
	max_genetic_damage = 3

//Transform into a human.
/datum/action/changeling/humanform/sting_action(var/mob/living/carbon/human/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/list/names = list()
	for(var/datum/dna/DNA in (changeling.absorbed_dna+changeling.protected_dna))
		names += "[DNA.real_name]"

	var/chosen_name = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!chosen_name)
		return

	var/datum/dna/chosen_dna = changeling.GetDNA(chosen_name)
	if(!chosen_dna)
		return
	if(!user)
		return 0
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

	changeling.purchasedpowers -= src
	//O.mind.changeling.purchasedpowers += new /datum/action/changeling/lesserform(null)
	src.Remove(user)
	feedback_add_details("changeling_powers","LFT")
	return 1
