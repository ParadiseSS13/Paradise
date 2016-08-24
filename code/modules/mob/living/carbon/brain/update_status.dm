// Brains do not update sight(?)
/mob/living/carbon/brain/update_sight()
	return

// This renders brains immune to:
/*
	* paralysis
	* sleep
	* suffocation-induced-blackout
	* Fake death
	* Critical health
*/
/mob/living/carbon/brain/update_stat()
	if(status_flags & GODMODE)
		return
	if(health <= min_health)
		if(stat != DEAD)
			death()
