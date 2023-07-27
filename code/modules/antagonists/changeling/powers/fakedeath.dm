/datum/action/changeling/fakedeath
	name = "Regenerative Stasis"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies. Costs 15 chemicals."
	button_icon_state = "fake_death"
	power_type = CHANGELING_INNATE_POWER
	req_dna = 1
	chemical_cost = 15
	req_stat = DEAD


/**
 * Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
 */
/datum/action/changeling/fakedeath/sting_action(mob/living/user)

	if(user.stat != DEAD)
		cling.calculate_stasis_delay(user)
		user.emote("deathgasp")
		user.timeofdeath = world.time

	ADD_TRAIT(user, TRAIT_FAKEDEATH, CHANGELING_TRAIT)		//play dead
	user.updatehealth("fakedeath sting")
	user.update_canmove()
	cling.regenerating = TRUE

	var/stasis_delay = LING_FAKEDEATH_TIME + cling.fakedeath_delay
	addtimer(CALLBACK(src, PROC_REF(ready_to_regenerate), user), stasis_delay)
	to_chat(user, span_changeling("We begin our stasis, preparing energy to arise once more. This process will take <b>[stasis_delay / 10] seconds</b>."))
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE


/datum/action/changeling/fakedeath/proc/ready_to_regenerate(mob/user)
	if(!QDELETED(user) && !QDELETED(src) && ischangeling(user) && cling?.acquired_powers)
		cling.fakedeath_delay = 0 SECONDS
		to_chat(user, span_changeling("We are ready to regenerate."))
		cling.give_power(new /datum/action/changeling/revive)


/datum/action/changeling/fakedeath/can_sting(mob/user)
	if(HAS_TRAIT(user, TRAIT_FAKEDEATH))
		to_chat(user, span_warning("We are already regenerating."))
		return FALSE

	if(!ishuman(user))
		to_chat(user, span_warning("Impossible in this form."))
		return FALSE

	if(!user.stat)//Confirmation for living changelings if they want to fake their death
		switch(alert("Are we sure we wish to fake our death?",, "Yes", "No"))
			if("No")
				return FALSE

	return ..()

