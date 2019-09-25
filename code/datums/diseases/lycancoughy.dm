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
	var/barklimit = 0

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
			if(prob(3) && barklimit <= 10)
				var/list/puppytype = list(/mob/living/simple_animal/pet/dog/corgi/puppy, /mob/living/simple_animal/pet/dog/pug, /mob/living/simple_animal/pet/dog/fox)
				var/mob/living/puppypicked = pick(puppytype)
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up [initial(puppypicked.name)]!</span>", \
													"<span class='userdanger'>You cough up [initial(puppypicked.name)]?!</span>")
				new puppypicked(affected_mob.loc)
				new puppypicked(affected_mob.loc)
				barklimit ++
			if(prob(1))
				var/list/plushtype = list(/obj/item/toy/plushie/orange_fox, /obj/item/toy/plushie/corgi, /obj/item/toy/plushie/robo_corgi, /obj/item/toy/plushie/pink_fox)
				var/obj/item/toy/plushie/coughfox = pick(plushtype)
				new coughfox(affected_mob.loc)
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up a [initial(coughfox.name)]!</span>", \
													"<span class='userdanger'>You cough [initial(coughfox.name)] up ?!</span>")

			affected_mob.emote("cough")
			affected_mob.adjustBruteLoss(5)
	return
