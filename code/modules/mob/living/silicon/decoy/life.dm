// Life without a parent call
// o_0
/mob/living/silicon/decoy/Life()
	if(src.stat == DEAD)
		return
	else
		if(src.health <= config.health_threshold_dead && src.stat != DEAD)
			death()
			return


/mob/living/silicon/decoy/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		if(stat != CONSCIOUS)
			update_revive()
	else
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
		update_stat()
