/mob/living/silicon/pai/incapacitated()
	// can a pAI even sleep
	return (stat || weakened || paralysis || sleeping)

// State Updating procs

/mob/living/silicon/pai/update_stat()
	if(health <= 0)
		death(gibbed = 0)
