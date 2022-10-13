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
	melee_damage_lower = 2
	melee_damage_upper = 2
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "kicks"
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	can_hide = TRUE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 2)
	can_collar = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN
	
/mob/living/simple_animal/pet/raven/nevermore
	name = "Nevermore"
	desc = "The coroner's pet. Reminds us that peace and quiet is coming for us all."
	icon_state = "raven"
	icon_living = "raven"
	icon_dead = "raven_dead"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	
/mob/living/simple_animal/pet/raven/npc_safe(mob/user)
    return TRUE
