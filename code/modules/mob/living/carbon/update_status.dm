// UI updating procs

// State query procs

/mob/living/carbon/restrained(ignore_grab)
	return

/mob/living/carbon/can_stand()
	return ..() && !((health - staminaloss) <= softcrit_health)

// State updating procs


/mob/living/carbon/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= min_health)
			death()
			return
		if(paralysis || sleeping || getOxyLoss() > low_oxy_ko || (status_flags & FAKEDEATH) || health <= crit_health)
			if(stat == CONSCIOUS)
				KnockOut()
		else
			if(stat == UNCONSCIOUS)
				// updating=FALSE because `WakeUp` will handle canmove up for us
				StopResting(updating=FALSE)
				WakeUp()
		update_damage_hud()
		update_health_hud()
		med_hud_set_status()

/mob/living/carbon/update_stamina()
	if(staminaloss)
		var/total_health = (health - staminaloss)
		if((total_health <= softcrit_health) && stat == CONSCIOUS)
			to_chat(src, "<span class='notice'>You're too exhausted to keep going...</span>")
			Weaken(5)
			// So we don't immediately collapse again
			setStaminaLoss((health - softcrit_health) - 2)
		update_health_hud()

/mob/living/carbon/proc/update_embedded_objects()
	var/list/E = get_damaging_implants()
	if(embedded_flag)
		if(!E.len)
			embedded_flag = 0
	else
		if(E.len)
			embedded_flag = 1

	var/list/F = get_visible_implants()
	if(F.len)
		verbs += /mob/proc/yank_out_object
	else
		verbs -= /mob/proc/yank_out_object
