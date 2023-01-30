/datum/disease/cold9
	name = "The Cold"
	max_stages = 3
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Common Cold Anti-bodies & Spaceacillin"
	cures = list("spaceacillin")
	agent = "ICE9-rhinovirus"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "If left untreated the subject will slow, as if partly frozen."
	severity = MEDIUM

/datum/disease/cold9/stage_act()
	..()
	switch(stage)
		if(2)
			affected_mob.bodytemperature -= 10
			if(prob(1) && prob(10))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your throat feels sore.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You feel stiff.</span>")
		if(3)
			affected_mob.bodytemperature -= 20
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your throat feels sore.</span>")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel stiff.</span>")
