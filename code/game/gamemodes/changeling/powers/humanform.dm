/obj/effect/proc_holder/changeling/humanform
	name = "Human form"
	desc = "We change into a human."
	chemical_cost = 5
	genetic_damage = 3
	req_dna = 1
	max_genetic_damage = 3


//Transform into a human.
/obj/effect/proc_holder/changeling/humanform/sting_action(var/mob/living/carbon/human/user)
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
	user.dna.SetSEState(MONKEYBLOCK,0,1)
	genemutcheck(user,MONKEYBLOCK,null,MUTCHK_FORCED)
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
	//O.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/lesserform(null)
	feedback_add_details("changeling_powers","LFT")
	return 1

