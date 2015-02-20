/obj/effect/proc_holder/changeling/humanform
	name = "Human form"
	desc = "We change into a human."
	chemical_cost = 5
	genetic_damage = 3
	req_dna = 1
	max_genetic_damage = 3


//Transform into a human.
/obj/effect/proc_holder/changeling/humanform/sting_action(var/mob/living/carbon/user)
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
	user << "<span class='notice'>We transform our appearance.</span>"
	user.dna = chosen_dna

	var/list/implants = list()
	for (var/obj/item/weapon/implant/I in user) //Still preserving implants
		implants += I

	for(var/obj/item/W in src)
		user.unEquip(W)
		if (user.client)
			user.client.screen -= W
		if (W)
			W.loc = user.loc
			W.dropped(user)
			W.layer = initial(W.layer)

	var/mob/living/carbon/human/O = new /mob/living/carbon/human( user, delay_ready_dna=1 )
	if (user.dna.GetUIState(DNA_UI_GENDER))
		O.gender = FEMALE
	else
		O.gender = MALE
	O.dna = user.dna.Clone()
	user.dna = null
	O.real_name = chosen_dna.real_name
	O.set_species()
	for(var/obj/T in user)
		del(T)

	O.loc = user.loc

	O.UpdateAppearance()
	domutcheck(O, null)
	O.setToxLoss(user.getToxLoss())
	O.adjustBruteLoss(user.getBruteLoss())
	O.setOxyLoss(user.getOxyLoss())
	O.adjustFireLoss(user.getFireLoss())
	O.stat = user.stat
	for (var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O

	user.mind.transfer_to(O)
	O.changeling_update_languages(changeling.absorbed_languages)
	O.mind.changeling.purchasedpowers -= src
	//O.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/lesserform(null)
	feedback_add_details("changeling_powers","LFT")
	qdel(user)
	return 1

