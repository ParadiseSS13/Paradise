/mob/living/basic/alien/drone
	name = "alien drone"
	icon_state = "aliend_running"
	icon_living = "aliend_running"
	icon_dead = "aliend_dead"
	melee_damage_lower = 15
	melee_damage_upper = 15

	ai_controller = /datum/ai_controller/basic_controller/alien/drone

/mob/living/basic/alien/drone/lavaland
	maximum_survivable_temperature = INFINITY
