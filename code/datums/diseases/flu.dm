/datum/disease/flu
	name = "The Flu"
	max_stages = 3
	spread_text = "Airborne"
	cure_text = "Spaceacillin"
	cures = list("spaceacillin")
	cure_chance = 10
	agent = "H13N1 flu virion"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	permeability_mod = 0.75
	desc = "If left untreated the subject will feel quite unwell."
	severity = MEDIUM

/datum/disease/flu/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(2)
			if(IS_HORIZONTAL(affected_mob) && MAYBE)
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
			if(MAYBE)
				affected_mob.emote("sneeze")
			if(MAYBE)
				affected_mob.emote("cough")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>Your muscles ache.</span>")
				if(MAYBE)
					affected_mob.take_organ_damage(1)
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
				if(MAYBE)
					affected_mob.adjustToxLoss(1)

		if(3)
			if(IS_HORIZONTAL(affected_mob) && MAYBE)
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
			if(MAYBE)
				affected_mob.emote("sneeze")
			if(MAYBE)
				affected_mob.emote("cough")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>Your muscles ache.</span>")
				if(MAYBE)
					affected_mob.take_organ_damage(1)
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
				if(MAYBE)
					affected_mob.adjustToxLoss(1)
	return
