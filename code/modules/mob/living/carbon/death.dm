/mob/living/carbon/death(gibbed)
	SetLoseBreath(0)
	med_hud_set_health()
	med_hud_set_status()

	if(reagents)
		reagents.death_metabolize(src)

	for(var/obj/item/organ/internal/I in internal_organs)
		I.on_owner_death()

	..(gibbed)
