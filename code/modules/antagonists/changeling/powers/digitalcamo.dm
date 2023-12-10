/datum/action/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "By evolving the ability to distort our form and proportions, we defeat common algorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera while using this skill."
	button_icon_state = "digital_camo"
	dna_cost = 2
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/utility

/datum/action/changeling/digitalcamo/Remove(mob/M)
	REMOVE_TRAIT(M, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT)
	..()

//Prevents AIs tracking you.
/datum/action/changeling/digitalcamo/sting_action(mob/user)
	if(HAS_TRAIT_FROM(user, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT))
		REMOVE_TRAIT(user, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT)
		user.set_invisible(INVISIBILITY_MINIMUM)
		to_chat(user, "<span class='notice'>We return to normal.</span>")
	else
		ADD_TRAIT(user, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT)
		to_chat(user, "<span class='notice'>We distort our form to prevent AI-tracking.</span>")
		user.set_invisible(SEE_INVISIBLE_LIVING)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
