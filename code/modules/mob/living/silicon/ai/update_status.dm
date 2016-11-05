/mob/living/silicon/ai/update_sight()
	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)
	if(aiRestorePowerRoutine)
		sight = sight&~SEE_TURFS
		sight = sight&~SEE_MOBS
		sight = sight&~SEE_OBJS
		see_in_dark = 0

	if(see_override)
		see_invisible = see_override

/mob/living/silicon/ai/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= config.health_threshold_dead)
			death()
			return
		else if(stat == UNCONSCIOUS)
			WakeUp()
	diag_hud_set_status()
