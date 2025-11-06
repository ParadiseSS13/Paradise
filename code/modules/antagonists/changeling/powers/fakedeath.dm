/datum/action/changeling/fakedeath
	name = "Regenerative Stasis"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies. Costs 15 chemicals."
	button_icon_state = "fake_death"
	chemical_cost = 15
	power_type = CHANGELING_INNATE_POWER
	req_dna = 1
	req_stat = DEAD

//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/datum/action/changeling/fakedeath/sting_action(mob/living/user)

	to_chat(user, "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>")
	if(user.stat != DEAD)
		user.emote("deathgasp")
		user.timeofdeath = world.time
	ADD_TRAIT(user, TRAIT_FAKEDEATH, CHANGELING_TRAIT)		//play dead
	user.updatehealth("fakedeath sting")
	cling.regenerating = TRUE

	cling.remove_specific_power(/datum/action/changeling/revive)
	addtimer(CALLBACK(src, PROC_REF(ready_to_regenerate), user), CHANGELING_FAKEDEATH_TIME)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/fakedeath/proc/ready_to_regenerate(mob/user)
	if(!HAS_TRAIT_FROM(user, TRAIT_FAKEDEATH, CHANGELING_TRAIT))
		return
	if(!QDELETED(user) && user.mind && cling?.acquired_powers)
		to_chat(user, "<span class='notice'>We are ready to regenerate.</span>")
		cling.give_power(new /datum/action/changeling/revive)

/datum/action/changeling/fakedeath/can_sting(mob/user)
	if(HAS_TRAIT(user, TRAIT_FAKEDEATH))
		to_chat(user, "<span class='warning'>We are already regenerating.</span>")
		return FALSE
	if(!user.stat)//Confirmation for living changelings if they want to fake their death
		var/death_confirmation = tgui_alert(user, "Are we sure we wish to fake our death?", "Fake Death", list("Yes", "No"))
		if(death_confirmation != "Yes")
			return FALSE
		// Do the checks again since we had user input
		if(cling.owner != user.mind)
			return FALSE
		if(HAS_TRAIT(user, TRAIT_FAKEDEATH))
			to_chat(user, "<span class='warning'>We are already regenerating.</span>")
			return FALSE
	return ..()
