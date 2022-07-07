/datum/disease/beesease
	name = "Beesease"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Sugar"
	cures = list("sugar")
	agent = "Apidae Infection"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "If left untreated subject will regurgitate bees."
	severity = DANGEROUS

/datum/disease/beesease/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm // no it doesn't, that's horrifyingly snowflakey
			if(prob(2))
				to_chat(affected_mob, span_notice("You taste honey in your mouth."))
		if(3)
			if(prob(10))
				to_chat(affected_mob, span_notice("Your stomach rumbles."))
			if(prob(2))
				to_chat(affected_mob, span_danger("Your stomach stings painfully."))
				if(prob(20))
					affected_mob.adjustToxLoss(2)
		if(4)
			if(prob(10))
				affected_mob.visible_message(span_danger("[affected_mob] buzzes."), \
												span_userdanger("Your stomach buzzes violently!"))
			if(prob(5))
				to_chat(affected_mob, span_danger("You feel something moving in your throat."))
			if(prob(1))
				affected_mob.visible_message(span_danger("[affected_mob] coughs up a swarm of bees!"), \
													span_userdanger("You cough up a swarm of bees!"))
				new /mob/living/simple_animal/hostile/poison/bees(affected_mob.loc)
		//if(5)
		//Plus if you die, you explode into bees
	return
