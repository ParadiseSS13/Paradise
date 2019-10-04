//Foxxy
/mob/living/simple_animal/pet/dog/fox
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
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 3)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"

//Captain fox
/mob/living/simple_animal/pet/dog/fox/Renault
	name = "Renault"
	desc = "Renault, the Captain's trustworthy fox. I wonder what it says?"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

//Syndi fox
/mob/living/simple_animal/pet/dog/fox/Syndifox
	name = "Syndifox"
	desc = "Syndifox, the Syndicate's most respected mascot. I wonder what it says?"
	icon_state = "Syndifox"
	icon_living = "Syndifox"
	icon_dead = "Syndifox_dead"
	icon_resting = "Syndifox_rest"
	mutations = list(BREATHLESS)
	faction = list("syndicate")
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	melee_damage_lower = 10
	melee_damage_upper = 20