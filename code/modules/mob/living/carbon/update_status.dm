/mob/living/carbon/update_stat(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		return ..()
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD && check_death_method())
			death()
			return
		if(paralysis || sleeping || (check_death_method() && getOxyLoss() > 50) || (status_flags & FAKEDEATH) || health <= HEALTH_THRESHOLD_CRIT && check_death_method())
			if(stat == CONSCIOUS)
				KnockOut()
		else
			if(stat == UNCONSCIOUS)
				WakeUp()
	..()

/mob/living/carbon/update_stamina()
	var/stam = getStaminaLoss()
	if(stam > DAMAGE_PRECISION && (maxHealth - stam) <= HEALTH_THRESHOLD_CRIT && !stat)
		enter_stamcrit()
	else if(stam_paralyzed)
		stam_paralyzed = FALSE
		update_canmove()

/mob/living/carbon/can_hear()
	. = FALSE
	var/obj/item/organ/internal/ears/ears = get_int_organ(/obj/item/organ/internal/ears)
	if(istype(ears) && !ears.deaf)
		. = TRUE
