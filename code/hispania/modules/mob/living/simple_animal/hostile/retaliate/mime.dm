/mob/living/simple_animal/hostile/retaliate/mime_goblin
	name = "mime goblin"
	desc = "A tiny walking beret and white gloves as shoes. You want to hear his voice!"
	icon = 'icons/hispania/mob/animals.dmi'
	icon_state = "MimeGoblin"
	icon_living = "MimeGoblin"
	icon_dead = null
	response_help = "keeps in silence"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	maxHealth = 100
	health = 100
	a_intent = INTENT_HARM
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	obj_damage = 0
	environment_smash = 0
	minbodytemp = 270
	maxbodytemp = 370
	heat_damage_per_tick = 15
	cold_damage_per_tick = 10
	unsuitable_atmos_damage = 10
	speed = -1
	turns_per_move = 1

	del_on_death = TRUE
	loot = list(/obj/item/clothing/head/beret, /obj/item/clothing/gloves/color/white)
