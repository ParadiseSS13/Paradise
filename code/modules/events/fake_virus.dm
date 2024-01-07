/datum/event/fake_virus/start()
	var/list/valid_targets = list()
	for(var/mob/living/carbon/human/victim in shuffle(GLOB.player_list))
		if(HAS_TRAIT(victim, TRAIT_VIRUSIMMUNE))
			continue
		if(victim.stat == DEAD || victim.InCritical() || victim.mind?.assigned_role == victim.mind?.special_role || victim.mind?.offstation_role)
			continue
		valid_targets += victim

	if(!length(valid_targets))
		return

	// First we do hard status effect victims
	var/fake_virus_victims = max(1, 0.05 * length(valid_targets)) // Event will affect 5% of valid crewmembers
	for(var/i in 1 to rand(1, fake_virus_victims))
		var/mob/living/carbon/human/hypochondriac = pick(valid_targets)
		hypochondriac.apply_status_effect(STATUS_EFFECT_FAKE_VIRUS)
		hypochondriac.create_log(MISC_LOG, "[hypochondriac] has contracted a fake virus.")
		valid_targets -= hypochondriac
		notify_ghosts("[hypochondriac] now has a fake virus!", flashwindow = FALSE)

	if(!length(valid_targets)) // List has been modified, lets check again
		return

	// Then we do light one-message victims who simply cough or whatever once (have to repeat the process since the last operation modified our candidates list)
	fake_virus_victims = max(1, 0.1 * length(valid_targets)) // 10% of the victims remaining
	for(var/i in 1 to rand(1, fake_virus_victims))
		var/mob/living/carbon/human/one_cough_man = pick(valid_targets)
		if(prob(25)) // 1/4 odds to get a spooky message instead of coughing out loud
			addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(to_chat), one_cough_man, "<span class='warning'>[pick("Your head hurts.", "Your head pounds.")]</span>"), rand(1, 120) SECONDS)
		else
			addtimer(CALLBACK(one_cough_man, TYPE_PROC_REF(/mob/, emote), pick("cough", "sniff", "sneeze", "yawn")), rand(1, 120) SECONDS) // Deliver the message with a randomized time interval so there arent multiple people coughing at the same time
		valid_targets -= one_cough_man
