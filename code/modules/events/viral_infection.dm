/datum/event/viral_infection
	severity = 1

/datum/event/viral_infection/setup()
	announceWhen = rand(0, 3000)
	endWhen = announceWhen + 1
	severity = rand(1, 3)

/datum/event/viral_infection/announce()
	command_announcement.Announce("Confirmed outbreak of level five viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", new_sound = 'sound/AI/outbreak5.ogg')

/datum/event/viral_infection/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)	return
	candidates = shuffle(candidates)//Incorporating Donkie's list shuffle

	var/datum/disease2/disease/D = new /datum/disease2/disease
	D.makerandom()
	D.infectionchance = 1
	message_admins("Viral Infection: releasing strain [D.uniqueID]")

	while(severity > 0 && candidates.len)
		var/mob/living/carbon/human/H = candidates[1]
		H.virus2["[D.uniqueID]"] = D
		candidates.Remove(candidates[1])
		severity--
