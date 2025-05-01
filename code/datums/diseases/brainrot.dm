/datum/disease/brainrot
	name = "Brainrot"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = SPREAD_CONTACT_GENERAL
	cure_text = "Mannitol"
	cures = list("mannitol")
	agent = "Cryptococcus Cosmosis"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 15
	desc = "This disease destroys the braincells, causing brain fever, brain necrosis and general intoxication."
	required_organs = list(/obj/item/organ/internal/brain)
	severity = VIRUS_HARMFUL

/datum/disease/brainrot/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("blink")
			if(prob(2))
				affected_mob.emote("yawn")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You don't feel like yourself.</span>")
			if(prob(5))
				affected_mob.adjustBrainLoss(1)
		if(3)
			if(prob(2))
				affected_mob.emote("stare")
			if(prob(2))
				affected_mob.emote("drool")
			if(prob(10) && affected_mob.getBrainLoss() < 100)
				affected_mob.adjustBrainLoss(2)
				if(prob(2))
					to_chat(affected_mob, "<span class='danger'>Your try to remember something important...but can't.</span>")

		if(4)
			if(prob(2))
				affected_mob.emote("stare")
			if(prob(2))
				affected_mob.emote("drool")
			if(prob(15) && affected_mob.getBrainLoss() < 100)
				affected_mob.adjustBrainLoss(3)
				if(prob(2))
					to_chat(affected_mob, "<span class='danger'>Strange buzzing fills your head, removing all thoughts.</span>")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>You lose consciousness...</span>")
				affected_mob.visible_message("<span class='warning'>[affected_mob] suddenly collapses</span>")
				affected_mob.Paralyse(rand(10 SECONDS, 20 SECONDS))
				if(prob(1))
					affected_mob.emote("snore")
			if(prob(15))
				affected_mob.AdjustStuttering(6 SECONDS)

	return
