/mob/living/silicon/ai/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(M, "You cannot attack people before the game has started.")
		return
	..()

/mob/living/silicon/ai/attack_slime(mob/living/simple_animal/slime/user)
	return //immune to slimes
