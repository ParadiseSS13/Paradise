/datum/event/mass_hallucination/setup()
	announceWhen = rand(0, 20)

/datum/event/mass_hallucination/start()
	for(var/mob/living/carbon/human as anything in GLOB.human_list)
		if(human.stat == DEAD)
			continue
		var/turf/turf = get_turf(human)
		if(!is_station_level(turf?.z))
			continue
		if(HAS_TRAIT(human, TRAIT_RADIMMUNE) || human.getarmor(armor_type = RAD) >= 150) // Leave radiation-immune species/rad armored players completely unaffected
			continue
		human.AdjustHallucinate(rand(50 SECONDS, 100 SECONDS))

/datum/event/mass_hallucination/announce()
	GLOB.minor_announcement.Announce("The [station_name()] is passing through a minor radiation field. Be advised that acute exposure to space radiation can induce hallucinogenic episodes.")
