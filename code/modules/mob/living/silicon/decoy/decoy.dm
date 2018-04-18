/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/mob/ai.dmi'//
	icon_state = "ai"
	anchored = 1 // -- TLE
	canmove = 0

/mob/living/silicon/decoy/New()
	src.icon = 'icons/mob/ai.dmi'
	src.icon_state = "ai"
	src.anchored = 1
	src.canmove = 0