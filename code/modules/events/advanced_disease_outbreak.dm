/datum/event/disease_outbreak/advanced/announce()
	if(prob(25))
		event_announcement.Announce("Confirmed outbreak of level 7 major viral biohazard aboard [station_name()]. Our intel suggests that the Syndicate have released an experimental virus onboard the [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", new_sound = 'sound/AI/outbreak7.ogg')
	else
		..()

//No need to pick one
/datum/event/disease_outbreak/advanced/PickVirus()
	return

/datum/event/disease_outbreak/advanced/Infect(mob/living/carbon/human/H)
	var/datum/disease/advance/A = GetVirus()
	A.carrier = TRUE
	H.AddDisease(A)

/datum/event/disease_outbreak/advanced/proc/GetVirus()
	var/success = FALSE
	var/datum/disease/advance/A
	while(!success)
		A = new
		for(var/i = rand(2, 6), i > 0, i--)
			A.Evolve(1, 6)
		success = CheckVirus(A)
	A.AssignName(GenerateName())
	A.eventSpawned = TRUE
	return A

/datum/event/disease_outbreak/advanced/proc/CheckVirus(datum/disease/advance/A)
	if(A.spread_flags == BLOOD)
		var/spread = FALSE
		for(var/datum/symptom/S in A.symptoms)
			if(istype(S, /datum/symptom/sneeze))
				spread = TRUE
				break
		if(!spread)
			return FALSE //Want it to spread atleast
	return TRUE

/datum/event/disease_outbreak/advanced/proc/GenerateName()
	var/base
	var/end
	if(prob(50))
		base = pick("Accessio ", "Spasmus ", "Marasmus ", "Privadrops ", "Colica ", "Exhaustio ")
		end = pick("Petechialis", "Pulmonum", "Vulnus", "Cavum", "Putrida", "Senilis")
	else 
		base = pick("X", "U", "D", "Q", "ADV", "UNKW")
		end = pick("457", "42", "6583", "001", "043", "948")
	return base + end

