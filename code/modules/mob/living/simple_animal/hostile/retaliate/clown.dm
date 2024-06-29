/mob/living/simple_animal/hostile/retaliate/clown
	name = "Clown"
	desc = "A strange creature that vaguely resembles a normal clown. Upon closer inspection, it is nothing of the sort."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speak = list("HONK", "Honk!", "Come join the fun!")
	emote_see = list("honks")
	speak_chance = 1
	a_intent = INTENT_HARM
	maxHealth = 75
	health = 75
	speed = 0
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "attacks"
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 0
	environment_smash = 0
	minbodytemp = 270
	maxbodytemp = 370
	heat_damage_per_tick = 15	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	cold_damage_per_tick = 10	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	unsuitable_atmos_damage = 10
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/retaliate/clown/goblin
	icon = 'icons/mob/animal.dmi'
	name = "clown goblin"
	desc = "A tiny walking mask and clown shoes. You want to honk his nose!"
	icon_state = "clowngoblin"
	icon_living = "clowngoblin"
	icon_dead = null
	mob_biotypes = MOB_ORGANIC
	response_help = "honks the"
	speak = list("Honk!")
	speak_emote = list("squeaks")
	emote_see = list("honks")
	maxHealth = 100
	health = 100

	speed = -1
	turns_per_move = 1

	del_on_death = TRUE
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/item/clothing/shoes/clown_shoes)

/mob/living/simple_animal/hostile/retaliate/clown/goblin/cluwne
	name = "cluwne goblin"
	desc = "A tiny pile of misery and evil. Kill this thing before it comes for your family."
	icon_state = "cluwnegoblin"
	icon_living = "cluwnegoblin"
	response_help = "henks the"
	speak = list("HENK!")
	emote_see = list("henks")
	maxHealth = 150
	health = 150
	harm_intent_damage = 15
	melee_damage_lower = 17
	melee_damage_upper = 20
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	move_to_delay = 2

	loot = list(/obj/item/clothing/mask/false_cluwne_mask, /obj/item/clothing/shoes/clown_shoes/false_cluwne_shoes) // We'd rather not give them ACTUAL cluwne stuff you know?
