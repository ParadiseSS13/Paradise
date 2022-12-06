/mob/living/silicon/decoy/Life(seconds, times_fired)
	return

/mob/living/silicon/decoy/updatehealth(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		return ..()
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
	update_stat("updatehealth([reason])", should_log)

/mob/living/silicon/decoy/update_stat(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		return ..()
	if(stat == DEAD)
		return
	if(health <= 0)
		death()
	..()
