/datum/action/changeling/contort_body
	name = "Contort Body"
	desc = "We contort our body, allowing us to fit in and under things we normally wouldn't be able to. Costs 25 chemicals."
	button_icon_state = "contort_body"
	chemical_cost = 25
	dna_cost = 2
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/contort_body/Remove(mob/M)
	REMOVE_TRAIT(M, TRAIT_CONTORTED_BODY, CHANGELING_TRAIT)
	..()

/datum/action/changeling/contort_body/sting_action(mob/living/user)
	if(HAS_TRAIT_FROM(user, TRAIT_CONTORTED_BODY, CHANGELING_TRAIT))
		REMOVE_TRAIT(user, TRAIT_CONTORTED_BODY, CHANGELING_TRAIT)
		to_chat(user, "<span class='notice'>Our body stiffens and returns to form.</span>")
		if(IS_HORIZONTAL(user))
			user.layer = initial(user.layer)
	else
		ADD_TRAIT(user, TRAIT_CONTORTED_BODY, CHANGELING_TRAIT)
		to_chat(user, "<span class='notice'>We contort our form to allow us to fit in and under things we normally wouldn't be able to.</span>")
		if(IS_HORIZONTAL(user))
			user.layer = TURF_LAYER + 0.2

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
