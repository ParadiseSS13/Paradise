// No args for restraints because robots don't have those
/mob/living/silicon/robot/incapacitated()
	if(stat || lockcharge || weakened || stunned || paralysis || !is_component_functioning("actuator"))
		return 1

/mob/living/silicon/robot/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= -maxHealth) //die only once
			death()
			return
		if(!is_component_functioning("actuator") || paralysis || sleeping || stunned || weakened || getOxyLoss() > maxHealth * 0.5)
			if(stat == CONSCIOUS)
				KnockOut()
		else
			if(stat == UNCONSCIOUS)
				WakeUp()
	// diag_hud_set_status()
	// diag_hud_set_health()
	// update_health_hud()
