/mob/living/carbon/IsWeakened(include_stamcrit = TRUE)
		return ..() || (include_stamcrit && stam_paralyzed)

/mob/living/carbon/proc/enter_stamcrit()
	if(!(status_flags & CANWEAKEN))
		return
	if(absorb_stun(0)) //continuous effect, so we don't want it to increment the stuns absorbed.
		return
	if(!IsWeakened())
		to_chat(src, "<span class='notice'>You're too exhausted to keep going...</span>")
	SEND_SIGNAL(src, COMSIG_CARBON_ENTER_STAMINACRIT)
	stam_regen_start_time = world.time + (STAMINA_REGEN_BLOCK_TIME * stamina_regen_block_modifier)
	var/prev = stam_paralyzed
	stam_paralyzed = TRUE
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, STAM_CRIT)
	ADD_TRAIT(src, TRAIT_FLOORED, STAM_CRIT)
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, STAM_CRIT)
	if(!prev && getStaminaLoss() < 120) // Puts you a little further into the initial stamcrit, makes stamcrit harder to outright counter with chems.
		adjustStaminaLoss(30, FALSE)
