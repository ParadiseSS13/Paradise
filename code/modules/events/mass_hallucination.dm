/datum/event/mass_hallucination/setup()
	announceWhen = rand(0, 20)

/datum/event/mass_hallucination/start()
	for(var/mob/living/carbon/human/H in living_mob_list)
		var/armor = H.getarmor(attack_flag = "rad")
		if((H.species.flags & NO_DNA_RAD) || armor >= 75) // Leave DNA-less species/rad armored players completely unaffected
			continue
		H.hallucination += rand(50, 100)
			
/datum/event/mass_hallucination/announce()
	command_announcement.Announce("It seems that station [station_name()] is passing through a minor radiation field, this may cause some hallucination, but no further damage")