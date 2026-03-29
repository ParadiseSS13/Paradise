/datum/disease/tuberculosis
	form = "Disease"
	name = "Fungal tuberculosis"
	max_stages = 5
	spread_text = "Airborne"
	cure_text = "Spaceacillin & Salbutamol"
	cures = list("spaceacillin", "salbutamol")
	agent = "Fungal Tubercle bacillus Cosmosis"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 5 // Like hell are you getting out of hell
	desc = "A rare highly transmittable virulent virus. Few samples exist, rumoured to be carefully grown and cultured by clandestine bio-weapon specialists. Causes fever, blood vomiting, lung damage, weight loss, and fatigue."
	required_organs = list(ORGAN_DATUM_LUNGS)
	severity = VIRUS_HARMFUL
	bypasses_immunity = TRUE //Fungal and bacterial in nature; also infects the lungs

/datum/disease/tuberculosis/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("cough")
				to_chat(affected_mob, SPAN_DANGER("Your chest hurts."))
			if(prob(2))
				to_chat(affected_mob, SPAN_DANGER("Your stomach violently rumbles!"))
			if(prob(5))
				to_chat(affected_mob, SPAN_DANGER("You feel a cold sweat form."))
		if(4)
			if(prob(2))
				to_chat(affected_mob, SPAN_USERDANGER("You see four of everything"))
				affected_mob.Dizzy(10 SECONDS)
			if(prob(2))
				to_chat(affected_mob, SPAN_DANGER("You feel a sharp pain from your lower chest!"))
				affected_mob.adjustOxyLoss(5)
				affected_mob.emote("gasp")
			if(prob(10))
				to_chat(affected_mob, SPAN_DANGER("You feel air escape from your lungs painfully."))
				affected_mob.adjustOxyLoss(25)
				affected_mob.emote("gasp")
		if(5)
			if(prob(2))
				to_chat(affected_mob, SPAN_USERDANGER("[pick("You feel your heart slowing...", "You relax and slow your heartbeat.")]"))
				affected_mob.adjustStaminaLoss(70)
			if(prob(10))
				affected_mob.adjustStaminaLoss(100)
				affected_mob.visible_message(SPAN_WARNING("[affected_mob] faints!"), SPAN_USERDANGER("You surrender yourself and feel at peace..."))
				affected_mob.AdjustSleeping(10 SECONDS)
			if(prob(2))
				to_chat(affected_mob, SPAN_USERDANGER("You feel your mind relax and your thoughts drift!"))
				affected_mob.AdjustConfused(16 SECONDS, bound_lower = 0, bound_upper = 200 SECONDS)
			if(prob(10))
				affected_mob.vomit(20)
			if(prob(3))
				to_chat(affected_mob, SPAN_WARNING("<i>[pick("Your stomach silently rumbles...", "Your stomach seizes up and falls limp, muscles dead and lifeless.", "You could eat a crayon")]</i>"))
				affected_mob.overeatduration = max(affected_mob.overeatduration - 100, 0)
				affected_mob.adjust_nutrition(-100)
			if(prob(15))
				to_chat(affected_mob, SPAN_DANGER("[pick("You feel uncomfortably hot...", "You feel like unzipping your jumpsuit", "You feel like taking off some clothes...")]"))
				affected_mob.bodytemperature += 40
	return
