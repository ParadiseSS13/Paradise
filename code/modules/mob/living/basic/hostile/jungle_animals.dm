//*********//
// Panther //
//*********//

/mob/living/basic/panther
	name = "panther"
	desc = "A long sleek, black cat with sharp teeth and claws."
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "panther"
	icon_living = "panther"
	icon_dead = "panther_dead"
	icon_resting = "panther_rest"
	icon_gib = "panther_dead"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	butcher_results = list(/obj/item/food/meat = 3)
	faction = list("hostile", "jungle")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_continuous = "gently push aside"
	maxHealth = 50
	health = 50
	pixel_x = -16
	see_in_dark = 8

	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 15
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slashes"
	attack_sound = 'sound/weapons/bite.ogg'

	layer = 3.1		//so they can stay hidde under the /obj/structure/bush
	var/stalk_tick_delay = 3
	gold_core_spawnable = HOSTILE_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles

/mob/living/basic/panther/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aggro_emote, emote_list = list("gnashes"), emote_chance = 20)
