/mob/living/simple_animal/pet/sloth
	name = "sloth"
	desc = "An adorable, sleepy creature."
	icon = 'icons/mob/pets.dmi'
	icon_state = "sloth"
	icon_living = "sloth"
	icon_dead = "sloth_dead"
	gender = MALE
	speak = list("Ahhhh")
	speak_emote = list("yawns")
	emote_hear = list("snores.","yawns.")
	emote_see = list("dozes off.", "looks around sleepily.")
	speak_chance = 1
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 3)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY
	melee_damage_lower = 0
	melee_damage_upper = 0
	health = 50
	maxHealth = 50
	speed = 2


//Cargo Sloth
/mob/living/simple_animal/pet/sloth/paperwork
	name = "Paperwork"
	desc = "Cargo's pet sloth. About as useful as the rest of the techs."
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID