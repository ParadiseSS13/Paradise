/// HIVE MIND UPLOAD/DOWNLOAD DNA
GLOBAL_LIST_EMPTY(hivemind_bank)

/datum/action/changeling/hivemind_pick
	name = "Hivemind Access"
	desc = "Allows us to upload or absorb DNA in the airwaves. Does not count towards absorb objectives. Allows us to speak over the Changeling Hivemind using :g. Costs 10 chemicals."
	helptext = "Tunes our chemical receptors for hivemind communication, which passively grants us access to the Changeling Hivemind."
	button_icon_state = "hive_absorb"
	power_type = CHANGELING_INNATE_POWER
	chemical_cost = 10
	/// Connected linglink ability.
	var/datum/action/changeling/linglink/linglink


/datum/action/changeling/hivemind_pick/on_purchase(mob/user, datum/antagonist/changeling/antag)
	if(!..())
		return FALSE

	//to_chat(user, span_notice("We feel our consciousness become capable of communion with the hivemind."))
	//to_chat(user, span_changeling("Use say \":g message\" to communicate with the other changelings. You can use linglink to interrogate properly grabbed victims."))
	to_chat(user, span_changeling("Use say \":g message\" to communicate with the other changelings."))

	return TRUE


/datum/action/changeling/hivemind_pick/Grant(mob/user)
	if(!..() || QDELETED(user) || !cling)
		return

	/*if(!linglink)
		linglink = new
		linglink.cling = cling
		linglink.Grant(user)*/

	if(!(GLOB.all_languages["Changeling"] in user.languages))
		user.add_language("Changeling")


/datum/action/changeling/hivemind_pick/Remove(mob/user)
	if(QDELETED(user))
		return

	to_chat(user, span_changeling("We feel a slight emptiness as we shut ourselves off from the hivemind."))

	/*if(linglink)
		linglink.Remove(user)
		QDEL_NULL(linglink)*/

	if(GLOB.all_languages["Changeling"] in user.languages)
		user.remove_language("Changeling")

	..()


/datum/action/changeling/hivemind_pick/Destroy(force, ...)
	/*if(linglink)
		if(owner)
			linglink.Remove(owner)

		QDEL_NULL(linglink)*/

	if(owner && (GLOB.all_languages["Changeling"] in owner.languages))
		owner.remove_language("Changeling")

	return ..()


/datum/action/changeling/hivemind_pick/sting_action(mob/user)
	var/channel_pick = alert("Upload or Absorb DNA?", "Channel Select", "Upload", "Absorb")

	if(channel_pick == "Upload")
		dna_upload(user)

	if(channel_pick == "Absorb")
		if(cling.using_stale_dna())//If our current DNA is the stalest, we gotta ditch it.
			to_chat(user, span_warning("We have reached our capacity to store genetic information! We must transform before absorbing more."))
			return FALSE
		else
			dna_absorb(user)

	return TRUE


/datum/action/changeling/proc/dna_upload(mob/user)
	var/datum/dna/chosen_dna = cling.select_dna("Select a DNA to channel: ", "Channel DNA", TRUE)
	if(!chosen_dna)
		to_chat(user, span_notice("The airwaves already have all of our DNA."))
		return FALSE

	GLOB.hivemind_bank += chosen_dna
	to_chat(user, span_notice("We channel the DNA of [chosen_dna.real_name] to the air."))
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE


/datum/action/changeling/proc/dna_absorb(mob/user)
	var/list/names = list()
	for(var/datum/dna/DNA in GLOB.hivemind_bank)
		if(!(DNA in cling.absorbed_dna))
			names[DNA.real_name] = DNA

	if(!length(names))
		to_chat(user, span_notice("There's no new DNA to absorb from the air."))
		return FALSE

	var/choice = input("Select a DNA absorb from the air: ", "Absorb DNA", null) as null|anything in names
	if(!choice)
		return FALSE

	var/datum/dna/chosen_dna = names[choice]
	cling.store_dna(chosen_dna)
	to_chat(user, span_notice("We absorb the DNA of [choice] from the air."))
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

