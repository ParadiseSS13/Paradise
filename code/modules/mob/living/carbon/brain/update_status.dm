/mob/living/carbon/brain/update_stat(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		return ..()
		// if(health <= min_health)
	if(stat == DEAD)
		if(container && health > HEALTH_THRESHOLD_DEAD)
			update_revive()
			return
	else
		if(!container || health <= HEALTH_THRESHOLD_DEAD && check_death_method())
			// Considered "dead" without any external apparatus
			death()
			return
			// Put brain(organ) damaging code here
	..()
