//Strained Muscles: Temporary speed boost at the cost of chemicals
//Limited because of hardsuits and such; ideally, used for a quick getaway

/datum/action/changeling/strained_muscles
	name = "Strained Muscles"
	desc = "We evolve the ability to reduce the acid buildup in our muscles, allowing us to move much faster."
	helptext = "The strain will use up our chemicals faster over time."
	button_icon_state = "strained_muscles"
	chemical_cost = 0
	dna_cost = 1
	req_human = 1
	var/stacks = 0 //Increments every 5 seconds; damage increases over time
	var/enabled = 0 //Whether or not you are a hedgehog

/datum/action/changeling/strained_muscles/sting_action(var/mob/living/carbon/user)
	if(!enabled)
		if(stacks > 0)
			to_chat(user, "<span class='notice'>Our muscles are too tired to strengthen.</span>")
		else
			to_chat(user, "<span class='notice'>Our muscles tense and strengthen.</span>")
			enabled = !enabled
	else
		user.status_flags &= ~GOTTAGOFAST
		if(stacks < 3) //no turning it on and off real fast to cheese the cost
			to_chat(user, "<span class='notice'>Our muscles just tensed up, they will not relax so fast.</span>")
		else
			to_chat(user, "<span class='notice'>Our muscles relax.</span>")
			enabled = !enabled
			if(stacks >= 10)
				to_chat(user, "<span class='danger'>We collapse in exhaustion.</span>")
				user.Weaken(3)
				user.emote("gasp")

	while(enabled)
		user.status_flags |= GOTTAGOFAST
		if(user.stat || user.staminaloss >= 90 || user.mind.changeling.chem_charges <= (stacks + 1) * 3)
			enabled = 0 //Let's use something exact instead of !enabled where we can.
			to_chat(user, "<span class='notice'>Our muscles relax without the energy to strengthen them.</span>")
			user.status_flags &= ~GOTTAGOFAST
			user.Weaken(2)
			user.emote("gasp")
			break

		stacks++
		//user.take_organ_damage(stacks * 0.03, 0)
		user.mind.changeling.chem_charges -= stacks * 3 //At first the changeling may regenerate chemicals fast enough to nullify fatigue, but it will stack

		sleep(40)

	while(!enabled) //Stacks decrease fairly rapidly while not in sanic mode
		if(stacks >= 1)
			stacks--
		sleep(20)

	feedback_add_details("changeling_powers","SANIC")
	return 1
