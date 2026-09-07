/mob/living/basic/tree
	name = "pine tree"
	desc = "A pissed off tree-like alien. It seems annoyed with the festivities..."
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"
	icon_living = "pine_1"
	icon_dead = "pine_1"
	icon_gib = "pine_1"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	response_help_continuous = "brushes"
	response_help_simple = "brush"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"
	maxHealth = 250
	health = 250
	mob_size = MOB_SIZE_LARGE

	pixel_x = -16

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attack_verb_continuous = "bites"
	attack_verb_simple = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("pines")

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0

	faction = list("hostile", "winter")
	loot = list(/obj/item/stack/sheet/wood)
	gold_core_spawnable = HOSTILE_SPAWN
	deathmessage = "is hacked into pieces!"
	basic_mob_flags = DEL_ON_DEATH

	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles

/mob/living/basic/tree/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aggro_emote, emote_list = list("growls"), emote_chance = 20)
