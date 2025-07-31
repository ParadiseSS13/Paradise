/mob/living/basic/feral_cat
	name = "feral cat"
	desc = "Kitty!! Wait..."
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	gender = MALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	maxHealth = 20
	health = 20
	melee_damage_lower = 5
	melee_damage_upper = 10
	attack_sound = 'sound/weapons/slash.ogg'
	melee_attack_cooldown_min = 0.5 SECONDS
	melee_attack_cooldown_max = 1.5 SECONDS
	attack_verb_simple = "claw"
	attack_verb_continuous = "claws"
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 2)
	response_help_simple  = "pet"
	response_help_continuous = "pets"
	response_disarm_simple = "gently push aside"
	response_disarm_continuous = "gently pushes aside"
	response_harm_simple = "kick"
	response_harm_continuous = "kicks"
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("cat")
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 5
	pass_flags = PASSTABLE
	step_type = FOOTSTEP_MOB_CLAW
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles/feral_cat

/datum/ai_controller/basic_controller/simple/simple_hostile_obstacles/feral_cat
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/cat,
	)

/datum/ai_planning_subtree/random_speech/cat
	speech_chance = 2
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	emote_hear = list("purrs", "meows")
	emote_see = list("meows", "mews")
