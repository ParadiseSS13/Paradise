/datum/event/mass_hallucination/setup()
	announceWhen = rand(0, 20)

/datum/event/mass_hallucination/start()
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(H.stat == DEAD)
			continue
		var/turf/T = get_turf(H)
		if(!T || !is_station_level(T.z))
			continue
		var/armor = H.getarmor(type = "rad")
		if((RADIMMUNE in H.dna.species.species_traits) || armor >= 75) // Leave radiation-immune species/rad armored players completely unaffected
			continue
		H.AdjustHallucinate(rand(100 SECONDS, 200 SECONDS))
		H.last_hallucinator_log = "Mass hallucination event"

/datum/event/mass_hallucination/announce()
	if(prob(40))
		GLOB.event_announcement.Announce("Станция [station_name()] проходит через радиационное поле низкой интенсивности. Возможно появление галлюцинаций, но не более.")
