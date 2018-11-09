/datum/event/spontaneous_appendicitis/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.living_mob_list))
		if(issmall(H)) //don't infect monkies; that's a waste.
			continue
		if(!H.client)
			continue
		if(!H.get_int_organ(/obj/item/organ/internal/appendix))
			continue
		var/foundAlready = FALSE	//don't infect someone that already has appendicitis
		for(var/datum/disease/appendicitis/A in H.viruses)
			foundAlready = TRUE
			break
		if(H.stat == DEAD || foundAlready)
			continue

		var/datum/disease/D = new /datum/disease/appendicitis
		H.ForceContractDisease(D)
		break
