/mob/living/carbon/death(gibbed)
	losebreath = 0
	med_hud_set_health()
	med_hud_set_status()

	if(reagents)
		reagents.death_metabolize(src)

	..(gibbed)