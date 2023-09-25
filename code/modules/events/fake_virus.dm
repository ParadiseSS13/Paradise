/datum/event/fake_virus/start()
	var/list/fake_virus_victims = list()
	for(var/mob/living/carbon/human/victim in shuffle(GLOB.player_list))
		if(HAS_TRAIT(victim, TRAIT_VIRUSIMMUNE))
			continue
		if(victim.stat == DEAD || victim.InCritical() || victim.mind?.assigned_role == victim.mind?.special_role || victim.mind?.offstation_role)
			continue
		fake_virus_victims += victim

	if(!length(fake_virus_victims))
		return

	// First we do hard status effect victims
	var/defacto_min = max(1, 0.05 * length(fake_virus_victims)) // Event will affect 5% of valid crewmembers
	for(var/i in 1 to rand(1, defacto_min))
		var/mob/living/carbon/human/hypochondriac = pick(fake_virus_victims)
		hypochondriac.apply_status_effect(STATUS_EFFECT_FAKE_VIRUS)
		hypochondriac.create_log(MISC_LOG, "[hypochondriac] has contracted a fake virus.")
		fake_virus_victims -= hypochondriac
		notify_ghosts("[hypochondriac] now has a fake virus!")

	if(!length(fake_virus_victims)) // List has been modified, lets check again
		return

	// Then we do light one-message victims who simply cough or whatever once (have to repeat the process since the last operation modified our candidates list)
	defacto_min = max(1, 0.1 * length(fake_virus_victims)) // 10% of the victims remaining
	for(var/i in 1 to rand(1, defacto_min))
		var/mob/living/carbon/human/onecoughman = pick(fake_virus_victims)
		if(prob(25)) // 1/4 odds to get a spooky message instead of coughing out loud
			addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(to_chat), onecoughman, "<span class='warning'>[pick("Your head hurts.", "Your head pounds.")]</span>"), rand(1, 120) SECONDS)
		else
			addtimer(CALLBACK(onecoughman, TYPE_PROC_REF(/mob/, emote), pick("cough", "sniff", "sneeze", "yawn")), rand(1, 120) SECONDS) // Deliver the message with a randomized time interval so there arent multiple people coughing at the same time
		fake_virus_victims -= onecoughman
