/datum/action/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form, curing diseases, removing parasites, sobering us, purging toxins and radiation, and resetting our genetic code completely. Costs 20 chemicals."
	helptext = "Can be used while unconscious."
	button_icon_state = "panacea"
	chemical_cost = 20
	dna_cost = 1
	req_stat = UNCONSCIOUS
	power_type = CHANGELING_PURCHASABLE_POWER

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
	INVOKE_ASYNC(src, PROC_REF(heal_tox), user)
	for(var/thing in user.viruses)
		var/datum/disease/D = thing
		if(D.severity == NONTHREAT)
			continue
		D.cure()

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/panacea/proc/heal_tox(mob/living/user)
	for(var/i in 1 to 10)
		user.adjustToxLoss(-5) //Has the same healing as 20 charcoal, but happens faster
		user.radiation = max(0, user.radiation - 70) //Same radiation healing as pentetic
		user.adjustBrainLoss(-5)
		user.AdjustDrunk(-12 SECONDS) //50% stronger than antihol
		user.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 10)
		for(var/datum/reagent/R in user.reagents.reagent_list)
			if(!R.harmless)
				user.reagents.remove_reagent(R.id, 2)
		sleep(2 SECONDS)
