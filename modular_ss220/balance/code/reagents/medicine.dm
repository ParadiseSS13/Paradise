/datum/reagent/medicine/syndicate_nanites
	overdose_threshold = 50
	harmless = FALSE

/datum/reagent/medicine/syndicate_nanites/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustCloneLoss(1.5 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return list(0, update_flags)
