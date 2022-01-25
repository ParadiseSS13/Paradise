/mob/living/simple_animal/chick/ducktron
	name = "Major Duck"
	desc = "Pet of security, he looks tired."
	gender = MALE
	health = 1
	maxHealth = 1
	unique_pet = TRUE
	density = FALSE
	icon = 'icons/hispania/mob/animals.dmi'
	icon_resting = "duck_sleep"
	icon_state = "duck"
	icon_living = "duck"
	icon_dead = "duck_dead"
	speak_emote = list("sighs")
	emote_hear = list("sighs")
	emote_see = list("sighs")
	turns_per_move = 10
	can_collar = FALSE
	stop_automated_movement_when_pulled = 1
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/chick/ducktron/Life(seconds, times_fired)
	if(amount_grown >= 30)
		amount_grown = 0
