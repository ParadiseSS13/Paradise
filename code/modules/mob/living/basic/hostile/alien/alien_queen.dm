/mob/living/basic/alien/queen
	name = "alien queen"
	icon_state = "alienq_running"
	icon_living = "alienq_running"
	icon_dead = "alienq_dead"
	health = 250
	maxHealth = 250
	melee_damage_lower = 15
	melee_damage_upper = 15
	status_flags = NONE // can't shove the queen, kiddo.

	ai_controller = /datum/ai_controller/basic_controller/alien/queen

	is_ranged = TRUE
	projectile_type = /obj/item/projectile/neurotox
	projectile_sound = 'sound/weapons/pierce.ogg'
	ranged_cooldown = 3 SECONDS

/mob/living/basic/alien/queen/lavaland
	maximum_survivable_temperature = INFINITY

/mob/living/basic/alien/queen/large
	name = "alien empress"
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "queen_s"
	icon_living = "queen_s"
	icon_dead = "queen_dead"
	bubble_icon = "alienroyal"
	maxHealth = 400
	health = 400
	mob_size = MOB_SIZE_LARGE

/mob/living/basic/alien/queen/large/lavaland
	maximum_survivable_temperature = INFINITY
