/datum/event/mass_hallucination/setup()
	announceWhen = rand(0, 20)

/datum/event/mass_hallucination/start()
	for(var/mob/living/carbon/human/H in GLOB.living_mob_list)
		var/armor = H.getarmor(type = "rad")
		if((RADIMMUNE in H.dna.species.species_traits) || armor >= 75) // Leave radiation-immune species/rad armored players completely unaffected
			continue
		H.AdjustHallucinate(rand(50, 100))

/datum/event/mass_hallucination/announce()
	GLOB.event_announcement.Announce("Parece que la estacion esta pasando a traves de un campo de radiacion menor, esto puede causar algunas alucinaciones, pero no mas danos.")
