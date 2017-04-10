/mob/living/silicon/ai/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= config.health_threshold_dead)
			death()
			return
		else if(stat == UNCONSCIOUS)
			WakeUp()
	//diag_hud_set_status()
