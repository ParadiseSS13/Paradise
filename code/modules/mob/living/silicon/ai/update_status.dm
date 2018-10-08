/mob/living/silicon/ai/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= config.health_threshold_dead)
			death()
			create_debug_log("died of damage, trigger reason: [reason]")
			return
		else if(stat == UNCONSCIOUS)
			WakeUp()
			create_debug_log("woke up, trigger reason: [reason]")
	//diag_hud_set_status()

/mob/living/silicon/ai/has_vision(information_only = FALSE)
	return ..() && !lacks_power()
