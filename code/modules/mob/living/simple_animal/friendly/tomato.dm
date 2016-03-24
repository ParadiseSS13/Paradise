/mob/living/simple_animal/tomato
	name = "tomato"
	desc = "It's a horrifyingly enormous beef tomato, and it's packing extra beef!"
	icon_state = "tomato"
	icon_living = "tomato"
	icon_dead = "tomato_dead"
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 15
	health = 15
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/tomatomeat = 3)
	response_help  = "prods the"
	response_disarm = "pushes aside the"
	response_harm   = "smacks the"
	harm_intent_damage = 5
	pass_flags = PASSTABLE
	can_hide = 1