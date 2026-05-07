/datum/disease/flock
	form = "Disease"
	name = "Flock Conversion"
	max_stages = 5
	stage_prob = 5
	spread_text = "Non-contagious"
	spread_flags = SPREAD_NON_CONTAGIOUS
	cure_text = "Mutadone"
	cures = list("mutadone")
	agent = "Gnesis Toxin"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Slow conversion into a flockbit."
	severity = VIRUS_BIOHAZARD
	disease_flags = VIRUS_CAN_CARRY
	bypasses_immunity = TRUE
	virus_heal_resistant = TRUE

/datum/disease/flock/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(1)
			if(prob(50))
				affected_mob.Jitter(50 SECONDS)
		if(2)
			if(prob(50))
				affected_mob.Weaken(20 SECONDS)
		if(3)
			if(prob(25))
				to_chat(affected_mob, SPAN_DANGER("You feel like you hear a distant chirping..."))
				to_chat(affected_mob, SPAN_DANGER("Your body convulses painfully!"))
				affected_mob.adjustBruteLoss(5)
				affected_mob.adjustOxyLoss(5)
				affected_mob.Weaken(20 SECONDS)
		if(4)
			if(prob(25))
				to_chat(affected_mob, SPAN_DANGER("You feel like you are going to die!"))
				affected_mob.adjustOxyLoss(75)
				affected_mob.Weaken(20 SECONDS)
		if(5)
			new /mob/living/basic/flock/bit(get_turf(affected_mob))
			affected_mob.gib()
