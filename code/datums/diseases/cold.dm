/datum/disease/cold
	name = "The Cold"
	max_stages = 3
	spread_text = "Airborne"
	spread_flags = AIRBORNE
	cure_text = "Rest & Spaceacillin"
	cures = list("spaceacillin")
	agent = "XY-rhinovirus"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	permeability_mod = 0.5
	desc = "If left untreated the subject will contract the flu."
	severity = MINOR

/datum/disease/cold/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(2)
/*
			if(affected_mob.sleeping && MAYBE)  //removed until sleeping is fixed
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
*/
			if(IS_HORIZONTAL(affected_mob) && MAYBE)  //changed FROM MAYBE until sleeping is fixed
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(MAYBE && MAYBE)
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(MAYBE)
				affected_mob.emote("sneeze")
			if(MAYBE)
				affected_mob.emote("cough")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>Your throat feels sore.</span>")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>Mucous runs down the back of your throat.</span>")
		if(3)
/*
			if(affected_mob.sleeping && MAYBE)  //removed until sleeping is fixed
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
*/
			if(IS_HORIZONTAL(affected_mob) && MAYBE)  //changed FROM MAYBE until sleeping is fixed
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(MAYBE && MAYBE)
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(MAYBE)
				affected_mob.emote("sneeze")
			if(MAYBE)
				affected_mob.emote("cough")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>Your throat feels sore.</span>")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>Mucous runs down the back of your throat.</span>")
			if(MAYBE && MAYBE)
				if(!affected_mob.resistances.Find(/datum/disease/flu))
					var/datum/disease/Flu = new /datum/disease/flu(0)
					affected_mob.ContractDisease(Flu)
					cure()
