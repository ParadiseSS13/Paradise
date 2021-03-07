/datum/event/disease_outbreak
	announceWhen = 15
	/// The type of disease that patient zero will be infected with.
	var/datum/disease/D
	/// The initial target of the disease.
	var/mob/living/carbon/human/patient_zero

/datum/event/disease_outbreak/setup()
	announceWhen = rand(15, 30)
	if(prob(25))
		var/virus_type = pick(/datum/disease/advance/flu, /datum/disease/advance/cold, /datum/disease/brainrot, /datum/disease/magnitis, /datum/disease/beesease, /datum/disease/anxiety, /datum/disease/fake_gbs, /datum/disease/fluspanish, /datum/disease/pierrot_throat, /datum/disease/lycan)
		D = new virus_type()
	else
		var/datum/disease/advance/A = new /datum/disease/advance
		A.name = capitalize(pick(GLOB.adjectives)) + " " + capitalize(pick(GLOB.nouns + GLOB.verbs)) // random silly name
		A.GenerateSymptoms(1,9,6)
		A.AssignProperties(list("resistance" = rand(0,11), "stealth" = rand(0,2), "stage_rate" = rand(0,5), "transmittable" = rand(0,5), "severity" = rand(0,10)))
		D = A

	D.carrier = TRUE

/datum/event/disease_outbreak/announce()
	GLOB.event_announcement.Announce("Confirmed outbreak of level 7 major viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", new_sound = 'sound/AI/outbreak7.ogg')
	for(var/p in GLOB.dead_mob_list)
		var/mob/M = p
		to_chat(M, "<span class='deadsay'><b>[patient_zero]</b> has been infected with <b>[D.name]</b> ([ghost_follow_link(patient_zero, M)])</span>")

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
		patient_zero = H
		break
