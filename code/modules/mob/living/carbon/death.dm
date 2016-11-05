/mob/living/carbon/death(gibbed)
	. = ..()
	if(!.)	return
	// Is this really needed?
	SetLoseBreath(0)
	med_hud_set_health()
	med_hud_set_status()

	if(reagents)
		reagents.death_metabolize(src)
