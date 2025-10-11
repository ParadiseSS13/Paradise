/datum/disease/cold
	name = "The Cold"
	max_stages = 3
	spread_text = "Airborne"
	cure_text = "Rest & Spaceacillin"
	cures = list("spaceacillin")
	agent = "XY-rhinovirus"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	permeability_mod = 0.5
	desc = "If left untreated the subject will contract the flu."
	severity = VIRUS_MINOR

/datum/disease/cold/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(2)
			if(affected_mob.stat == UNCONSCIOUS && prob(40))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(IS_HORIZONTAL(affected_mob) && prob(10))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(prob(1) && prob(5))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your throat feels sore.</span>")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Mucous runs down the back of your throat.</span>")
		if(3)
			if(affected_mob.stat == UNCONSCIOUS && prob(25))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(IS_HORIZONTAL(affected_mob) && prob(5))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(prob(1) && prob(1))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your throat feels sore.</span>")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Mucous runs down the back of your throat.</span>")
			if(prob(1) && prob(50))
				if(!affected_mob.resistances.Find(/datum/disease/flu))
					var/datum/disease/Flu = new /datum/disease/flu(0)
					affected_mob.ContractDisease(Flu)
					cure()
