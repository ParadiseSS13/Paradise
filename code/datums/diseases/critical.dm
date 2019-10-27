/datum/disease/critical

/datum/disease/critical/stage_act() //overriden to ensure unique behavior
	stage = min(stage, max_stages)

	if(prob(stage_prob))
		stage = min(stage + 1, max_stages)

	for(var/C_id in cures)
		if(affected_mob.reagents.has_reagent(C_id))
			if(prob(cure_chance))
				cure()
				return FALSE
	return TRUE

/datum/disease/critical/shock
	name = "Shock"
	form = "Medical Emergency"
	spread_text = "The patient is in shock"
	max_stages = 3
	spread_flags = SPECIAL
	cure_text = "Saline-Glucose Solution"
	cures = list("salglu_solution")
	cure_chance = 10
	viable_mobtypes = list(/mob/living/carbon/human)
	stage_prob = 6
	severity = DANGEROUS
	disease_flags = CURABLE
	bypasses_immunity = TRUE
	virus_heal_resistant = TRUE

/datum/disease/critical/shock/stage_act()
	if(..())
		if(affected_mob.health >= 25)
			to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
			cure()
			return
		switch(stage)
			if(1)
				if(prob(1) && prob(10))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("shiver", "pale", "moan"))
				if(prob(5))
					to_chat(affected_mob, "<span class='danger'>You feel weak!</span>")
			if(2)
				if(prob(1) && prob(10))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("shiver", "pale", "moan", "shudder", "tremble"))
				if(prob(5))
					to_chat(affected_mob, "<span class='danger'>You feel absolutely terrible!</span>")
				if(prob(5))
					affected_mob.emote("faint", "collapse", "groan")
			if(3)
				if(prob(1) && prob(10))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("shudder", "pale", "tremble", "groan", "bshake"))
				if(prob(5))
					to_chat(affected_mob, "<span class='danger'>You feel horrible!</span>")
				if(prob(5))
					affected_mob.emote(pick("faint", "collapse", "groan"))
				if(prob(7))
					to_chat(affected_mob, "<span class='danger'>You can't breathe!</span>")
					affected_mob.AdjustLoseBreath(1)
				if(prob(5))
					var/datum/disease/D = new /datum/disease/critical/heart_failure
					affected_mob.ForceContractDisease(D)

/datum/disease/critical/heart_failure
	name = "Cardiac Failure"
	form = "Medical Emergency"
	spread_text = "The patient is having a cardiac emergency"
	max_stages = 3
	spread_flags = SPECIAL
	cure_text = "Atropine or Epinephrine"
	cures = list("atropine", "epinephrine")
	cure_chance = 10
	needs_all_cures = FALSE
	viable_mobtypes = list(/mob/living/carbon/human)
	stage_prob = 5
	severity = DANGEROUS
	disease_flags = CURABLE
	required_organs = list(/obj/item/organ/internal/heart)
	bypasses_immunity = TRUE
	virus_heal_resistant = TRUE

/datum/disease/critical/heart_failure/has_cure()
	if(affected_mob.has_status_effect(STATUS_EFFECT_EXERCISED))
		return TRUE

	return ..()

/datum/disease/critical/heart_failure/stage_act()
	if(..())
		switch(stage)
			if(1)
				if(prob(1) && prob(10))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("pale", "shudder"))
				if(prob(5))
					to_chat(affected_mob, "<span class='danger'>Your arm hurts!</span>")
				else if(prob(5))
					to_chat(affected_mob, "<span class='danger'>Your chest hurts!</span>")
			if(2)
				if(prob(1) && prob(10))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("pale", "groan"))
				if(prob(5))
					to_chat(affected_mob, "<span class='danger'>Your heart lurches in your chest!</span>")
					affected_mob.AdjustLoseBreath(1)
				if(prob(3))
					to_chat(affected_mob, "<span class='danger'>Your heart stops beating!</span>")
					affected_mob.AdjustLoseBreath(3)
				if(prob(5))
					affected_mob.emote(pick("faint", "collapse", "groan"))
			if(3)
				affected_mob.adjustOxyLoss(1)
				if(prob(8))
					affected_mob.emote(pick("twitch", "gasp"))
				if(prob(5) && ishuman(affected_mob))
					var/mob/living/carbon/human/H = affected_mob
					H.set_heartattack(TRUE)