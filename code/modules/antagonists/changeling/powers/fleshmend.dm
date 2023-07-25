/datum/action/changeling/fleshmend
	name = "Fleshmend"
	desc = "Our flesh rapidly regenerates, healing our burns, bruises, and shortness of breath. Costs 20 chemicals."
	helptext = "Does not regrow limbs. Partially recovers our blood. Functions while unconscious."
	button_icon_state = "fleshmend"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 20
	req_stat = UNCONSCIOUS


/**
 * Starts healing you every second for 10 seconds. Can be used whilst unconscious.
 */
/datum/action/changeling/fleshmend/sting_action(mob/living/user)
	to_chat(user, span_notice("We begin to heal rapidly."))
	if(user.has_status_effect(STATUS_EFFECT_FLESHMEND))
		to_chat(user, span_warning("Our healing's effectiveness is reduced by quick repeated use!"))

	user.apply_status_effect(STATUS_EFFECT_FLESHMEND)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))

	return TRUE

