/mob/living/simple_animal/hostile/retaliate/clown
	name = "Clown"
	desc = "A denizen of clown planet"
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speak = list("HONK", "Honk!", "Welcome to clown planet!")
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


/mob/living/simple_animal/hostile/retaliate/clown/goblin
	name = "clown goblin"
	desc = "A tiny walking mask and clown shoes. You want to honk his nose!"
	icon_state = "clowngoblin"
	icon_living = "clowngoblin"
	icon_dead = null
	response_help = "honks the"
	speak = list("Honk!")
	speak_emote = list("sqeaks")
	emote_see = list("honks")
	maxHealth = 100
	health = 100

	speed = -1
	turns_per_move = 1

	del_on_death = TRUE
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/item/clothing/shoes/clown_shoes)
