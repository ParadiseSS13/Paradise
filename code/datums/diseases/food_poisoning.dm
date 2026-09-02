/datum/disease/food_poisoning
	name = "Food Poisoning"
	max_stages = 3
	stage_prob = 5
	spread_text = "Non-contagious"
	spread_flags = SPREAD_NON_CONTAGIOUS
	cure_text = "Sleep"
	agent = "Salmonella"
	cures = list("chicken_soup", "ginger_ale")
	cure_chance = 10
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Nausea, sickness, and vomitting."
	severity = VIRUS_MINOR
	disease_flags = VIRUS_CURABLE
	virus_heal_resistant = TRUE

/datum/disease/food_poisoning/stage_act()
	if(!..())
		return FALSE
	if(affected_mob.IsSleeping() && prob(33))
		to_chat(affected_mob, SPAN_NOTICE("You feel better."))
		cure()
		return
	switch(stage)
		if(1)
			if(prob(5))
				to_chat(affected_mob, SPAN_DANGER("Your stomach feels weird."))
			if(prob(5))
				to_chat(affected_mob, SPAN_DANGER("You feel queasy."))
		if(2)
			if(affected_mob.IsSleeping() && prob(40))
				to_chat(affected_mob, SPAN_NOTICE("You feel better."))
				cure()
				return
			if(prob(1) && prob(10))
				to_chat(affected_mob, SPAN_NOTICE("You feel better."))
				cure()
				return
			if(prob(10))
				affected_mob.emote("groan")
			if(prob(5))
				to_chat(affected_mob, SPAN_DANGER("Your stomach aches."))
			if(prob(5))
				to_chat(affected_mob, SPAN_DANGER("You feel nauseous."))
		if(3)
			if(affected_mob.IsSleeping() && prob(25))
				to_chat(affected_mob, SPAN_NOTICE("You feel better."))
				cure()
				return
			if(prob(1) && prob(10))
				to_chat(affected_mob, SPAN_NOTICE("You feel better."))
				cure()
				return
			if(prob(10))
				affected_mob.emote("moan")
			if(prob(10))
				affected_mob.emote("groan")
			if(prob(1))
				to_chat(affected_mob, SPAN_DANGER("Your stomach hurts."))
			if(prob(1))
				to_chat(affected_mob, SPAN_DANGER("You feel sick."))
			if(prob(5))
				if(affected_mob.nutrition > 10)
					affected_mob.visible_message(SPAN_DANGER("[affected_mob] vomits on the floor profusely!"))
					affected_mob.fakevomit(no_text = 1)
					affected_mob.adjust_nutrition(-rand(3,5))
				else
					to_chat(affected_mob, SPAN_DANGER("Your stomach lurches painfully!"))
					affected_mob.visible_message(SPAN_DANGER("[affected_mob] gags and retches!"))
					affected_mob.Stun(rand(4 SECONDS, 8 SECONDS))
					affected_mob.Weaken(rand(4 SECONDS, 8 SECONDS))
