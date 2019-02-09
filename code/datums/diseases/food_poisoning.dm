/datum/disease/food_poisoning
	name = "Food Poisoning"
	max_stages = 3
	stage_prob = 5
	spread_text = "Non-Contagious"
	spread_flags = SPECIAL
	cure_text = "Sleep"
	agent = "Salmonella"
	cures = list("chicken_soup")
	cure_chance = 10
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Nausea, sickness, and vomitting."
	severity = MINOR
	disease_flags = CURABLE
	spread_flags = NON_CONTAGIOUS
	virus_heal_resistant = TRUE
	var/remissive = 0

/datum/disease/food_poisoning/stage_act()
	if(!remissive)
		..()
	if(affected_mob.sleeping && prob(33))
		to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
		remissive = 1
	if(remissive)
		if(prob(stage_prob))
			stage--
			if(stage == 0)
				cure()
				return
	switch(stage)
		if(1)
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Your stomach feels weird.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You feel queasy.</span>")
		if(2)
			if(affected_mob.sleeping && prob(40))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(prob(1) && prob(10))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(prob(10))
				affected_mob.emote("groan")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Your stomach aches.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You feel nauseous.</span>")
		if(3)
			if(affected_mob.sleeping && prob(25))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(prob(1) && prob(10))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(prob(10))
				affected_mob.emote("moan")
			if(prob(10))
				affected_mob.emote("groan")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>You feel sick.</span>")
			if(prob(5))
				if(affected_mob.nutrition > 10)
					affected_mob.visible_message("<span class='danger'>[affected_mob] vomits on the floor profusely!</span>")
					affected_mob.fakevomit(no_text = 1)
					affected_mob.nutrition -= rand(3,5)
				else
					to_chat(affected_mob, "<span class='danger'>Your stomach lurches painfully!</span>")
					affected_mob.visible_message("<span class='danger'>[affected_mob] gags and retches!</span>")
					affected_mob.Stun(rand(2,4))
					affected_mob.Weaken(rand(2,4))