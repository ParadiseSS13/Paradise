/mob/living/carbon/slime/updatehealth()
	// TODO: Make slime max health not be hard-coded
	if(is_adult)
		health = 200 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())
	else
		health = 150 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())
	update_stat()
