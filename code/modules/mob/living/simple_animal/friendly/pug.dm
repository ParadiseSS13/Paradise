//Corgi //best comment 2014
/mob/living/simple_animal/pet/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "It's a pug."
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	speak_chance = 1
	turns_per_move = 10
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/pug = 3)
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	see_in_dark = 5
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

/mob/living/simple_animal/pet/pug/process_ai()
	..()

	if(!resting && !buckled)
		if(prob(1))
			custom_emote(1, pick("chases its tail."))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)
