/datum/spell_handler/vampire
	var/required_blood
	/// If the blood cost should be handled by this handler. Or if the spell will handle it itself
	var/deduct_blood_on_cast = TRUE

/datum/spell_handler/vampire/can_cast(mob/user, charge_check, show_message, datum/spell/spell)
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)

	if(!vampire)
		return FALSE

	var/fullpower = vampire.get_ability(/datum/vampire_passive/full)

	if(user.stat >= DEAD) // TODO check if needed
		if(show_message)
			to_chat(user, "<span class='warning'>Not while you're dead!</span>")
		return FALSE

	if(vampire.nullified >= VAMPIRE_COMPLETE_NULLIFICATION && !fullpower) // above 100 nullification vampire powers are useless
		if(show_message)
			to_chat(user, "<span class='warning'>Something is blocking your powers!</span>")
		return FALSE
	if(vampire.bloodusable < required_blood)
		if(show_message)
			to_chat(user, "<span class='warning'>You require at least [required_blood] units of usable blood to do that!</span>")
		return FALSE
	//chapel check
	if(istype(get_area(user), /area/station/service/chapel) && !fullpower)
		if(show_message)
			to_chat(user, "<span class='warning'>Your powers are useless on this holy ground.</span>")
		return FALSE
	return TRUE

/datum/spell_handler/vampire/spend_spell_cost(mob/user, datum/spell/spell)
	if(!required_blood || !deduct_blood_on_cast) //don't take the blood yet if this is false!
		return

	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/blood_cost = calculate_blood_cost(vampire)
	vampire.subtract_usable_blood(blood_cost)

/datum/spell_handler/vampire/proc/calculate_blood_cost(datum/antagonist/vampire/vampire)
	var/blood_cost_modifier = 1 + vampire.nullified / 100
	var/blood_cost = round(required_blood * blood_cost_modifier)
	return blood_cost

/datum/spell_handler/vampire/after_cast(list/targets, mob/user, datum/spell/spell)
	if(!spell.should_recharge_after_cast)
		return
	if(!required_blood)
		return
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	to_chat(user, "<span class='boldnotice'>You have [vampire.bloodusable] left to use.</span>")
	SSblackbox.record_feedback("tally", "vampire_powers_used", 1, "[spell]") // Only log abilities which require blood

