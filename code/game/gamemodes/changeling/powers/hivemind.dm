//HIVEMIND COMMUNICATION (:g)
/datum/action/changeling/hivemind_comms
	name = "Hivemind Communication"
	desc = "We tune our senses to the airwaves to allow us to discreetly communicate and exchange DNA with other changelings."
	helptext = "We will be able to talk with other changelings with :g. Exchanged DNA do not count towards absorb objectives."
	dna_cost = 0
	chemical_cost = -1
	needs_button = FALSE

/datum/action/changeling/hivemind_comms/on_purchase(var/mob/user)
	..()
	var/datum/changeling/changeling=user.mind.changeling
	changeling.changeling_speak = 1
	to_chat(user, "<i><font color=#800080>Use say \":g message\" to communicate with the other changelings.</font></i>")
	var/datum/action/changeling/hivemind_upload/S1 = new
	if(!changeling.has_sting(S1))
		changeling.purchasedpowers+=S1
		S1.Grant(user)
	var/datum/action/changeling/hivemind_download/S2 = new
	if(!changeling.has_sting(S2))
		S2.Grant(user)
		changeling.purchasedpowers+=S2
	return

// HIVE MIND UPLOAD/DOWNLOAD DNA
var/list/datum/dna/hivemind_bank = list()

/datum/action/changeling/hivemind_upload
	name = "Hive Channel DNA"
	desc = "Allows us to channel DNA in the airwaves to allow other changelings to absorb it. Costs 10 chemicals."
	button_icon_state = "hivemind_channel"
	chemical_cost = 10
	dna_cost = -1

/datum/action/changeling/hivemind_upload/sting_action(var/mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/list/names = list()
	for(var/datum/dna/DNA in (changeling.absorbed_dna+changeling.protected_dna))
		if(!(DNA in hivemind_bank))
			names += DNA.real_name

	if(names.len <= 0)
		to_chat(user, "<span class='notice'>The airwaves already have all of our DNA.</span>")
		return

	var/chosen_name = input("Select a DNA to channel: ", "Channel DNA", null) as null|anything in names
	if(!chosen_name)
		return

	var/datum/dna/chosen_dna = changeling.GetDNA(chosen_name)
	if(!chosen_dna)
		return

	hivemind_bank += chosen_dna
	to_chat(user, "<span class='notice'>We channel the DNA of [chosen_name] to the air.</span>")
	feedback_add_details("changeling_powers","HU")
	return 1

/datum/action/changeling/hivemind_download
	name = "Hive Absorb DNA"
	desc = "Allows us to absorb DNA that has been channeled to the airwaves. Does not count towards absorb objectives. Costs 10 chemicals."
	button_icon_state = "hive_absorb"
	chemical_cost = 10
	dna_cost = -1

/datum/action/changeling/hivemind_download/can_sting(var/mob/living/carbon/user)
	if(!..())
		return
	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.using_stale_dna(user))//If our current DNA is the stalest, we gotta ditch it.
		to_chat(user, "<span class='warning'>We have reached our capacity to store genetic information! We must transform before absorbing more.</span>")
		return
	return 1

/datum/action/changeling/hivemind_download/sting_action(var/mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/list/names = list()
	for(var/datum/dna/DNA in hivemind_bank)
		if(!(DNA in changeling.absorbed_dna))
			names[DNA.real_name] = DNA

	if(names.len <= 0)
		to_chat(user, "<span class='notice'>There's no new DNA to absorb from the air.</span>")
		return

	var/S = input("Select a DNA absorb from the air: ", "Absorb DNA", null) as null|anything in names
	if(!S)	return
	var/datum/dna/chosen_dna = names[S]
	if(!chosen_dna)
		return

	changeling.store_dna(chosen_dna, user)
	to_chat(user, "<span class='notice'>We absorb the DNA of [S] from the air.</span>")
	feedback_add_details("changeling_powers","HD")
	return 1
