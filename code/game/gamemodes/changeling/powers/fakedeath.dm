/datum/action/changeling/fakedeath
	name = "Regenerative Stasis"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies. Costs 15 chemicals."
	button_icon_state = "fake_death"
	chemical_cost = 15
	dna_cost = 0
	req_dna = 1
	req_stat = DEAD
	max_genetic_damage = 100

//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/datum/action/changeling/fakedeath/sting_action(var/mob/living/user)

	to_chat(user, "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>")
	if(user.stat != DEAD)
		user.emote("deathgasp")
		user.timeofdeath = world.time
	user.status_flags |= FAKEDEATH		//play dead
	user.update_stat("fakedeath sting")
	user.update_canmove()
	user.med_hud_set_health()
	user.handle_hud_icons_health()
	user.med_hud_set_status()
	user.mind.changeling.regenerating = TRUE

	addtimer(CALLBACK(src, .proc/ready_to_regenerate, user), LING_FAKEDEATH_TIME)
	feedback_add_details("changeling_powers","FD")
	return 1

/datum/action/changeling/fakedeath/proc/ready_to_regenerate(mob/user)
	if(user && user.mind && user.mind.changeling && user.mind.changeling.purchasedpowers)
		to_chat(user, "<span class='notice'>We are ready to regenerate.</span>")
		var/datum/action/changeling/revive/R = new
		R.Grant(user)

/datum/action/changeling/fakedeath/can_sting(var/mob/user)
	if(user.status_flags & FAKEDEATH)
		to_chat(user, "<span class='warning'>We are already regenerating.</span>")
		return
	if(!user.stat)//Confirmation for living changelings if they want to fake their death
		switch(alert("Are we sure we wish to fake our death?",,"Yes","No"))
			if("No")
				return
	return ..()
