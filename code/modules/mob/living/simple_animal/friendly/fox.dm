//Foxxy
/mob/living/simple_animal/pet/fox
	name = "fox"
	desc = "It's a fox. I wonder what it says?"
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	speak = list("Ack-Ack","Ack-Ack-Ack-Ackawoooo","Geckers","Awoo","Tchoff")
	speak_emote = list("geckers", "barks")
	emote_hear = list("howls","barks")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	meat_amount = 3
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"

//Captain fox
/mob/living/simple_animal/pet/fox/Renault
	name = "Renault"
	desc = "Renault, the Captain's trustworthy fox. I wonder what it says?"

//Syndi fox
/mob/living/simple_animal/pet/fox/Syndifox
	name = "Syndifox"
	desc = "Syndifox, the Syndicate's most respected mascot. I wonder what it says?"
	icon_state = "Syndifox"
	icon_living = "Syndifox"
	icon_dead = "Syndifox_dead"
	icon_resting = "Syndifox_rest"
	flags = IS_SYNTHETIC|NO_BREATHE
	faction = list("syndicate")
