/datum/action/changeling/fleshmend
	name = "Fleshmend"
	desc = "Our flesh rapidly regenerates, healing our burns, bruises, and shortness of breath. Costs 20 chemicals."
	helptext = "Does not regrow limbs. Partially recovers our blood. Functions while unconscious."
	button_icon_state = "fleshmend"
	chemical_cost = 20
	dna_cost = 5
	req_stat = UNCONSCIOUS
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/defence

//Starts healing you every second for 10 seconds. Can be used whilst unconscious.
/datum/action/changeling/fleshmend/sting_action(mob/living/user)
	to_chat(user, "<span class='notice'>We begin to heal rapidly.</span>")
	if(user.has_status_effect(STATUS_EFFECT_FLESHMEND))
		to_chat(user, "<span class='warning'>Our healing's effectiveness is reduced \
			by quick repeated use!</span>")

	user.apply_status_effect(STATUS_EFFECT_FLESHMEND)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
