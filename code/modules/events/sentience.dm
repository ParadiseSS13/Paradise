/datum/event/sentience

/datum/event/sentience/start()
	processing = FALSE //so it won't fire again in next tick

	var/ghostmsg = "Do you want to awaken as a sentient being?"
	var/list/candidates = pollCandidates(ghostmsg, ROLE_SENTIENT, 1)
	var/list/potential = list()
	var/sentience_type = SENTIENCE_ORGANIC

	for(var/mob/living/simple_animal/L in GLOB.living_mob_list)
		var/turf/T = get_turf(L)
		if (T.z != 1)
			continue
		if(!(L in GLOB.player_list) && !L.mind && (L.sentience_type == sentience_type))
			potential += L

	if(!candidates.len || !potential.len) //if there are no players or simple animals to choose from, then end
		return FALSE

	var/mob/living/simple_animal/SA = pick(potential)
	var/mob/SG = pick(candidates)

	var/sentience_report = "<font size=3><b>[command_name()] Medium-Priority Update</b></font>"

	var/data = pick("scans from our long-range sensors", "our sophisticated probabilistic models", "our omnipotence", "the communications traffic on your station", "energy emissions we detected", "\[REDACTED\]", "Steve")
	var/pets = pick("animals", "pets", "simple animals", "lesser lifeforms", "\[REDACTED\]")
	var/strength = pick("human", "skrell", "vox", "grey", "diona", "IPC", "tajaran", "vulpakanin", "kidan", "plasmaman", "drask",
					 "slime", "monkey", "moderate", "lizard", "security", "command", "clown", "mime", "low", "very low", "greytide", "catgirl", "\[REDACTED\]")

	sentience_report += "<br><br>Based on [data], we believe that one of the station's [pets] has developed [strength] level intelligence, and the ability to communicate."



	SA.key = SG.key
	SA.universal_speak = 1
	SA.sentience_act()
	SA.can_collar = 1
	SA.maxHealth = max(SA.maxHealth, 200)
	SA.health = SA.maxHealth
	SA.del_on_death = FALSE
	greet_sentient(SA)
	print_command_report(sentience_report, "[command_name()] Update")
	processing = TRUE // Let it naturally end, if it runs successfully

/datum/event/sentience/proc/greet_sentient(var/mob/living/carbon/human/M)
	to_chat(M, "<span class='userdanger'>Hello world!</span>")
	to_chat(M, "<span class='warning'>Due to freak radiation, you have gained \
	 						human level intelligence and the ability to speak and understand \
							human language!</span>")
