/datum/disease/beesease
	name = "Beesease"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = SPREAD_CONTACT_GENERAL
	cure_text = "Sugar"
	cures = list("sugar")
	agent = "Apidae Infection"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "If left untreated subject will regurgitate bees."
	severity = VIRUS_BIOHAZARD

/datum/disease/beesease/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, SPAN_NOTICE("You taste honey in your mouth."))
		if(3)
			if(prob(10))
				to_chat(affected_mob, SPAN_NOTICE("Your stomach rumbles."))
			if(prob(2))
				to_chat(affected_mob, SPAN_DANGER("Your stomach stings painfully."))
				if(prob(20))
					affected_mob.adjustToxLoss(2)
		if(4)
			if(prob(10))
				affected_mob.visible_message(SPAN_DANGER("[affected_mob] buzzes."), \
												SPAN_USERDANGER("Your stomach buzzes violently!"))
			if(prob(5))
				to_chat(affected_mob, SPAN_DANGER("You feel something moving in your throat."))
			if(prob(1))
				affected_mob.visible_message(SPAN_DANGER("[affected_mob] coughs up a swarm of bees!"), \
													SPAN_USERDANGER("You cough up a swarm of bees!"))
				new /mob/living/basic/bee(affected_mob.loc)
	return
