// Dealing toxins when drinking alcohol
/obj/item/organ/internal/kidneys/skrell/on_life()
	. = ..()
	var/datum/reagent/consumable/ethanol/ethanol_reagent = locate(/datum/reagent/consumable/ethanol) in owner.reagents.reagent_list
	if(!ethanol_reagent)
		return
	if(is_broken())
		owner.adjustToxLoss(1.5 * max(ethanol_reagent.alcohol_perc, 1) * PROCESS_ACCURACY)
	else
		owner.adjustToxLoss(0.5 * max(ethanol_reagent.alcohol_perc, 1) * PROCESS_ACCURACY)
		receive_damage(0.1 * PROCESS_ACCURACY)

// Weak night vision
/obj/item/organ/internal/eyes/skrell
	see_in_dark = 3

// Reagent scan for food
/obj/item/food/examine(mob/user)
	. = ..()
	if(!isskrell(user))
		return
	. += "<span class='notice'>It contains:</span>"
	for(var/datum/reagent/reagent_inside_food as anything in reagents.reagent_list)
		. += "<span class='notice'>[reagent_inside_food.volume] units of [reagent_inside_food.name]</span>"

// Reagent scan for solutions
/mob/living/carbon/human/reagent_vision()
	return isskrell(src) || ..()

// Getting less toxins
/datum/species/skrell
	tox_mod = 0.9
