//Strained Muscles: Temporary speed boost at the cost of chemicals
//Limited because of hardsuits and such; ideally, used for a quick getaway

/datum/action/changeling/strained_muscles
	name = "Strained Muscles"
	desc = "We evolve the ability to reduce the acid buildup in our muscles, allowing us to move much faster."
	helptext = "The strain will use up our chemicals faster over time, and is not sustainable. Causes slight genetic damage to our genome. Can not be used in lesser form."
	button_icon_state = "strained_muscles"
	chemical_cost = 0
	dna_cost = 1
	req_human = 1
	max_genetic_damage = 0

/datum/action/changeling/strained_muscles/sting_action(mob/living/carbon/user)
	if(!user.has_status_effect(STATUS_EFFECT_SPEEDLEGS))
		if(user.dna.species.speed_mod < 0)
			to_chat(user, "<span class='notice'>We are moving as fast as we can, we can not go faster.</span>")
		else
			to_chat(user, "<span class='notice'>Our muscles tense and strengthen.</span>")
			user.apply_status_effect(STATUS_EFFECT_SPEEDLEGS)
	else
		user.remove_status_effect(STATUS_EFFECT_SPEEDLEGS)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return 1
