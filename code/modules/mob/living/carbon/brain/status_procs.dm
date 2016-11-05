// Since `AdjustSTATE` and `STATE` procs are just wrappers around `SetSTATE`
// procs, we can negate them by not implementing `SetSTATE` here

// no ears to damage or heal
/mob/living/carbon/brain/SetEarDeaf()
	return

/mob/living/carbon/brain/SetEarDamage()
	return
