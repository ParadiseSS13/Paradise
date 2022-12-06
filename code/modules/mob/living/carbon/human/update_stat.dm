/mob/living/carbon/human/update_stat(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		return ..()
	..()
	if(stat == DEAD)
		if(dna.species && dna.species.can_revive_by_healing)
			var/obj/item/organ/internal/brain/B = get_int_organ(/obj/item/organ/internal/brain)
			if(B)
				if((health >= (HEALTH_THRESHOLD_DEAD + HEALTH_THRESHOLD_CRIT) * 0.5) && getBrainLoss() < 120)
					update_revive()

/mob/living/carbon/human/update_nearsighted_effects()
	var/obj/item/clothing/glasses/G = glasses
	if((NEARSIGHTED in mutations) && (!istype(G) || !G.prescription))
		overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("nearsighted")


/mob/living/carbon/human/can_hear()
	. = TRUE // Fallback if we don't have a species
	if(dna.species)
		. = dna.species.can_hear(src)

/mob/living/carbon/human/check_death_method()
	return dna.species.dies_at_threshold
