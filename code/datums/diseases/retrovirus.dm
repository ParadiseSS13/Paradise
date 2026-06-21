/datum/disease/dna_retrovirus
	name = "Retrovirus"
	max_stages = 4
	spread_text = "Contact"
	spread_flags = SPREAD_CONTACT_GENERAL
	cure_text = "Rest or an injection of mutadone"
	cure_chance = 6
	agent = ""
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A DNA-altering retrovirus that scrambles the structural and unique enzymes of a host constantly."
	severity = VIRUS_BIOHAZARD
	permeability_mod = 0.4
	stage_prob = 2
	var/SE
	var/UI
	var/restcure = 0


/datum/disease/dna_retrovirus/New()
	..()
	agent = "Virus class [pick("A","B","C","D","E","F")][pick("A","B","C","D","E","F")]-[rand(50,300)]"
	if(prob(40))
		cures = list("mutadone")
	else
		restcure = 1


/datum/disease/dna_retrovirus/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(1)
			if(restcure)
				if(IS_HORIZONTAL(affected_mob) && prob(30))
					to_chat(affected_mob, SPAN_NOTICE("You feel better."))
					cure()
					return
			if(prob(8))
				to_chat(affected_mob, SPAN_DANGER("Your head hurts."))
			if(prob(9))
				to_chat(affected_mob, "You feel a tingling sensation in your chest.")
			if(prob(9))
				to_chat(affected_mob, SPAN_DANGER("You feel angry."))
		if(2)
			if(restcure)
				if(IS_HORIZONTAL(affected_mob) && prob(20))
					to_chat(affected_mob, SPAN_NOTICE("You feel better."))
					cure()
					return
			if(prob(8))
				to_chat(affected_mob, SPAN_DANGER("Your skin feels loose."))
			if(prob(10))
				to_chat(affected_mob, "You feel very strange.")
			if(prob(4))
				to_chat(affected_mob, SPAN_DANGER("You feel a stabbing pain in your head!"))
				affected_mob.Paralyse(4 SECONDS)
			if(prob(4))
				to_chat(affected_mob, SPAN_DANGER("Your stomach churns."))
		if(3)
			if(restcure)
				if(IS_HORIZONTAL(affected_mob) && prob(20))
					to_chat(affected_mob, SPAN_NOTICE("You feel better."))
					cure()
					return
			if(prob(10))
				to_chat(affected_mob, SPAN_DANGER("Your entire body vibrates."))

			if(prob(35))
				if(prob(50))
					scramble(1, affected_mob, rand(15, 45))
				else
					scramble(0, affected_mob, rand(15, 45))

		if(4)
			if(restcure)
				if(IS_HORIZONTAL(affected_mob) && prob(5))
					to_chat(affected_mob, SPAN_NOTICE("You feel better."))
					cure()
					return
			if(prob(60))
				if(prob(50))
					scramble(1, affected_mob, rand(15, 45))
				else
					scramble(0, affected_mob, rand(15, 45))
