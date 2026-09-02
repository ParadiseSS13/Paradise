/datum/disease/lycan
	name = "Lycancoughy"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = SPREAD_CONTACT_GENERAL
	cure_text = "Ethanol"
	cures = list("ethanol")
	agent = "Excess Snuggles"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "If left untreated subject will regurgitate... puppies."
	severity = VIRUS_HARMFUL
	var/barklimit = 10
	var/list/puppy_types = list(/mob/living/simple_animal/pet/dog/corgi/puppy, /mob/living/simple_animal/pet/dog/pug, /mob/living/simple_animal/pet/dog/fox)
	var/list/plush_types = list(/obj/item/toy/plushie/orange_fox, /obj/item/toy/plushie/corgi, /obj/item/toy/plushie/robo_corgi, /obj/item/toy/plushie/pink_fox)

/datum/disease/lycan/stage_act()
	if(!..())
		return FALSE

	var/mob/living/carbon/human/H = affected_mob

	switch(stage)
		if(2)
			if(prob(2))
				H.emote("cough")
			if(prob(3))
				to_chat(H, SPAN_NOTICE("You itch."))
				H.adjustBruteLoss(rand(4, 6))
		if(3)
			var/obj/item/organ/external/stomach = H.bodyparts_by_name[pick("chest", "groin")]

			if(prob(3))
				H.emote("cough")
				stomach.receive_damage(rand(0, 5))
			if(prob(3))
				to_chat(H, SPAN_NOTICE("You hear faint barking."))
				stomach.receive_damage(rand(4, 6))
			if(prob(2))
				to_chat(H, SPAN_NOTICE("You crave meat."))
			if(prob(3))
				to_chat(H, SPAN_DANGER("Your stomach growls!"))
				stomach.receive_damage(rand(5, 10))
		if(4)
			var/obj/item/organ/external/stomach = H.bodyparts_by_name[pick("chest", "groin")]

			if(prob(5))
				H.emote("cough")
				stomach.receive_damage(rand(0, 5))
			if(prob(5))
				to_chat(H, SPAN_DANGER("Your stomach barks?!"))
				stomach.receive_damage(rand(5, 10))
			if(prob(5))
				H.visible_message(
					SPAN_DANGER("[H] howls!"),
					SPAN_USERDANGER("You howl!")
					)
				H.AdjustConfused(rand(12 SECONDS, 16 SECONDS))
				stomach.receive_damage(rand(0, 5))
			if(prob(5))
				if(!barklimit)
					to_chat(H, SPAN_DANGER("Your stomach growls!"))
					stomach.receive_damage(rand(5, 10))
				else
					var/atom/hairball = pick(prob(50) ? puppy_types : plush_types)
					H.visible_message(
						SPAN_DANGER("[H] coughs up \a [initial(hairball.name)]!"),
						SPAN_USERDANGER("You cough up \a [initial(hairball.name)]?!")
						)
					new hairball(H.loc)
					barklimit--
					stomach.receive_damage(rand(10, 15))
