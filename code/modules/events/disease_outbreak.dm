/datum/event/disease_outbreak
	announceWhen = 15

	var/virus_type

/datum/event/disease_outbreak/setup()
	announceWhen = rand(15, 30)

/datum/event/disease_outbreak/announce()
	event_announcement.Announce("Confirmed outbreak of level 7 major viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", new_sound = 'sound/AI/outbreak7.ogg')

/datum/event/disease_outbreak/start()
	if(!virus_type)
		virus_type = pick(/datum/disease/advance/flu, /datum/disease/advance/cold, /datum/disease/brainrot, /datum/disease/magnitis, /datum/disease/beesease, /datum/disease/anxiety, /datum/disease/fake_gbs, /datum/disease/fluspanish, /datum/disease/pierrot_throat, /datum/disease/lycan)

	for(var/mob/living/carbon/human/H in shuffle(GLOB.living_mob_list))
		if(issmall(H)) //don't infect monkies; that's a waste
			continue
		if(!H.client)
			continue
		if(VIRUSIMMUNE in H.dna.species.species_traits) //don't let virus immune things get diseases they're not supposed to get.
			continue
		var/turf/T = get_turf(H)
		if(!T)
			continue
		if(!is_station_level(T.z))
			continue
		var/foundAlready = FALSE	// don't infect someone that already has the virus
		for(var/thing in H.viruses)
			foundAlready = TRUE
			break
		if(H.stat == DEAD || foundAlready)
			continue

		var/datum/disease/D
		D = new virus_type()
		D.carrier = TRUE
		H.AddDisease(D)
		break
