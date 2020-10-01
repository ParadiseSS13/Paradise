/mob/living/carbon/alien/larva/Life(seconds, times_fired)
	set invisibility = 0
	if(notransform)
		return
	if(..()) //not dead and not in stasis
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++
			update_icons()

/mob/living/carbon/alien/larva/update_stat(reason = "None given")
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= -maxHealth || !get_int_organ(/obj/item/organ/internal/brain))
			death()
			return

		if(paralysis || sleeping || getOxyLoss() > 50 || (health <= HEALTH_THRESHOLD_CRIT && check_death_method()))
			if(stat == CONSCIOUS)
				KnockOut()
				create_debug_log("fell unconscious, trigger reason: [reason]")
		else
			if(stat == UNCONSCIOUS)
				WakeUp()
				create_debug_log("woke up, trigger reason: [reason]")
	update_damage_hud()
	update_health_hud()
