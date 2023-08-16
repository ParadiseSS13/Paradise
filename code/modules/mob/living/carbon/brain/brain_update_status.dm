/mob/living/carbon/brain/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return
		// if(health <= min_health)
	if(stat == DEAD)
		if(container && health > HEALTH_THRESHOLD_DEAD && !suiciding)
			update_revive()
			create_debug_log("revived, trigger reason: [reason]")
			return
	else
		if(!container || health <= HEALTH_THRESHOLD_DEAD && check_death_method())
			// Considered "dead" without any external apparatus
			death()
			create_debug_log("died, trigger reason: [reason]")
			return
			// Put brain(organ) damaging code here
