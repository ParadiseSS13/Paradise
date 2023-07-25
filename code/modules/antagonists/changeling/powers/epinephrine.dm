/datum/action/changeling/epinephrine
	name = "Epinephrine Overdose"
	desc = "We evolve additional sacs of adrenaline throughout our body. Costs 30 chemicals."
	helptext = "Removes all stuns instantly and adds a short term reduction in further stuns. Can be used while unconscious. Continued use poisons the body."
	button_icon_state = "adrenaline"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 30
	req_human = TRUE
	req_stat = UNCONSCIOUS


/datum/action/changeling/epinephrine/sting_action(mob/living/user)

	if(user.lying)
		to_chat(user, span_notice("We arise."))
	else
		to_chat(user, span_notice("Adrenaline rushes through us."))

	user.SetSleeping(0)
	user.WakeUp()
	user.SetParalysis(0)
	user.SetStunned(0)
	user.SetWeakened(0)
	user.lying = FALSE
	user.resting = FALSE
	user.update_canmove()
	user.reagents.add_reagent("synaptizine", 20)
	user.adjustStaminaLoss(-95)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
