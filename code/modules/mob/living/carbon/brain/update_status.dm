/mob/living/carbon/brain/update_stat()
	if(status_flags & GODMODE)
		return
		// if(health <= min_health)
	if(health <= config.health_threshold_dead)
		if(stat != DEAD)
			death()
			// Put brain(organ) damaging code here
