/mob/living/carbon/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD && check_death_method())
			death()
			create_debug_log("died of damage, trigger reason: [reason]")
			return
		if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || (check_death_method() && getOxyLoss() > 50) || HAS_TRAIT(src, TRAIT_FAKEDEATH) || health < HEALTH_THRESHOLD_KNOCKOUT && check_death_method())
			if(stat == CONSCIOUS)
				KnockOut()
				create_debug_log("fell unconscious, trigger reason: [reason]")
		else if(health < HEALTH_THRESHOLD_CRIT && check_death_method())
			KnockDown(3 SECONDS)
		else
			if(stat == UNCONSCIOUS)
				WakeUp()
				create_debug_log("woke up, trigger reason: [reason]")
	update_damage_hud()
	update_health_hud()
	med_hud_set_health()
	med_hud_set_status()

/mob/living/carbon/update_stamina()
	var/stam = getStaminaLoss()
	if(stam > DAMAGE_PRECISION && (maxHealth - stam) <= HEALTH_THRESHOLD_CRIT && !stat)
		enter_stamcrit()
	else if(stam_paralyzed)
		SEND_SIGNAL(src, COMSIG_CARBON_EXIT_STAMINACRIT)
		stam_paralyzed = FALSE
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "stam_crit") // make defines later
		REMOVE_TRAIT(src, TRAIT_FLOORED, "stam_crit")
		REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, "stam_crit")

/mob/living/carbon/can_hear()
	. = FALSE
	var/obj/item/organ/internal/ears/ears = get_int_organ(/obj/item/organ/internal/ears)
	if(istype(ears) && !HAS_TRAIT(src, TRAIT_DEAF))
		. = TRUE
