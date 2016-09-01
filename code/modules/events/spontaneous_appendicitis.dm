/datum/event/spontaneous_appendicitis/start()
	for(var/mob/living/carbon/human/H in shuffle(living_mob_list))
		if(issmall(H)) //don't infect monkies; that's a waste.
			continue
		if(!H.client)
			continue
		if(H.species.virus_immune) //don't count things that are virus immune; they'll just get picked and auto-cure
			continue
		if(!H.get_int_organ(/obj/item/organ/internal/appendix))
			continue
		var/foundAlready = 0	//don't infect someone that already has the virus
		for(var/datum/disease/D in H.viruses)
			foundAlready = 1
		if(H.stat == DEAD || foundAlready)
			continue

		var/datum/disease/D = new /datum/disease/appendicitis
		H.ForceContractDisease(D)
		break
