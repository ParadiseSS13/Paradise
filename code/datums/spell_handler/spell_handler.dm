/**
 * The base class for the handler systems spells use.
 * Subtypes of this class can be added to spells to modify their behaviour and change their can_cast.
 * Thus allowing for a more modular behaviour system. For example a vampire spell that jaunts can just add the vampire spell_handler to the jaunt spell
 */

/datum/spell_handler

/datum/spell_handler/proc/can_cast(mob/user, charge_check, show_message, datum/spell/spell)
	return TRUE

/datum/spell_handler/proc/spend_spell_cost(mob/user, datum/spell/spell)
	return

/datum/spell_handler/proc/revert_cast(mob/user, datum/spell/spell)
	return

/datum/spell_handler/proc/before_cast(list/targets, mob/user, datum/spell/spell)
	return

/datum/spell_handler/proc/after_cast(list/targets, mob/user, datum/spell/spell)
	return
