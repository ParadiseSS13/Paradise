/datum/disease/lycan
	name = "Lycancoughy"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Ethanol"
	cures = list("ethanol")
	agent = "Excess Snuggles"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "If left untreated subject will regurgitate... puppies."
	severity = MEDIUM

/datum/disease/lycan/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>You itch.</span>")
				affected_mob.emote("cough")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>You hear faint barking.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>You crave meat.</span>")
				affected_mob.emote("cough")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your stomach growls!</span>")
		if(4)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Your stomach barks?!</span>")
			if(prob(5))
				affected_mob.visible_message("<span class='danger'>[affected_mob] howls!</span>", \
												"<span class='userdanger'>You howl!</span>")
				affected_mob.AdjustConfused(rand(6, 8))
			if(prob(3))
				var/list/puppytype = list(/mob/living/simple_animal/pet/corgi/puppy, /mob/living/simple_animal/pet/pug, /mob/living/simple_animal/pet/fox)
				var/mob/living/puppypicked = pick(puppytype)
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up [initial(puppypicked.name)]!</span>", \
													"<span class='userdanger'>You cough up [initial(puppypicked.name)]?!</span>")
				affected_mob.emote("cough")
				affected_mob.adjustBruteLoss(5)
				new puppypicked(affected_mob.loc)
				new puppypicked(affected_mob.loc)
	return
