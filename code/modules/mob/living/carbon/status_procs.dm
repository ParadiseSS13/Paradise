/mob/living/carbon/IsWeakened(include_stamcrit = TRUE)
		return ..() || (include_stamcrit && stam_paralyzed)

/mob/living/carbon/proc/enter_stamcrit()
	if(!(status_flags & CANWEAKEN))
		return
	if(absorb_stun(0)) //continuous effect, so we don't want it to increment the stuns absorbed.
		return
	if(!IsWeakened())
		to_chat(src, "<span class='notice'>You're too exhausted to keep going...</span>")
	var/prev = stam_paralyzed
	stam_paralyzed = TRUE
	update_canmove()
	if(!prev && getStaminaLoss() < 120) // Puts you a little further into the initial stamcrit, makes stamcrit harder to outright counter with chems.
		adjustStaminaLoss(30, FALSE)
