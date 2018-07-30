/mob/living/carbon/human/interactive/angry/Initialize(mapload)
	TRAITS |= TRAIT_ROBUST
	TRAITS |= TRAIT_MEAN
	faction += "bot_angry"
	return ..()

/mob/living/carbon/human/interactive/friendly/Initialize(mapload)
	TRAITS |= TRAIT_FRIENDLY
	TRAITS |= TRAIT_UNROBUST
	faction += "bot_friendly"
	faction += "neutral"
	functions -= "combat"
	return ..()

/mob/living/carbon/human/interactive/greytide/Initialize(mapload)
	TRAITS |= TRAIT_ROBUST
	TRAITS |= TRAIT_MEAN
	TRAITS |= TRAIT_THIEVING
	TRAITS |= TRAIT_DUMB
	maxInterest = 5 // really short attention span
	targetInterestShift = 2 // likewise
	faction += "bot_grey"
	graytide = 1
	return ..()
