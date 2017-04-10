/mob/living/carbon/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
//		if(health <= min_health)
		if(health <= config.health_threshold_dead)
			death()
			return
//		if(paralysis || sleeping || getOxyLoss() > low_oxy_ko || (status_flags & FAKEDEATH) || health <= crit_health)
		if(paralysis || sleeping || getOxyLoss() > 50 || (status_flags & FAKEDEATH) || health <= config.health_threshold_crit)
			if(stat == CONSCIOUS)
				KnockOut()
		else
			if(stat == UNCONSCIOUS)
				WakeUp()
