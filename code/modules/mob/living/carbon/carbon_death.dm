/mob/living/carbon/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	if(!gibbed && !HAS_TRAIT(src, TRAIT_FAKEDEATH))
		// We dont want people who have fake death to have the status effect applied a second time when they actually die
		apply_status_effect(STATUS_EFFECT_REVIVABLE)

	if(reagents)
		reagents.death_metabolize(src)

	for(var/obj/item/organ/internal/I in internal_organs)
		I.on_owner_death()
