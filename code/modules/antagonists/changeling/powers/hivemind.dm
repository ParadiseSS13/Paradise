// HIVE MIND UPLOAD/DOWNLOAD DNA
GLOBAL_LIST_EMPTY(hivemind_bank)

/datum/action/changeling/hivemind_pick
	name = "Hivemind Access"
	desc = "Allows us to upload or absorb DNA in the airwaves. Does not count towards absorb objectives. Costs 10 chemicals."
	helptext = "Tunes our chemical receptors for hivemind communication, which passively grants us access to the Changeling Hivemind."
	button_icon_state = "hive_absorb"
	chemical_cost = 10
	power_type = CHANGELING_INNATE_POWER
	category = /datum/changeling_power_category/utility

/datum/action/changeling/hivemind_pick/sting_action(mob/user)
	var/channel_pick = tgui_alert(user, "Upload or Absorb DNA?", "Channel Select", list("Upload", "Absorb"))

	if(channel_pick == "Upload")
		dna_upload(user)
	if(channel_pick == "Absorb")
		if(cling.using_stale_dna())//If our current DNA is the stalest, we gotta ditch it.
			to_chat(user, "<span class='warning'>We have reached our capacity to store genetic information! We must transform before absorbing more.</span>")
			return FALSE
		else
			dna_absorb(user)

/datum/action/changeling/proc/dna_upload(mob/user)
	var/datum/dna/chosen_dna = cling.select_dna("Select a DNA to channel: ", "Channel DNA", TRUE)
	if(!chosen_dna)
		to_chat(user, "<span class='notice'>The airwaves already have all of our DNA.</span>")
		return FALSE

	GLOB.hivemind_bank += chosen_dna
	to_chat(user, "<span class='notice'>We channel the DNA of [chosen_dna.real_name] to the air.</span>")
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/proc/dna_absorb(mob/user)
	var/list/names = list()
	for(var/datum/dna/DNA in GLOB.hivemind_bank)
		if(!(DNA in cling.absorbed_dna))
			names[DNA.real_name] = DNA

	if(!length(names))
		to_chat(user, "<span class='notice'>There's no new DNA to absorb from the air.</span>")
		return

	var/S = tgui_input_list(user, "Select a DNA absorb from the air", "Absorb DNA", names)
	if(!S)
		return

	var/datum/dna/chosen_dna = names[S]
	cling.store_dna(chosen_dna)
	to_chat(user, "<span class='notice'>We absorb the DNA of [S] from the air.</span>")
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/hivemind_pick/Remove(mob/user)
	if(!istype(user))
		return
	user.remove_language("Changeling")
	to_chat(user, "<span class='notice'>We feel a slight emptiness as we shut ourselves off from the hivemind.</span>")
	..()
