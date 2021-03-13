/datum/reagent/medicine/regen_jelly
	name = "Regenerative Jelly"
	id = "regen_jelly"
	description = "Gradually regenerates all types of damage, without harming slime anatomy."
	reagent_state = LIQUID
	color = "#91D865"
	taste_description = "jelly"

/datum/reagent/medicine/regen_jelly/on_mob_life(mob/living/carbon/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustToxLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags
