/datum/disease/appendicitis
	form = "Condition"
	name = "Appendicitis"
	max_stages = 3
	spread_text = "Non-contagious"
	spread_flags = NON_CONTAGIOUS
	cure_text = "Surgery"
	agent = "Shitty Appendix"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "If left untreated the subject will become very weak, and may vomit often."
	severity = MINOR
	disease_flags = CAN_CARRY|CAN_RESIST
	visibility_flags = HIDDEN_PANDEMIC
	required_organs = list(/obj/item/organ/internal/appendix)
	bypasses_immunity = TRUE
	virus_heal_resistant = TRUE

/datum/disease/appendicitis/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(1)
			if(prob(5))
				affected_mob.emote("cough")
		if(2)
			var/obj/item/organ/internal/appendix/A = affected_mob.get_int_organ(/obj/item/organ/internal/appendix)
			if(A)
				A.inflamed = 1
				A.update_icon()
			if(prob(3))
				to_chat(affected_mob, "<span class='warning'>You feel a stabbing pain in your abdomen!</span>")
				affected_mob.Stun(rand(4 SECONDS, 6 SECONDS))
				affected_mob.adjustToxLoss(1)
		if(3)
			if(prob(1))
				affected_mob.vomit(95)
