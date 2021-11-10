/mob/living/simple_animal/hostile/clowngoblin
	icon = 'icons/mob/animal.dmi'
	name = "maint clown goblin"
	desc = "A tiny walking mask and clown shoes. He WILL honk your nose!"
	icon_state = "clowngoblin"
	icon_living = "clowngoblin"
	icon_dead = null
	mob_biotypes = MOB_ORGANIC
	response_help = "honks the"
	speak = list("Honk!")
	speak_emote = list("sqeaks")
	emote_see = list("honks")
	maxHealth = 30
	health = 30

	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speak = list("HONK", "Honk!", "Welcome to clown planet!")
	emote_see = list("honks")
	speak_chance = 1
	a_intent = INTENT_HARM

	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "attacks"
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 0
	environment_smash = 0
	minbodytemp = 270
	maxbodytemp = 370
	heat_damage_per_tick = 15
	cold_damage_per_tick = 15
	unsuitable_atmos_damage = 30
	footstep_type = FOOTSTEP_MOB_SHOE

	speed = -1
	turns_per_move = 1

	del_on_death = TRUE
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/item/clothing/shoes/clown_shoes)
