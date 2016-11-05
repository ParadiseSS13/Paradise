/mob/living/simple_animal/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= min_health)
			death()
		// apparently mice sleep, let's find out what this breaks
		// else
		// 	// No rest for the simple - this shouldn't happen
		// 	if(stat == UNCONSCIOUS)
		// 		log_runtime(EXCEPTION("Unconscious simple animal!"), src)
		// 		WakeUp()


/mob/living/simple_animal/update_canmove(delay_action_updates = 0)
	if(incapacitated())
		drop_r_hand()
		drop_l_hand()
		canmove = 0
	else if(buckled)
		canmove = 0
	else
		canmove = 1
	update_transform()
	if(!delay_action_updates)
		update_action_buttons_icon()
	return canmove
