/**
 * Proc called to check if the ninja can afford an ability's cost.
 *
 * Proc which determine whether or not a space ninja can afford to use a specific ability.
 * It can also cancel stealth if the ability requested it.
 * Arguments:
 * * cost - the energy cost of the ability
 * * extraCheckFlag - Determines if the check is a normal one, an adrenaline one, heal one or a stealth cancel check.
 * * Returns TRUE if we can't perform the ability, and FALSE if we can.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninjacost(cost = 0, extraCheckFlag = 0)
	var/mob/living/carbon/human/ninja = affecting
	if(cost && cell.charge < cost)
		to_chat(ninja, span_warning("Not enough energy!"))
		return TRUE
	else
		cell.use(cost)
	switch(extraCheckFlag)
		if(N_STEALTH_CANCEL)
			if(stealth)
				cancel_stealth()		//Get rid of it.
			if(disguise_active)
				restore_form()			//This count's too
			if(spirited)
				cancel_spirit_form() 	//And another one!
		if(N_ADRENALINE)
			if(!a_boost.charge_counter)
				to_chat(ninja, span_warning("You do not have any more adrenaline boosters!"))
				return TRUE
		if(N_HEAL)
			if(!heal_chems.charge_counter)
				to_chat(ninja, span_warning("You do not have any more chemicals to heal yourself!"))
				return TRUE
	// 'return' below is no longer used to check the suit cooldown,
	// cause it was abolished and replaced by the cooldown per action system
	return FALSE
