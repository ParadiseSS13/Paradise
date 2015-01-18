/datum/event/mass_hallucination/start()
	for(var/mob/living/carbon/human/C in living_mob_list)
		if(!(C.species.flags & IS_SYNTHETIC))
			C.hallucination += rand(70, 100)