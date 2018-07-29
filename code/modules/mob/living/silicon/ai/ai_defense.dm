/mob/living/silicon/ai/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return
	..()

/mob/living/silicon/ai/attack_slime(mob/living/carbon/slime/user)
	return //immune to slimes
