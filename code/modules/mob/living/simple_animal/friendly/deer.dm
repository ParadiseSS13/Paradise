/mob/living/simple_animal/deer
	name = "deer"
	desc = "A strong, brave deer."
	icon_state = "deer"
	icon_living = "deer"
	icon_dead = "deer_dead"
	speak = list("snorts")
	speak_emote = list("snorts")
	emote_see = list("shakes its head")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 0 //I'm so funny
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	meat_amount = 3
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"