/mob/living/simple_animal/pet/raven
	name = "raven"
	desc = "Quoth the raven nevermore! Just now in space!"
	icon = 'icons/mob/animal.dmi'
	icon_state = "raven"
	icon_living = "raven"
	icon_dead = "raven_dead"
	speak_emote = list("caws")
	health = 7
	maxHealth = 7
	attacktext = "bites"
	obj_damage = 0
	melee_damage_lower = 2
	melee_damage_upper = 2
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "kicks"
	ventcrawler = 2
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	can_hide = TRUE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 2)
	can_collar = TRUE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
