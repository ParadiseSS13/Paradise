/mob/living/basic/alien/sentinel
	name = "alien sentinel"
	icon_state = "aliens_running"
	icon_living = "aliens_running"
	icon_dead = "aliens_dead"
	health = 150
	maxHealth = 150
	melee_damage_lower = 15
	melee_damage_upper = 15

	ai_controller = /datum/ai_controller/basic_controller/alien/sentinel

	is_ranged = TRUE
	projectile_type = /obj/item/projectile/neurotox
	projectile_sound = 'sound/weapons/pierce.ogg'
	ranged_cooldown = 1 SECONDS
