/mob/living/simple_animal/bunny
	name = "bunny"
	real_name = "bunny"
	desc = "Awww a cute bunny"
	icon_state = "m_bunny"
	icon_living = "m_bunny"
	icon_dead = "bunny_dead"
	icon_resting = "bunny_stretch"
	emote_see = list("thumps", "sniffs at something", "hops around", "flips their ears up")
	faction = list("neutral", "jungle")
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 10
	health = 10
	butcher_results = list(/obj/item/food/meat = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	mob_size = MOB_SIZE_TINY
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	can_hide = TRUE
	holder_type = /obj/item/holder/bunny
	can_collar = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN
	ventcrawler = VENTCRAWLER_ALWAYS

/mob/living/simple_animal/bunny/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M, TRUE)
	..()

/mob/living/simple_animal/bunny/syndi // for the syndicake factory bunny so its not being shot
	faction = list("syndicate")
	gold_core_spawnable = NO_SPAWN
