/datum/event/mass_hallucination/setup()
	announceWhen = rand(0, 20)

/datum/event/mass_hallucination/start()
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(H.stat == DEAD)
			continue
		var/turf/T = get_turf(H)
		if(!is_station_level(T.z))
			continue
		var/armor = H.getarmor(type = RAD)
		if(HAS_TRAIT(H, TRAIT_RADIMMUNE) || armor >= 75) // Leave radiation-immune species/rad armored players completely unaffected
			continue
		H.AdjustHallucinate(rand(50, 100))

/datum/event/mass_hallucination/announce()
	GLOB.event_announcement.Announce("It seems that station [station_name()] is passing through a minor radiation field, this may cause some hallucination, but no further damage")
