/datum/disease/stoneman_disease
	name = "Stoneman disease"
	max_stages = 5
	spread_text = "On contact"
	cure_text = "Mitocholide & Pentetic Acid"
	cures = list("mitocholide", "pen_acid")
	cure_chance = 15
	agent = "Ossiumviridae"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "A mutation of the body's repair mechanism, which causes fibrous tissue to be ossified spontaneously or when damaged."
	severity = DANGEROUS

/datum/disease/stoneman_disease/stage_act()
	..()

	switch(stage)
		if(1)
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Your chest hurts.</span>")
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your chest hurts.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your neck feels stiff!</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Your arms feel heavy.</span>")
				affected_mob.adjustStaminaLoss(15)
		if(3)
			if(prob(2))
				to_chat(affected_mob, "<span class='userdanger'>You can barely move your legs</span>")
				affected_mob.adjustStaminaLoss(30)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You feel a sharp pain from your lower chest!</span>")
				affected_mob.adjustOxyLoss(5)
				affected_mob.emote("gasp")
			if(prob(10))
				to_chat(affected_mob, "<span class='userdanger'>[pick("Your knees feel stiff...", "Your arms feel stiff.")]</span>")
				affected_mob.adjustStaminaLoss(10)
		if(4)
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You feel a sharp pain from your chest!</span>")
				affected_mob.adjustStaminaLoss(20)
				affected_mob.emote("scream")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You can't move your face.!</span>")
				affected_mob.emote("stare")
			if(prob(5))
				to_chat(affected_mob, "<span class='userdanger'>You can't move your arms!</span>")
				affected_mob.drop_l_hand()
				affected_mob.drop_r_hand()
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Something's piercing your lungs!.</span>")
				affected_mob.adjustOxyLoss(15)
				affected_mob.adjustStaminaLoss(50)
				affected_mob.emote("gasp")
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>You can't move your legs!.</span>")
				affected_mob.adjustStaminaLoss(100)
		if(5)
			if(prob(20))
				to_chat(affected_mob, "<span class='danger'>You can't move your body!</span>")
				affected_mob.adjustStaminaLoss(100)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Something's piercing your lungs!.</span>")
				affected_mob.adjustOxyLoss(30)
				affected_mob.adjustStaminaLoss(50)
				affected_mob.emote("scream")
	return