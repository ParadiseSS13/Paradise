/datum/event/mass_hallucination/setup()
	announceWhen = rand(0, 20)

/datum/event/mass_hallucination/start()
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(H.stat == DEAD)
			continue
		var/turf/T = get_turf(H)
		if(!is_station_level(T?.z))
			continue
		var/armor = H.getarmor(type = RAD)
		if(HAS_TRAIT(H, TRAIT_RADIMMUNE) || armor >= 150) // Leave radiation-immune species/rad armored players completely unaffected
			continue
		H.AdjustHallucinate(rand(50 SECONDS, 100 SECONDS))

/datum/event/mass_hallucination/announce()
	GLOB.minor_announcement.Announce("[station_name()] проходит через радиационное поле низкой интенсивности. Возможно появление галлюцинаций, но не более.")
