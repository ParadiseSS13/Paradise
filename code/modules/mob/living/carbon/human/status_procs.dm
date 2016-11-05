// EYES_BLOCKED

/mob/living/carbon/human/proc/BlockEyes()
	var/val_change = !eyes_blocked
	eyes_blocked = TRUE
	if(val_change)
		update_blind_effects()

/mob/living/carbon/human/proc/UnblockEyes()
	var/val_change = eyes_blocked
	eyes_blocked = FALSE
	if(val_change)
		update_blind_effects()
