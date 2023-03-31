/datum/disease/food_poisoning
	name = "Food Poisoning"
	max_stages = 3
	stage_prob = 5
	spread_text = "Non-contagious"
	spread_flags = NON_CONTAGIOUS
	cure_text = "Sleep"
	agent = "Salmonella"
	cures = list("chicken_soup")
	cure_chance = 10
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Nausea, sickness, and vomitting."
	severity = MINOR
	disease_flags = CURABLE
	virus_heal_resistant = TRUE

/datum/disease/food_poisoning/stage_act()
	if(!..())
		return FALSE
	if(affected_mob.IsSleeping() && MAYBE)
		to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
		cure()
		return
	switch(stage)
		if(1)
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>Your stomach feels weird.</span>")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>You feel queasy.</span>")
		if(2)
			if(affected_mob.IsSleeping() && MAYBE)
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(MAYBE && MAYBE)
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(MAYBE)
				affected_mob.emote("groan")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>Your stomach aches.</span>")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>You feel nauseous.</span>")
		if(3)
			if(affected_mob.IsSleeping() && MAYBE)
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(MAYBE && MAYBE)
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(MAYBE)
				affected_mob.emote("moan")
			if(MAYBE)
				affected_mob.emote("groan")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>You feel sick.</span>")
			if(MAYBE)
				if(affected_mob.nutrition > 10)
					affected_mob.visible_message("<span class='danger'>[affected_mob] vomits on the floor profusely!</span>")
					affected_mob.fakevomit(no_text = 1)
					affected_mob.adjust_nutrition(-rand(3,5))
				else
					to_chat(affected_mob, "<span class='danger'>Your stomach lurches painfully!</span>")
					affected_mob.visible_message("<span class='danger'>[affected_mob] gags and retches!</span>")
					affected_mob.Stun(rand(4 SECONDS, 8 SECONDS))
					affected_mob.Weaken(rand(4 SECONDS, 8 SECONDS))
