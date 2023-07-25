/datum/action/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "By evolving the ability to distort our form and proprotions, we defeat common altgorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera while using this skill. However, humans looking at us will find us... uncanny."
	button_icon_state = "digital_camo"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1


/datum/action/changeling/digitalcamo/Remove(mob/user)
	REMOVE_TRAIT(user, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT)
	..()


/**
 * Prevents AIs tracking you but makes you easily detectable to the human-eye.
 */
/datum/action/changeling/digitalcamo/sting_action(mob/user)
	if(HAS_TRAIT_FROM(user, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT))
		REMOVE_TRAIT(user, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT)
		to_chat(user, span_notice("We return to normal."))
	else
		ADD_TRAIT(user, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT)
		to_chat(user, span_notice("We distort our form to prevent AI-tracking."))

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
