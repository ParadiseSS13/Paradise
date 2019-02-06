/datum/disease/Cancer
	form = "Condition"
	name = "Space Cancer"
	max_stages = 5
	cure_text = "Surgery"
	agent = "Cancer Cells"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	desc = "The Old and Trusty Cancer but in SPACE."
	severity = "Very Dangerous!"
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC
	required_organs = list(/obj/item/organ/internal/Lungs)
	bypasses_immunity = TRUE
	virus_heal_resistant = TRUE

/datum/disease/Cancer/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(5))
				affected_mob.emote("cough")
		if(2)
			var/obj/item/organ/internal/Lungs/A = affected_mob.get_int_organ(/obj/item/organ/internal/Lungs)
			if(A)
				A.inflamed = 1
				A.update_icon()
			if(prob(3))
				to_chat(affected_mob, "<span class='warning'>You feel a sharp Pain in your chest!</span>")
				affected_mob.adjustOxyLoss(10)
		if(3)
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>You can´t Breathe Normaly!</span>")
                if(4)
                        if(prob(1))
                                to_chat(affected_mob, "<span class='warning'>You feel the pain expanding to all your body!</span>")
                                affected_mob.AdjustWeaken(10)
                                affected_mob.AdjustToxinloss(30)
                if(5)
                        if(prob(4))
                                to_chat(affected_mob, "<span class='warning'>You can´t Figth it anymore!</span>")
                                affected_mob.AdjusttoxinLoss(30)
                                affected_mob.adjustoxyloss(30)
                if(6)
                        if(prob(3))
                                to_chat(affected_mob, "<span class='warning'>You feel CANCEROUS!</span>")
	                        affected_mob.adjustBruteLoss(20)
                if(7)
                        if(prob(3))
                                to_chat(affected_mob, "<span class='warning'>You feel Weak!</span>")
	                        affected_mob.Weaken(10)
                if(8)
                        if(prob(3))
                                to_chat(affected_mob, "<span class='warning'>You are too weak to Stand Up!</span>")
	                        affected_mob.stun(4)
                if(9)
                        if(prob(3))
                                to_chat(affected_mob, "<span class='warning'>You just let you go!</span>")
	                        affected_mob.adjustOXYLoss(70)

