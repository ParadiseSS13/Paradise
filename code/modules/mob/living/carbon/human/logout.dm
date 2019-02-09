/mob/living/carbon/human/Logout()
	..()
	if(mind.active)
		overlays += image('icons/effects/effects.dmi', icon_state = "zzz_glow")