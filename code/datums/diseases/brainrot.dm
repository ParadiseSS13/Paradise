/datum/disease/brainrot
	name = "Brainrot"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Mannitol"
	cures = list("mannitol")
	agent = "Cryptococcus Cosmosis"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 15//higher chance to cure, since two reagents are required
	desc = "This disease destroys the braincells, causing brain fever, brain necrosis and general intoxication."
	required_organs = list(/obj/item/organ/internal/brain)
	severity = DANGEROUS

/datum/disease/brainrot/stage_act() //Removed toxloss because damaging diseases are pretty horrible. Last round it killed the entire station because the cure didn't work -- Urist -ACTUALLY Removed rather than commented out, I don't see it returning - RR
	if(!..())
		return FALSE
	switch(stage)
		if(2)
			if(MAYBE)
				affected_mob.emote("blink")
			if(MAYBE)
				affected_mob.emote("yawn")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>You don't feel like yourself.</span>")
			if(MAYBE)
				affected_mob.adjustBrainLoss(1)
		if(3)
			if(MAYBE)
				affected_mob.emote("stare")
			if(MAYBE)
				affected_mob.emote("drool")
			if(MAYBE && affected_mob.getBrainLoss()<=98)//shouldn't brainpain you to death now
				affected_mob.adjustBrainLoss(2)
				if(MAYBE)
					to_chat(affected_mob, "<span class='danger'>Your try to remember something important...but can't.</span>")

		if(4)
			if(MAYBE)
				affected_mob.emote("stare")
			if(MAYBE)
				affected_mob.emote("drool")
			if(MAYBE && affected_mob.getBrainLoss()<=98) //shouldn't brainpain you to death now
				affected_mob.adjustBrainLoss(3)
				if(MAYBE)
					to_chat(affected_mob, "<span class='danger'>Strange buzzing fills your head, removing all thoughts.</span>")
			if(MAYBE)
				to_chat(affected_mob, "<span class='danger'>You lose consciousness...</span>")
				affected_mob.visible_message("<span class='warning'>[affected_mob] suddenly collapses</span>")
				affected_mob.Paralyse(rand(10 SECONDS, 20 SECONDS))
				if(MAYBE)
					affected_mob.emote("snore")
			if(MAYBE)
				affected_mob.AdjustStuttering(6 SECONDS)

	return
