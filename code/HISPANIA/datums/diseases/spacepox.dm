/datum/disease/spacepox
	name = "Spacepox"
	max_stages = 4
	spread_text = "On contact"
	cure_text = "Mitocholide & Pentetic Acid"
	cures = list("mitocholide", "pen_acid")
	cure_chance = 15
	agent = "Spaciola major"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "In addition to flu-like symptoms, patients also experience  rashes that appear first on the faces and later on the trunk."
	severity = DANGEROUS

/datum/disease/spacepox/stage_act()
	..()
	var/mob/living/carbon/human/H = affected_mob
	var/obj/item/organ/external/head = H.get_organ("head")
	var/obj/item/organ/external/l_leg = H.get_organ("l_leg")
	var/obj/item/organ/external/r_leg = H.get_organ("r_leg")
	var/obj/item/organ/external/r_arm = H.get_organ("r_arm")
	var/obj/item/organ/external/l_arm = H.get_organ("l_arm")

	switch(stage)
		if(2)
			affected_mob.bodytemperature += 10
			if(prob(15))
				affected_mob.emote("cough")
			if(prob(15))
				to_chat(affected_mob, "<span class='danger'>You feel week!</span>")

		if(3)
			if(prob(5))
				if(head.receive_damage(6, 0))
					affected_mob.UpdateDamageIcon()
			if(prob(10))
				affected_mob.emote("cough")
			if(prob(15))
				to_chat(affected_mob, "<span class='danger'>You can feel sores on your face!</span>")

		if(4)
			if(prob(5))
				if(r_leg.receive_damage(6, 0) && l_leg.receive_damage(6, 0))
					affected_mob.UpdateDamageIcon()
			if(prob(5))
				if(r_arm.receive_damage(6, 0) && l_arm.receive_damage(6, 0))
					affected_mob.UpdateDamageIcon()
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You can feel pustules on your entire body!</span>")
				affected_mob.take_organ_damage(0,5)
	return
