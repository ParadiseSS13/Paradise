/mob/living/silicon/robot/Logout()
	..()
	if(mind?.active && stat != DEAD)
		overlays += image('icons/effects/effects.dmi', icon_state = "zzz_glow_silicon")
