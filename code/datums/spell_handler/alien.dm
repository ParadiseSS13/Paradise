/datum/spell_handler/alien
	/// Amount of plasma required to use this ability
	var/plasma_cost = 0

/datum/spell_handler/alien/can_cast(mob/living/carbon/user, charge_check, show_message, obj/effect/proc_holder/spell/spell)
	var/obj/item/organ/internal/xenos/plasmavessel/vessel = user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
	if(!vessel)
		return FALSE
	if(vessel.stored_plasma < plasma_cost)
		if(show_message)
			to_chat(user, "<span class='warning'>You require at least [plasma_cost] plasma to use this ability!</span>")
		return FALSE
	return TRUE

/datum/spell_handler/alien/spend_spell_cost(mob/living/carbon/user, obj/effect/proc_holder/spell/spell)
	user.use_plasma_spell(plasma_cost, user)

/datum/spell_handler/alien/before_cast(list/targets, mob/living/carbon/user, obj/effect/proc_holder/spell/spell)
	if(plasma_cost)
		to_chat(user, "<span class='boldnotice'>You have [user.getPlasma()] plasma left to use.</span>")

/datum/spell_handler/alien/revert_cast(mob/living/carbon/user, obj/effect/proc_holder/spell/spell)
	user.add_plasma(plasma_cost, user)
	to_chat(user, "<span class='boldnotice'>You have [user.getPlasma()] plasma left to use.</span>")

/mob/living/carbon/proc/getPlasma()
	var/obj/item/organ/internal/xenos/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
	if(!vessel)
		return FALSE
	return vessel.stored_plasma

/mob/living/carbon/proc/adjustPlasma(amount)
	var/obj/item/organ/internal/xenos/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
	if(!vessel)
		return
	vessel.stored_plasma = max(vessel.stored_plasma + amount, 0)
	vessel.stored_plasma = min(vessel.stored_plasma, vessel.max_plasma) //upper limit of max_plasma, lower limit of 0
	return FALSE

/mob/living/carbon/alien/adjustPlasma(amount)
	. = ..()
	updatePlasmaDisplay()
