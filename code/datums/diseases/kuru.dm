/datum/disease/kuru
	form = "Disease"
	name = "Space Kuru"
	max_stages = 4
	stage_prob = 5
	spread_text = "Non-contagious"
	spread_flags = SPREAD_NON_CONTAGIOUS
	cure_text = "Incurable"
	agent = "Prions"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Uncontrollable laughing."
	severity = VIRUS_BIOHAZARD
	disease_flags = VIRUS_CAN_CARRY
	bypasses_immunity = TRUE // Kuru is a prion disorder, not a virus
	virus_heal_resistant = TRUE

/datum/disease/kuru/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(1)
			if(prob(50))
				affected_mob.emote("laugh")
			if(prob(50))
				affected_mob.Jitter(50 SECONDS)
		if(2)
			if(prob(50))
				affected_mob.visible_message("<span class='danger'>[affected_mob] laughs uncontrollably!</span>")
				affected_mob.Weaken(20 SECONDS)
				affected_mob.Jitter(500 SECONDS)
		if(3)
			if(prob(25))
				to_chat(affected_mob, "<span class='danger'>You feel like you are about to drop dead!</span>")
				to_chat(affected_mob, "<span class='danger'>Your body convulses painfully!</span>")
				affected_mob.adjustBruteLoss(5)
				affected_mob.adjustOxyLoss(5)
				affected_mob.Weaken(20 SECONDS)
				affected_mob.Jitter(500 SECONDS)
				affected_mob.visible_message("<span class='danger'>[affected_mob] laughs uncontrollably!</span>")
		if(4)
			if(prob(25))
				to_chat(affected_mob, "<span class='danger'>You feel like you are going to die!</span>")
				affected_mob.adjustOxyLoss(75)
				affected_mob.adjustBruteLoss(75)
				affected_mob.Weaken(20 SECONDS)
				affected_mob.visible_message("<span class='danger'>[affected_mob] laughs uncontrollably!</span>")
