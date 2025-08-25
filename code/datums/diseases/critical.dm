/datum/disease/critical
	form = "Medical Emergency"
	max_stages = 3
	spread_flags = SPREAD_SPECIAL
	viable_mobtypes = list(/mob/living/carbon/human)
	severity = VIRUS_MINOR
	disease_flags = VIRUS_CURABLE
	visibility_flags = VIRUS_HIDDEN_PANDEMIC
	bypasses_immunity = TRUE
	virus_heal_resistant = TRUE

/datum/disease/critical/stage_act() //overriden to ensure unique behavior
	stage = min(stage, max_stages)

	if(prob(stage_prob))
		stage = min(stage + 1, max_stages)

	if(has_cure())
		cure()
		return FALSE
	return TRUE

/datum/disease/critical/has_cure()
	for(var/C_id in cures)
		if(affected_mob.reagents.has_reagent(C_id))
			if(prob(cure_chance))
				return TRUE
	return FALSE

/datum/disease/critical/shock
	name = "Shock"
	spread_text = "The patient is in shock."
	cure_text = "Saline-Glucose Solution"
	cures = list("salglu_solution", "syndicate_nanites", "stimulative_agent")
	cure_chance = 10
	stage_prob = 6

/datum/disease/critical/shock/stage_act()
	if(..())
		if(affected_mob.health >= 25 && affected_mob.nutrition >= NUTRITION_LEVEL_HYPOGLYCEMIA)
			to_chat(affected_mob, span_notice("You feel better."))
			cure()
			return
		switch(stage)
			if(1)
				if(prob(1) && prob(10))
					to_chat(affected_mob, span_notice("You feel better."))
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("shiver", "pale", "moan"))
				if(prob(5))
					to_chat(affected_mob, span_danger("You feel weak!"))
			if(2)
				if(prob(1) && prob(10))
					to_chat(affected_mob, span_notice("You feel better."))
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("shiver", "pale", "moan", "shudder", "tremble"))
				if(prob(5))
					to_chat(affected_mob, span_danger("You feel absolutely terrible!"))
				if(prob(5))
					affected_mob.emote(pick(2; "faint", 1; "groan"))
			if(3)
				if(prob(1) && prob(10))
					to_chat(affected_mob, span_notice("You feel better."))
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("shudder", "pale", "tremble", "groan", "bshake"))
				if(prob(5))
					to_chat(affected_mob, span_danger("You feel horrible!"))
				if(prob(5))
					affected_mob.emote(pick(2; "faint", 1; "groan"))
				if(prob(7))
					to_chat(affected_mob, span_danger("You can't breathe!"))
					affected_mob.AdjustLoseBreath(2 SECONDS)
				if(prob(5))
					var/datum/disease/D = new /datum/disease/critical/heart_failure
					affected_mob.ForceContractDisease(D)

/datum/disease/critical/heart_failure
	name = "Cardiac Failure"
	spread_text = "The patient is having a cardiac emergency."
	cure_text = "Atropine, Epinephrine, or Heparin"
	cures = list("atropine", "epinephrine", "heparin", "syndicate_nanites", "stimulative_agent")
	cure_chance = 10
	stage_prob = 5
	severity = VIRUS_HARMFUL
	required_organs = list(ORGAN_DATUM_HEART)

/datum/disease/critical/heart_failure/stage_act()
	if(..())
		switch(stage)
			if(1)
				if(prob(1) && prob(10))
					to_chat(affected_mob, span_notice("You feel better."))
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("pale", "shudder"))
				if(prob(5))
					to_chat(affected_mob, span_danger("Your arm hurts!"))
				else if(prob(5))
					to_chat(affected_mob, span_danger("Your chest hurts!"))
			if(2)
				if(prob(1) && prob(10))
					to_chat(affected_mob, span_notice("You feel better."))
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("pale", "groan"))
				if(prob(5))
					to_chat(affected_mob, span_danger("Your heart lurches in your chest!"))
					affected_mob.AdjustLoseBreath(2 SECONDS)
				if(prob(3))
					to_chat(affected_mob, span_danger("Your heart stops beating!"))
					affected_mob.AdjustLoseBreath(6 SECONDS)
				if(prob(5))
					affected_mob.emote(pick(2; "faint", 1; "groan"))
			if(3)
				affected_mob.adjustOxyLoss(1)
				if(prob(8))
					affected_mob.emote(pick("twitch", "gasp"))
				if(prob(5) && ishuman(affected_mob))
					var/mob/living/carbon/human/H = affected_mob
					H.set_heartattack(TRUE)

/datum/disease/critical/hypoglycemia
	name = "Hypoglycemia"
	spread_text = "The patient has low blood sugar."
	cure_text = "Eating or administration of vitamins or nutrients"
	stage_prob = 1

/datum/disease/critical/hypoglycemia/has_cure()
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if(HAS_TRAIT(H, TRAIT_NOHUNGER))
			return TRUE
		if(ismachineperson(H))
			return TRUE
	return ..()

/datum/disease/critical/hypoglycemia/stage_act()
	if(..())
		if(isLivingSSD(affected_mob)) // We don't want AFK people dying from this.
			return
		if(affected_mob.nutrition > NUTRITION_LEVEL_HYPOGLYCEMIA)
			to_chat(affected_mob, span_notice("You feel a lot better!"))
			cure()
			return
		switch(stage)
			if(1)
				if(prob(4))
					to_chat(affected_mob, span_warning("You feel hungry!"))
				if(prob(2))
					to_chat(affected_mob, span_warning("You have a headache!"))
				if(prob(2))
					to_chat(affected_mob, span_warning("You feel [pick("anxious", "depressed")]!"))
			if(2)
				if(prob(4))
					to_chat(affected_mob, span_warning("You feel like everything is wrong with your life!"))
				if(prob(5))
					affected_mob.Slowed(rand(8 SECONDS, 32 SECONDS))
					to_chat(affected_mob, span_warning("You feel [pick("tired", "exhausted", "sluggish")]."))
				if(prob(5))
					affected_mob.Weaken(12 SECONDS)
					affected_mob.Stuttering(20 SECONDS)
					to_chat(affected_mob, span_warning("You feel [pick("numb", "confused", "dizzy", "lightheaded")]."))
					affected_mob.emote("collapse")
			if(3)
				if(prob(8))
					var/datum/disease/D = new /datum/disease/critical/shock
					affected_mob.ForceContractDisease(D)
				if(prob(12))
					affected_mob.Weaken(12 SECONDS)
					affected_mob.Stuttering(20 SECONDS)
					to_chat(affected_mob, span_warning("You feel [pick("numb", "confused", "dizzy", "lightheaded")]."))
					affected_mob.emote("collapse")
				if(prob(12))
					to_chat(affected_mob, span_warning("You feel [pick("tired", "exhausted", "sluggish")]."))
					affected_mob.Slowed(rand(8 SECONDS, 32 SECONDS))
