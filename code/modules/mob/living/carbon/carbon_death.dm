/mob/living/carbon/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	if(!gibbed)
		apply_status_effect(STATUS_EFFECT_REVIVABLE)

	if(reagents)
		reagents.death_metabolize(src)

	for(var/obj/item/organ/internal/I in internal_organs)
		I.on_owner_death()
