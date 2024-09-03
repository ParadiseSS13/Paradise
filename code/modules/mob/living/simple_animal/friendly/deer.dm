/mob/living/simple_animal/deer
	name = "deer"
	desc = "A strong, brave deer."
	icon_state = "deer"
	icon_living = "deer"
	icon_dead = "deer_dead"
	speak = list("snorts")
	speak_emote = list("snorts")
	emote_see = list("shakes its head")
	faction = list("neutral", "jungle")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 0 //I'm so funny
	butcher_results = list(/obj/item/food/meat = 4)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	can_collar = TRUE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
