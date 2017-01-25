/datum/disease/kuru
	name = "Space Kuru"
	max_stages = 4
	stage_prob = 5
	spread_text = "Non-Contagious"
	spread_flags = SPECIAL
	cure_text = "Incurable"
	agent = "Prions"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Uncontrollable laughing."
	severity = BIOHAZARD
	spread_flags = NON_CONTAGIOUS

/datum/disease/kuru/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(50))
				affected_mob.emote("laugh")
			if(prob(50))
				affected_mob.Jitter(25)
		if(2)
			if(prob(50))
				affected_mob.visible_message("<span class='danger'>[affected_mob] laughs uncontrollably!</span>")
				affected_mob.Stun(10)
				affected_mob.Weaken(10)
				affected_mob.Jitter(250)
				affected_mob.drop_l_hand()
				affected_mob.drop_r_hand()
		if(3)
			if(prob(25))
				to_chat(affected_mob, "<span class='danger'>You feel like you are about to drop dead!</span>")
				to_chat(affected_mob, "<span class='danger'>Your body convulses painfully!</span>")
				affected_mob.drop_l_hand()
				affected_mob.drop_r_hand()
				affected_mob.adjustBruteLoss(5)
				affected_mob.adjustOxyLoss(5)
				affected_mob.Stun(10)
				affected_mob.Weaken(10)
				affected_mob.Jitter(250)
				affected_mob.visible_message("<span class='danger'>[affected_mob] laughs uncontrollably!</span>")
		if(4)
			if(prob(25))
				to_chat(affected_mob, "<span class='danger'>You feel like you are going to die!</span>")
				affected_mob.adjustOxyLoss(75)
				affected_mob.adjustBruteLoss(75)
				affected_mob.drop_l_hand()
				affected_mob.drop_r_hand()
				affected_mob.Stun(10)
				affected_mob.Weaken(10)
				affected_mob.visible_message("<span class='danger'>[affected_mob] laughs uncontrollably!</span>")