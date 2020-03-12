/obj/item/organ/internal/liver
	name = "liver"
	icon_state = "liver"
	organ_tag = "liver"
	parent_organ = "groin"
	slot = "liver"
	var/alcohol_intensity = 1

/obj/item/organ/internal/liver/on_life()
	if(germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			to_chat(owner, "<span class='warning'> Your skin itches.</span>")
	if(germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			owner.vomit()

	if(owner.life_tick % PROCESS_ACCURACY == 0)

		//High toxins levels are dangerous
		if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent("charcoal"))
			//Healthy liver suffers on its own
			if(damage < min_broken_damage)
				receive_damage(0.2 * PROCESS_ACCURACY)
			//Damaged one shares the fun
			else
				var/obj/item/organ/internal/O = pick(owner.internal_organs)
				if(O)
					O.receive_damage(0.2  * PROCESS_ACCURACY)

		//Detox can heal small amounts of damage
		if(damage && damage < min_bruised_damage && owner.reagents.has_reagent("charcoal"))
			receive_damage(-0.2 * PROCESS_ACCURACY)

		// Get the effectiveness of the liver.
		var/filter_effect = 3
		if(is_bruised())
			filter_effect -= 1
		if(is_broken())
			filter_effect -= 2

		// Damaged liver means some chemicals are very dangerous
		if(damage >= min_bruised_damage)
			for(var/datum/reagent/R in owner.reagents.reagent_list)
				// Ethanol and all drinks are bad
				if(istype(R, /datum/reagent/consumable/ethanol))
					owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)

			// Can't cope with toxins at all
			for(var/toxin in GLOB.liver_toxins)
				if(owner.reagents.has_reagent(toxin))
					owner.adjustToxLoss(0.3 * PROCESS_ACCURACY)

/obj/item/organ/internal/liver/cybernetic
	name = "cybernetic liver"
	icon_state = "liver-c"
	desc = "An electronic device designed to mimic the functions of a human liver. It has no benefits over an organic liver, but is easy to produce."
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT