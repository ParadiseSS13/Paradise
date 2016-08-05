/mob/living/carbon/human/interactive/angry/New()
	TRAITS |= TRAIT_ROBUST
	TRAITS |= TRAIT_MEAN
	faction += "bot_angry"
	..()

/mob/living/carbon/human/interactive/friendly/New()
	TRAITS |= TRAIT_FRIENDLY
	TRAITS |= TRAIT_UNROBUST
	faction += "bot_friendly"
	faction += "neutral"
	functions -= "combat"
	..()

/mob/living/carbon/human/interactive/greytide/New()
	TRAITS |= TRAIT_ROBUST
	TRAITS |= TRAIT_MEAN
	TRAITS |= TRAIT_THIEVING
	TRAITS |= TRAIT_DUMB
	maxInterest = 5 // really short attention span
	targetInterestShift = 2 // likewise
	faction += "bot_grey"
	graytide = 1
	..()