//Foxxy
/mob/living/simple_animal/pet/fox
	name = "fox"
	desc = "It's a fox. I wonder what it says?"
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	icon_resting = "fox_rest"
	speak = list("Ack-Ack","Ack-Ack-Ack-Ackawoooo","Geckers","Awoo","Tchoff")
	speak_emote = list("geckers", "barks")
	emote_hear = list("howls","barks")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 3)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

	var/turns_since_scan = 0
	var/mob/living/movement_target

//Captain fox
/mob/living/simple_animal/pet/fox/Renault
	name = "Renault"
	desc = "Renault, the Captain's trustworthy fox. I wonder what it says?"
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID

/mob/living/simple_animal/pet/fox/Renault/handle_automated_action()
	. = ..()

	if(!incapacitated())
		for(var/mob/living/L in range(1, src))
			if(Adjacent(L) && L == movement_target)
				perform_the_nom(src, L, src, "Stomach")
				movement_target = null

/mob/living/simple_animal/pet/fox/Renault/handle_automated_movement()
	. = ..()

	if(!incapacitated())
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if(movement_target && !isturf(movement_target.loc))
				movement_target = null
				stop_automated_movement = 0
			if(!movement_target || !(movement_target.loc in oview(src, 3)))
				movement_target = null
				stop_automated_movement = 0
				for(var/mob/living/snack in oview(src, 3))
					if(isturf(snack.loc) && !snack.stat)
						if(snack.get_species() == "Vulpkanin") //is this caninebalism
							movement_target = snack
							break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src, movement_target, 0, 3)


//Syndi fox
/mob/living/simple_animal/pet/fox/Syndifox
	name = "Syndifox"
	desc = "Syndifox, the Syndicate's most respected mascot. I wonder what it says?"
	icon_state = "Syndifox"
	icon_living = "Syndifox"
	icon_dead = "Syndifox_dead"
	icon_resting = "Syndifox_rest"
	flags = NO_BREATHE
	faction = list("syndicate")
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0