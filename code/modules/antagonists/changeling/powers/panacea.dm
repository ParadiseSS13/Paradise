/datum/action/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form, curing diseases, removing parasites, sobering us, purging toxins and radiation, and resetting our genetic code completely. Costs 20 chemicals."
	helptext = "Can be used while unconscious."
	button_icon_state = "panacea"
	chemical_cost = 20
	dna_cost = 2
	req_stat = UNCONSCIOUS
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/defence

//Heals the things that the other regenerative abilities don't.
/datum/action/changeling/panacea/sting_action(mob/living/user)

	to_chat(user, "<span class='notice'>We cleanse impurities from our form.</span>")

	var/obj/item/organ/internal/body_egg/egg = user.get_int_organ(/obj/item/organ/internal/body_egg)
	if(egg)
		egg.remove(user)
		if(iscarbon(user))
			var/mob/living/carbon/human/C = user
			C.vomit()
		egg.forceMove(get_turf(user))

	user.reagents.add_reagent("mutadone", 1)
	user.apply_status_effect(STATUS_EFFECT_PANACEA)
	for(var/thing in user.viruses)
		var/datum/disease/D = thing
		if(D.severity == VIRUS_NONTHREAT)
			continue
		D.cure()

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
