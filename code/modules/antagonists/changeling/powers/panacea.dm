/datum/action/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form, curing diseases, removing parasites, sobering us, purging toxins and radiation, and resetting our genetic code completely. Costs 20 chemicals."
	helptext = "Can be used while unconscious."
	button_icon_state = "panacea"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 20
	req_stat = UNCONSCIOUS


/**
 * Heals the things that the other regenerative abilities don't.
 */
/datum/action/changeling/panacea/sting_action(mob/living/user)

	to_chat(user, span_notice("We cleanse impurities from our form."))

	var/mob/living/simple_animal/borer/borer = user.has_brain_worms()
	if(borer)
		borer.leave_host()
		if(iscarbon(user))
			var/mob/living/carbon/c_user = user
			c_user.vomit(FALSE)

	var/obj/item/organ/internal/body_egg/egg = user.get_int_organ(/obj/item/organ/internal/body_egg)
	if(egg)
		egg.remove(user)
		if(iscarbon(user))
			var/mob/living/carbon/human/c_user = user
			c_user.vomit()
		egg.forceMove(get_turf(user))

	user.reagents.add_reagent("mutadone", 2)
	user.apply_status_effect(STATUS_EFFECT_PANACEA)

	for(var/datum/disease/virus in user.viruses)
		if(virus.severity == NONTHREAT)
			continue
		virus.cure()

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

