/datum/event/mass_hallucination/setup()
	announceWhen = rand(0, 20)

/datum/event/mass_hallucination/start()
	for(var/mob/living/carbon/human/C in living_mob_list)
		if(!(C.species.flags & IS_SYNTHETIC))
			C.hallucination += rand(50, 100)
/datum/event/mass_hallucination/announce()
	command_alert("It seems that station [station_name()] is passing through a minor radiation field, this may cause some hallucination, but no further damage")