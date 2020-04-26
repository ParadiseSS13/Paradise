// Makes it so they happen instantly no matter the intent

/datum/martial_combo/krav_maga

/datum/martial_combo/krav_maga/check_combo(step, mob/living/target)
	return TRUE

/datum/martial_combo/krav_maga/progress_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	return perform_combo(user, target, MA)
