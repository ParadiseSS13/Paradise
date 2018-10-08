/mob/living/carbon/brain/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return
		// if(health <= min_health)
	if(stat == DEAD)
		if(container && health > config.health_threshold_dead)
			update_revive()
			create_debug_log("revived, trigger reason: [reason]")
			return
	else
		if(!container || health <= config.health_threshold_dead)
			// Considered "dead" without any external apparatus
			death()
			create_debug_log("died, trigger reason: [reason]")
			return
			// Put brain(organ) damaging code here
