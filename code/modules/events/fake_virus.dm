/datum/event/fake_virus/start()
	var/list/fake_virus_victims = list()
	for(var/mob/living/carbon/human/victim in shuffle(GLOB.player_list))
		if(HAS_TRAIT(victim, TRAIT_VIRUSIMMUNE))
			continue
		if(victim.stat == DEAD || victim.InCritical() || victim.mind?.assigned_role == victim.mind?.special_role || victim.mind?.offstation_role)
			continue
		fake_virus_victims += victim

	//first we do hard status effect victims
	var/defacto_min = min(3, length(fake_virus_victims))
	if(defacto_min) // event will hit 1-3 people by default, but will do 1-2 or just 1 if only those many candidates are available
		for(var/i in 1 to rand(1, defacto_min))
			var/mob/living/carbon/human/hypochondriac = pick(fake_virus_victims)
			hypochondriac.apply_status_effect(STATUS_EFFECT_FAKE_VIRUS)
			hypochondriac.create_log(MISC_LOG, "[hypochondriac] has contracted a fake virus.")
			fake_virus_victims -= hypochondriac
			notify_ghosts("[hypochondriac] now has a fake virus!")
	//then we do light one-message victims who simply cough or whatever once (have to repeat the process since the last operation modified our candidates list)
	defacto_min = min(5, length(fake_virus_victims))
	if(defacto_min)
		for(var/i in 1 to rand(1, defacto_min))
			var/mob/living/carbon/human/onecoughman = pick(fake_virus_victims)
			if(prob(25)) //1/4 odds to get a spooky message instead of coughing out loud
				addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(to_chat), onecoughman, "<span class='warning'>[pick("Your head hurts.", "Your head pounds.")]</span>"), rand(30, 150))
			else
				addtimer(CALLBACK(onecoughman, TYPE_PROC_REF(/mob/, emote), pick("cough", "sniff", "sneeze")), rand(30, 150)) //deliver the message with a slightly randomized time interval so there arent multiple people coughing at the exact same time
			fake_virus_victims -= onecoughman
