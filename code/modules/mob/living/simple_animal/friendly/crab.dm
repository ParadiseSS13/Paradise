//Look Sir, free crabs!
/mob/living/simple_animal/crab
	name = "crab"
	desc = "A hard-shelled crustacean. Seems quite content to lounge around all the time."
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks")
	emote_see = list("clacks")
	speak_chance = 1
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	stop_automated_movement = 1
	friendly = "pinches"
	ventcrawler = 2
	can_hide = 1
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/crab/handle_automated_movement()
	//CRAB movement
	if(!stat)
		if(isturf(src.loc) && !resting && !buckled)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				var/east_vs_west = pick(4, 8)
				if(Process_Spacemove(east_vs_west))
					Move(get_step(src, east_vs_west), east_vs_west)

//COFFEE! SQUEEEEEEEEE!
/mob/living/simple_animal/crab/Coffee
	name = "Coffee"
	real_name = "Coffee"
	desc = "It's Coffee, the other pet!"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/simple_animal/crab/evil
	name = "Evil Crab"
	real_name = "Evil Crab"
	desc = "Unnerving, isn't it? It has to be planning something nefarious..."
	icon_state = "evilcrab"
	icon_living = "evilcrab"
	icon_dead = "evilcrab_dead"
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "stomps"
	gold_core_spawnable = HOSTILE_SPAWN
