/datum/event/disease_outbreak
	announceWhen = 15
	var/datum/disease/D

/datum/event/disease_outbreak/setup()
	announceWhen = rand(15, 30)
	if(prob(25))
		var/virus_type = pick(/datum/disease/advance/flu, /datum/disease/advance/cold, /datum/disease/brainrot, /datum/disease/magnitis, /datum/disease/beesease, /datum/disease/anxiety, /datum/disease/fake_gbs, /datum/disease/fluspanish, /datum/disease/pierrot_throat, /datum/disease/lycan)
		D = new virus_type()
	else
		var/datum/disease/advance/A = new /datum/disease/advance
		// Try generating a random spreading virus. If that fails just use the last generated one
		for(var/i = 0; i < 100; i++)
			var/symptom_amount = rand(2, 6)
			QDEL_LIST(A.symptoms)
			A.symptoms = A.GenerateSymptoms(1, 6, symptom_amount)
			A.Refresh(FALSE, FALSE) // Don't actually archive the miscreants
			if(VirusCanSpread(A))
				break
		A.name = capitalize(pick(GLOB.adjectives)) + " " + capitalize(pick(GLOB.nouns + GLOB.verbs)) // random silly name
		A.Refresh() // Actually archive it with it's name
		D = A

	if(istype(D, /datum/disease/advance))
		var/datum/disease/advance/A = D
		A.event_spawned = TRUE // Will make random advanced viruses and default ones like the flu or such also able to spread
	D.carrier = TRUE

/datum/event/disease_outbreak/proc/VirusCanSpread(datum/disease/advance/A)
	if(A.spread_flags == BLOOD)
		return locate(/datum/symptom/sneeze) in A.symptoms // Should atleast have sneezing then to be considered spreading
	return TRUE

/datum/event/disease_outbreak/announce()
	GLOB.event_announcement.Announce("Confirmed outbreak of level 7 major viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", new_sound = 'sound/AI/outbreak7.ogg')

/datum/event/disease_outbreak/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mob_list))
		if(!H.client)
			continue
		if(issmall(H)) //don't infect monkies; that's a waste
			continue
		var/turf/T = get_turf(H)
		if(!T)
			continue
		if(!is_station_level(T.z))
			continue

		if(!H.ForceContractDisease(D))
			continue
		break
