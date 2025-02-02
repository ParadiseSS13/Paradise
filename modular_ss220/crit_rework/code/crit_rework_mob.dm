/mob/living/carbon/human/handle_critical_condition()
	if(status_flags & GODMODE)
		return FALSE
	. = ..()
	if(health <= HEALTH_THRESHOLD_CRIT)
		AddComponent(/datum/component/softcrit)

/mob/living/carbon/human/check_death_method()
	return FALSE
