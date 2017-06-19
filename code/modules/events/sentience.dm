/datum/event/sentience

/datum/event/sentience/start()
	var/ghostmsg = "Do you want to awaken as a sentient being?"
	var/list/candidates = pollCandidates(ghostmsg, ROLE_SENTIENT, 1)
	var/list/potential = list()
	var/sentience_type = SENTIENCE_ORGANIC

	for(var/mob/living/simple_animal/L in living_mob_list)
		var/turf/T = get_turf(L)
		if (T.z != 1)
			continue
		if(!(L in player_list) && !L.mind && (L.sentience_type == sentience_type))
			potential += L

	var/mob/living/simple_animal/SA = pick(potential)
	var/mob/SG = pick(candidates)

	if(!SA || !SG) //if you can't find either a simple animal or a player, end
		return FALSE

	SA.key = SG.key
	SA.universal_speak = 1
	SA.sentience_act()
	SA.maxHealth = max(SA.maxHealth, 200)
	SA.health = SA.maxHealth
	SA.del_on_death = FALSE
	greet_sentient(SA)

/datum/event/sentience/proc/greet_sentient(var/mob/living/carbon/human/M)
	to_chat(M, "<span class='userdanger'>Hello world!</span>")
	to_chat(M, "<span class='warning'>Due to freak radiation, you have gained \
	 						human level intelligence and the ability to speak and understand \
							human language!</span>")
