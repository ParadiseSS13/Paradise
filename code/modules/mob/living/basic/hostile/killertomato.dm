/mob/living/basic/killertomato
	name = "Killer Tomato"
	desc = "It's a horrifyingly enormous beef tomato, and it's packing extra beef!"
	icon_state = "tomato"
	icon_living = "tomato"
	icon_dead = "tomato_dead"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	maxHealth = 30
	health = 30
	see_in_dark = 3
	butcher_results = list(/obj/item/food/meat/tomatomeat = 2)
	response_help_simple  = "prod"
	response_help_continuous = "prods"
	response_disarm_simple = "push aside"
	response_disarm_continuous = "pushes aside"
	response_harm_simple = "smack"
	response_harm_continuous = "smacks"
	melee_damage_lower = 8
	melee_damage_upper = 12
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	attack_verb_simple = "slam"
	attack_verb_continuous = "slams"
	faction = list("plants", "jungle")
	ventcrawler = VENTCRAWLER_ALWAYS

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 150
	maximum_survivable_temperature = 500
	gold_core_spawnable = HOSTILE_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles/ventcrawler
	contains_xeno_organ = TRUE
	surgery_container = /datum/xenobiology_surgery_container/tomato
