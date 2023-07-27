/* This is the handler for alien spells
This relies on a lot of different procs on the spell and carbon level, so if you are editing this, remember to check that the other procs aren't editied in a way that
could change behavior.
You're gonna see a lot of plasmavessel checks and alien checks, as a lot of things need to work a certain way when used by an alien, and a different way when used by a human.
This was also the case with the verb implementation, it's just much more obvious now.
 */
/datum/spell_handler/alien
	/// Amount of plasma required to use this ability
	var/plasma_cost = 0


/datum/spell_handler/alien/can_cast(mob/living/carbon/user, charge_check, show_message, obj/effect/proc_holder/spell/spell)
	var/obj/item/organ/internal/xenos/plasmavessel/vessel = user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
	if(!vessel)
		return FALSE

	if(vessel.stored_plasma < plasma_cost)
		if(show_message)
			to_chat(user, span_warning("You require at least [plasma_cost] plasma to use this ability!"))
		return FALSE

	return TRUE


/datum/spell_handler/alien/spend_spell_cost(mob/living/carbon/user, obj/effect/proc_holder/spell/spell)
	user.use_plasma_spell(plasma_cost, user)


/datum/spell_handler/alien/before_cast(list/targets, mob/living/carbon/user, obj/effect/proc_holder/spell/spell)
	if(plasma_cost)
		to_chat(user, span_boldnotice("You have [user.get_plasma()] plasma left to use."))
		user.update_plasma_display(user, update_buttons = TRUE)


/datum/spell_handler/alien/revert_cast(mob/living/carbon/user, obj/effect/proc_holder/spell/spell)
	if(plasma_cost)
		user.adjust_alien_plasma(plasma_cost)
		to_chat(user, span_boldnotice("You have [user.get_plasma()] plasma left to use."))
		user.update_plasma_display(user, update_buttons = TRUE)


/mob/living/carbon/proc/use_plasma_spell(amount, mob/living/carbon/user)
	var/obj/item/organ/internal/xenos/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
	if(amount > vessel.stored_plasma)
		return FALSE
	adjust_alien_plasma(-amount)
	return TRUE

