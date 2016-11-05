/mob/living/silicon/robot/can_see()
	return ..() && is_component_functioning("camera")

// No args for restraints because robots don't have those
/mob/living/silicon/robot/incapacitated()
	if(stat || lockcharge || weakened || stunned || paralysis || !is_component_functioning("actuator"))
		return 1

// Update mob state

/mob/living/silicon/robot/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src))
			return

	if(sight_mode & BORGMESON)
		sight |= SEE_TURFS
		see_invisible = min(see_invisible, SEE_INVISIBLE_MINIMUM)
		see_in_dark = 1

	// if(sight_mode & BORGMATERIAL)
	// 	sight |= SEE_OBJS
	// 	see_invisible = min(see_invisible, SEE_INVISIBLE_MINIMUM)
	// 	see_in_dark = 1

	if(sight_mode & BORGXRAY)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_invisible = SEE_INVISIBLE_LIVING
		see_in_dark = 8

	if(sight_mode & BORGTHERM)
		sight |= SEE_MOBS
		see_invisible = min(see_invisible, SEE_INVISIBLE_LIVING)
		see_in_dark = 8

	if(see_override)
		see_invisible = see_override

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
	diag_hud_set_status()
	diag_hud_set_health()
	update_health_hud()
