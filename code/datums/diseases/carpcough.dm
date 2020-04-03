/datum/disease/carpcough
	name = "Carpcough"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Carpotoxin"
	cures = list("carpotoxin")
	agent = "Fishy Infection"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "If left untreated subject will regurgitate aggressive space carp. And to make matters worse, the cure is almost as bad as the disease.."
	severity = BIOHAZARD	//it is significantly harder to cure than beesease and spawns more dangerous mobs

/datum/disease/carpcough/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='notice'>You taste something fishy.</span>")
		if(3)
			if(prob(3))
				affected_mob.emote("cough")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your stomach suddenly hurts a lot. It feels like there's something sharp in there.</span>")
				if(prob(20))
					affected_mob.adjustBruteLoss(2)
		if(4)
			if(prob(10))
				affected_mob.visible_message("<span class='danger'>[affected_mob] clutches his stomach.</span>", \
												"<span class='userdanger'>Your stomach hurts!</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You feel something moving in your throat.</span>")
			if(prob(1))
				affected_mob.emote("cough")
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up an angry space carp!</span>", \
													"<span class='userdanger'>You cough up an angry space carp!</span>")
				new /mob/living/simple_animal/hostile/carp(affected_mob.loc)
	return

/datum/disease/carpcough/fake
	name = "Localized Carpcough"
	desc = "If left untreated subject will regurgitate aggressive space carp. And to make matters worse, the cure is almost as bad as the disease. Thankfully, this strain is not transmissable."
	spread_flags = NON_CONTAGIOUS
	spread_text = "Non-Contagious"
	severity = DANGEROUS
