/datum/disease/anxiety
	name = "Severe Anxiety"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = SPREAD_CONTACT_GENERAL
	cure_text = "Ethanol"
	cures = list("ethanol")
	agent = "Excess Lepidopticides"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "If left untreated subject will regurgitate butterflies."
	severity = VIRUS_MINOR

/datum/disease/anxiety/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(2)
			if(prob(5))
				to_chat(affected_mob, SPAN_NOTICE("You feel anxious."))
		if(3)
			if(prob(10))
				to_chat(affected_mob, SPAN_NOTICE("Your stomach flutters."))
			if(prob(5))
				to_chat(affected_mob, SPAN_NOTICE("You feel panicky."))
			if(prob(2))
				to_chat(affected_mob, SPAN_DANGER("You're overtaken with panic!"))
				affected_mob.AdjustConfused(rand(4 SECONDS, 6 SECONDS))
		if(4)
			if(prob(10))
				to_chat(affected_mob, SPAN_DANGER("You feel butterflies in your stomach."))
			if(prob(5))
				affected_mob.visible_message(SPAN_DANGER("[affected_mob] stumbles around in a panic."), \
												SPAN_USERDANGER("You have a panic attack!"))
				affected_mob.AdjustConfused(rand(12 SECONDS, 16 SECONDS))
				affected_mob.AdjustJitter(rand(12 SECONDS, 16 SECONDS))
			if(prob(2))
				affected_mob.visible_message(SPAN_DANGER("[affected_mob] coughs up butterflies!"), \
													SPAN_USERDANGER("You cough up butterflies!"))
				for(var/i in 1 to 2)
					var/mob/living/basic/butterfly/B = new(affected_mob.loc)
					addtimer(CALLBACK(B, TYPE_PROC_REF(/mob/living/basic/butterfly, decompose)), rand(5, 25) SECONDS)

/**
 * Made so severe anxiety does not overload the SSmob while keeping it's effect
 */
/mob/living/basic/butterfly/proc/decompose()
	visible_message(SPAN_NOTICE("[src] decomposes due to being outside of its original habitat for too long!"),
					SPAN_USERDANGER("You decompose for being too long out of your habitat!"))
	melt()
