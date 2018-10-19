/mob/living/silicon/decoy/Life(seconds, times_fired)
	return


/mob/living/silicon/decoy/updatehealth(reason = "none given")
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
	update_stat("updatehealth([reason])")


/mob/living/silicon/decoy/update_stat(reason = "none given")
	if(stat == DEAD)
		return
	if(health <= 0)
		death()
		create_debug_log("died of damage, trigger reason: [reason]")
