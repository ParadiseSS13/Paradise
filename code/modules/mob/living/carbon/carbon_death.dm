/mob/living/carbon/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	if(reagents)
		reagents.death_metabolize(src)

	for(var/obj/item/organ/internal/I in internal_organs)
		I.on_owner_death()
