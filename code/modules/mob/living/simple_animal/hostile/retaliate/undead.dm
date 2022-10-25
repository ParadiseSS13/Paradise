/mob/living/simple_animal/hostile/ghost/retaliate
	retaliate_only = TRUE

/mob/living/simple_animal/hostile/skeleton/retaliate
	name = "skeleton"
	icon = 'icons/mob/human.dmi'
	icon_state = "skeleton_s"
	icon_living = "skeleton_s"
	icon_dead = "skeleton_l"
	retaliate_only = TRUE
	speak_chance = 0
	turns_per_move = 10
	speed = 1
	maxHealth = 20
	health = 20
	harm_intent_damage = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	robust_searching = FALSE
	gold_core_spawnable = NO_SPAWN
	lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	footstep_type = null

/mob/living/simple_animal/hostile/zombie/retaliate
	retaliate_only = TRUE
