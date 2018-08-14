/mob/living/silicon/decoy/Life(seconds, times_fired)
	return


/mob/living/silicon/decoy/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
	update_stat()


/mob/living/silicon/decoy/update_stat()
	if(stat == DEAD)
		return
	if(health <= 0)
		death()