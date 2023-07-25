/**
 * Strained Muscles: Temporary speed boost at the cost of rapid damage.
 * Limited because of hardsuits and such; ideally, used for a quick getaway.
 */
/datum/action/changeling/strained_muscles
	name = "Strained Muscles"
	desc = "We evolve the ability to reduce the acid buildup in our muscles, allowing us to move much faster."
	helptext = "The strain will make us tired, and we will rapidly become fatigued. Standard weight restrictions, like hardsuits, still apply. Cannot be used in lesser form."
	button_icon_state = "strained_muscles"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 0
	req_human = TRUE


/datum/action/changeling/strained_muscles/Remove(mob/living/user)
	user.remove_status_effect(STATUS_EFFECT_SPEEDLEGS)
	..()


/datum/action/changeling/strained_muscles/sting_action(mob/living/carbon/user)
	if(!user.has_status_effect(STATUS_EFFECT_SPEEDLEGS))
		if(user.dna.species.speed_mod < 0)
			to_chat(user, span_notice("We are moving as fast as we can, we can not go faster."))
		else
			to_chat(user, span_notice("Our muscles tense and strengthen."))
			user.apply_status_effect(STATUS_EFFECT_SPEEDLEGS)
	else
		user.remove_status_effect(STATUS_EFFECT_SPEEDLEGS)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

