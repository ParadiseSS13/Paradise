/mob/living/basic/samak
	name = "samak"
	desc = "A fast, armored predator accustomed to hiding and ambushing in cold terrain."
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	butcher_results = list(/obj/item/food/meat = 2)

	icon_state = "samak"
	icon_living = "samak"
	icon_dead = "samak_dead"
	attack_verb_continuous = "mauls"
	attack_verb_simple = "maul"

	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	faction = list("avernus")
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/diyaab
	name = "diyaab"
	desc = "A small pack animal. Although omnivorous, it will hunt meat on occasion."
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	butcher_results = list(/obj/item/food/meat = 1)

	icon_state = "diyaab"
	icon_living = "diyaab"
	icon_dead = "diyaab_dead"
	attack_verb_continuous = "gouges"
	attack_verb_simple = "gouge"

	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	faction = list("avernus")
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/shantak
	name = "shantak"
	desc = "A piglike creature with a bright iridiscent mane that sparkles as though lit by an inner light. Don't be fooled by its beauty though."
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	butcher_results = list(/obj/item/food/meat = 1)

	icon_state = "shantak"
	icon_living = "shantak"
	icon_dead = "shantak_dead"
	attack_verb_continuous = "gouges"
	attack_verb_simple = "gouge"

	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	faction = list("avernus")
	gold_core_spawnable = NO_SPAWN

/obj/effect/spawner/random/avernus_monsters
	spawn_loot_chance = 50
	loot = list(
		/mob/living/basic/samak,
		/mob/living/basic/shantak,
		/mob/living/basic/diyaab,
	)
