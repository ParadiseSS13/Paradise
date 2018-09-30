/mob/living/carbon/human/interactive/angry/Initialize(mapload)
	TRAITS |= AI_TRAIT_ROBUST
	TRAITS |= AI_TRAIT_MEAN
	faction += "bot_angry"
	return ..()

/mob/living/carbon/human/interactive/friendly/Initialize(mapload)
	TRAITS |= AI_TRAIT_FRIENDLY
	TRAITS |= AI_TRAIT_UNROBUST
	faction += "bot_friendly"
	faction += "neutral"
	functions -= "combat"
	return ..()

/mob/living/carbon/human/interactive/greytide/Initialize(mapload)
	TRAITS |= AI_TRAIT_ROBUST
	TRAITS |= AI_TRAIT_MEAN
	TRAITS |= AI_TRAIT_THIEVING
	TRAITS |= AI_TRAIT_DUMB
	maxInterest = 5 // really short attention span
	targetInterestShift = 2 // likewise
	faction += "bot_grey"
	graytide = 1
	return ..()
