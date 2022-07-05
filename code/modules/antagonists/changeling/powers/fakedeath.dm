/datum/action/changeling/fakedeath
	name = "Regenerative Stasis"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies. Costs 15 chemicals."
	button_icon_state = "fake_death"
	chemical_cost = 15
	power_type = CHANGELING_INNATE_POWER
	req_dna = 1
	req_stat = DEAD
	max_genetic_damage = 100

//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/datum/action/changeling/fakedeath/sting_action(mob/living/user)

	to_chat(user, "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>")
	if(user.stat != DEAD)
		user.emote("deathgasp")
		user.timeofdeath = world.time
	ADD_TRAIT(user, TRAIT_FAKEDEATH, CHANGELING_TRAIT)		//play dead
	user.updatehealth("fakedeath sting")
	user.update_canmove()
	cling.regenerating = TRUE

	addtimer(CALLBACK(src, .proc/ready_to_regenerate, user), LING_FAKEDEATH_TIME)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/fakedeath/proc/ready_to_regenerate(mob/user)
	if(user?.mind && cling?.acquired_powers)
		to_chat(user, "<span class='notice'>We are ready to regenerate.</span>")
		cling.give_power(new /datum/action/changeling/revive)

/datum/action/changeling/fakedeath/can_sting(mob/user)
	if(HAS_TRAIT(user, TRAIT_FAKEDEATH))
		to_chat(user, "<span class='warning'>We are already regenerating.</span>")
		return FALSE
	if(!user.stat)//Confirmation for living changelings if they want to fake their death
		switch(alert("Are we sure we wish to fake our death?",,"Yes","No"))
			if("No")
				return FALSE
	return ..()
