/datum/disease/tuberculosis
	form = "Disease"
	name = "Fungal tuberculosis"
	max_stages = 5
	spread_text = "Airborne"
	cure_text = "Spaceacillin & salbutamol"
	cures = list("spaceacillin", "salbutamol")
	agent = "Fungal Tubercle bacillus Cosmosis"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 5//like hell are you getting out of hell
	desc = "A rare highly transmittable virulent virus. Few samples exist, rumoured to be carefully grown and cultured by clandestine bio-weapon specialists. Causes fever, blood vomiting, lung damage, weight loss, and fatigue."
	required_organs = list(/obj/item/organ/internal/lungs)
	severity = DANGEROUS
	bypasses_immunity = TRUE //Fungal and bacterial in nature; also infects the lungs

/datum/disease/tuberculosis/stage_act() //it begins
	..()
	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("cough")
				to_chat(affected_mob, "<span class='danger'>Your chest hurts.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your stomach violently rumbles!</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You feel a cold sweat form.</span>")
		if(4)
			if(prob(2))
				to_chat(affected_mob, "<span class='userdanger'>You see four of everything</span>")
				affected_mob.Dizzy(5)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You feel a sharp pain from your lower chest!</span>")
				affected_mob.adjustOxyLoss(5)
				affected_mob.emote("gasp")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel air escape from your lungs painfully.</span>")
				affected_mob.adjustOxyLoss(25)
				affected_mob.emote("gasp")
		if(5)
			if(prob(2))
				to_chat(affected_mob, "<span class='userdanger'>[pick("You feel your heart slowing...", "You relax and slow your heartbeat.")]</span>")
				affected_mob.adjustStaminaLoss(70)
			if(prob(10))
				affected_mob.adjustStaminaLoss(100)
				affected_mob.visible_message("<span class='warning'>[affected_mob] faints!</span>", "<span class='userdanger'>You surrender yourself and feel at peace...</span>")
				affected_mob.AdjustSleeping(5)
			if(prob(2))
				to_chat(affected_mob, "<span class='userdanger'>You feel your mind relax and your thoughts drift!</span>")
				affected_mob.AdjustConfused(8, bound_lower = 0, bound_upper = 100)
			if(prob(10))
				affected_mob.vomit(20)
			if(prob(3))
				to_chat(affected_mob, "<span class='warning'><i>[pick("Your stomach silently rumbles...", "Your stomach seizes up and falls limp, muscles dead and lifeless.", "You could eat a crayon")]</i></span>")
				affected_mob.overeatduration = max(affected_mob.overeatduration - 100, 0)
				affected_mob.nutrition = max(affected_mob.nutrition - 100, 0)
			if(prob(15))
				to_chat(affected_mob, "<span class='danger'>[pick("You feel uncomfortably hot...", "You feel like unzipping your jumpsuit", "You feel like taking off some clothes...")]</span>")
				affected_mob.bodytemperature += 40
	return
