/datum/disease/black_death
	name = "Black Hole Death"
	max_stages = 5
	spread_flags = CONTACT_GENERAL|BLOOD
	spread_text = "Fleas, blood and contact"
	cure_text = "Holywater and Haloperidol"
	cures = list("holywater","haloperidol")
	cure_chance = 7
	agent = "Nigrum Foraminis Pestis"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A variant of the old black plague, it is usually carried by space fleas that live with space ants."
	severity = BIOHAZARD
	virus_heal_resistant = TRUE
	needs_all_cures = TRUE
	stage_prob = 1

/datum/disease/black_death/stage_act()
	..()
	switch(stage)
		if(1)
			visibility_flags = HIDDEN_SCANNER
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>You feel a headache.</span>")
				affected_mob.adjustStaminaLoss(15)

		if(2)
			visibility_flags = HIDDEN_SCANNER
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>Some black lumps begin to appear in your body.</span>")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel a headache.</span>")
				affected_mob.adjustStaminaLoss(15)

		if(3)
			visibility_flags = null
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Some black lumps begin to appear in your body.</span>")
			if(prob(15))
				to_chat(affected_mob, "<span class='danger'>You feel a headache.</span>")
				affected_mob.adjustStaminaLoss(15)

		if(4)
			visibility_flags = null
			if(prob(15))
				to_chat(affected_mob, "<span class='danger'>You feel a headache.</span>")
				affected_mob.adjustStaminaLoss(30)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>The black lumps hurt a lot.</span>")
				affected_mob.adjustStaminaLoss(30)
				affected_mob.adjustBruteLoss(0.2)
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Black bumps explode on your skin!</span>")
				affected_mob.adjustBruteLoss(20)

		if(5)
			visibility_flags = null
			if(prob(15))
				to_chat(affected_mob, "<span class='danger'>You feel a sensation of hypersensitivity and muscular pain.</span>")
				affected_mob.drop_r_hand()
				affected_mob.Weaken(10)
				affected_mob.adjustBruteLoss(2)
				affected_mob.drop_l_hand()
			if(prob(20))
				to_chat(affected_mob, "<span class='userdanger'>You feel your mind very slower.</span>")
				affected_mob.AdjustConfused(8, bound_lower = 0, bound_upper = 100)
				affected_mob.Dizzy(5)
				affected_mob.adjustStaminaLoss(20)
				affected_mob.Weaken(10)
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Black bumps explode on your skin!</span>")
				affected_mob.adjustBruteLoss(20)
			if(prob(15))
				to_chat(affected_mob, "<span class='danger'>The walls of your mouth start to drop blood.</span>")
				affected_mob.adjustBruteLoss(5)
				affected_mob.vomit(0,1)
			if(prob(20))
				to_chat(affected_mob, "<span class='danger'>You feel a headache.</span>")
				affected_mob.adjustStaminaLoss(100)
