/datum/event/disease_outbreak
	announceWhen = 15
	var/datum/disease/advance/virus_type
	var/infect_number = 1	//how many people to infect

/datum/event/disease_outbreak/setup()
	announceWhen = rand(15, 30)

/datum/event/disease_outbreak/announce()
	GLOB.event_announcement.Announce("Confirmed outbreak of level 7 major viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", new_sound = 'sound/AI/outbreak7.ogg')

/datum/event/disease_outbreak/start()
	pick_disease()
	var/infected = 0
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

		var/datum/disease/advance/D
		D = virus_type
		D.carrier = TRUE
		H.AddDisease(D)
		infected += 1
		if(infected >= infect_number)//have we infected enough people?
			break

/datum/event/disease_outbreak/proc/pick_disease()
	if(prob(25))
		virus_type = pick(/datum/disease/advance/flu, /datum/disease/advance/cold, /datum/disease/brainrot, /datum/disease/magnitis, /datum/disease/beesease, /datum/disease/anxiety, /datum/disease/fake_gbs, /datum/disease/fluspanish, /datum/disease/pierrot_throat, /datum/disease/lycan)
	else
		virus_type = new /datum/disease/advance
		virus_type.name = capitalize(pick(GLOB.adjectives)) + " " + capitalize(pick(GLOB.nouns,GLOB.verbs)) // random silly name
		virus_type.GenerateSymptoms(1,9,6)
		virus_type.AssignProperties(list("resistance" = rand(0,11), "stealth" = rand(0,2), "stage_rate" = rand(0,5), "transmittable" = rand(0,5), "severity" = rand(0,10)))

/datum/event/disease_outbreak/severe
	infect_number = 3	//severe outbreaks have multiple initial hosts, so it's not so easy to stop.

/datum/event/disease_outbreak/severe/pick_disease()
	if(prob(50))
		virus_type = pick(/datum/disease/brainrot, /datum/disease/fluspanish, /datum/disease/carpcough, /datum/disease/tuberculosis)
	else
		virus_type = new /datum/disease/advance
		virus_type.name = capitalize(pick(GLOB.adjectives)) + " " + capitalize(pick(GLOB.nouns,GLOB.verbs)) // random silly name
		virus_type.GenerateSymptoms(3,9,6)
		virus_type.AssignProperties(list("resistance" = rand(5,11), "stealth" = rand(1,3), "stage_rate" = rand(1,5), "transmittable" = rand(3,5), "severity" = rand(4,10)))

/datum/event/disease_outbreak/announce()
	GLOB.event_announcement.Announce("Confirmed outbreak of level 5 major viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", new_sound = 'sound/AI/outbreak7.ogg')	//TODO get sound

