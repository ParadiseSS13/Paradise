/datum/disease/anxiety
	name = "Severe Anxiety"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Ethanol"
	cures = list("ethanol")
	agent = "Excess Lepidopticides"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "If left untreated subject will regurgitate butterflies."
	severity = MEDIUM

/datum/disease/anxiety/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>You feel anxious.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>Your stomach flutters.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>You feel panicky.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You're overtaken with panic!</span>")
				affected_mob.AdjustConfused(rand(2,3))
		if(4)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel butterflies in your stomach.</span>")
			if(prob(5))
				affected_mob.visible_message("<span class='danger'>[affected_mob] stumbles around in a panic.</span>", \
												"<span class='userdanger'>You have a panic attack!</span>")
				affected_mob.AdjustConfused(rand(6,8))
				affected_mob.AdjustJitter(rand(6,8))
			if(prob(2))
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up butterflies!</span>", \
													"<span class='userdanger'>You cough up butterflies!</span>")
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
	return
