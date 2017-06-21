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
	var/objtype = pick(subtypesof(/datum/objective/sentFluff/))
	var/datum/objective/sentFluff/O = new objtype()
	SA.mind.objectives += O
	to_chat(SA, "<B>Purpose in life</B>: [O.explanation_text]")

/datum/event/sentience/proc/greet_sentient(var/mob/living/carbon/human/M)
	to_chat(M, "<span class='userdanger'>Hello world!</span>")
	to_chat(M, "<span class='warning'>Due to freak radiation, you have gained \
	 						human level intelligence and the ability to speak and understand \
							human language!</span>")
/datum/objective/sentFluff
	completed = 1

/datum/objective/sentFluff/steal
	explanation_text = "You have the urge to steal as many "

/datum/objective/sentFluff/steal/New()
	var/things = pick(list("lights","fruits","shoes","bars of soap", "hats", "pants", "organs"))
	explanation_text += " [things] as you can!"

/datum/objective/sentFluff/fear
	explanation_text = "In your new found sentience you have learnd"

/datum/objective/sentFluff/fear/New()
	var/list/jobs = job_master.occupations.Copy()
	for(var/datum/job/J in jobs)
		if(J.current_positions < 1)
			jobs -= J
	if(jobs.len > 0)
		var/datum/job/target = pick(jobs)
		explanation_text += " that [target.title] are evil, avoid these scary things!"
	else
		explanation_text += " people are evil, avoid these scary things!"

/datum/objective/sentFluff/toy
	explanation_text = "You MUST find your special "

/datum/objective/sentFluff/toy/New()
	var/toy = pick(list("shoe","rubber duck","bike horn","bar of soap", "hat", "par of pants"))
	explanation_text += " [toy] and not lose it! EVER!"
