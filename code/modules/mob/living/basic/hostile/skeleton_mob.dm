/mob/living/basic/skeleton
	name = "reanimated skeleton"
	desc = "A real bonefied skeleton, doesn't seem like it wants to socialize."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "skeleton"
	icon_living = "skeleton"
	speak_emote = list("rattles")
	mob_biotypes = MOB_UNDEAD | MOB_HUMANOID
	maxHealth = 40
	health = 40
	a_intent = INTENT_HARM
	melee_damage_lower = 15
	melee_damage_upper = 15
	harm_intent_damage = 5
	obj_damage = 50
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	healable = FALSE
	attack_verb_simple = "slash"
	attack_verb_continuous = "slashes"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAM = 0, OXY = 1)
	unsuitable_atmos_damage = 10
	see_in_dark = 8
	faction = list("skeleton")
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	speed = 1
	step_type = FOOTSTEP_MOB_SHOE
	gold_core_spawnable = HOSTILE_SPAWN
	loot = list(/obj/effect/decal/remains/human)
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles/demonic_incursion

/mob/living/basic/skeleton/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/skeleton/arctic
	name = "undead arctic explorer"
	desc = "The reanimated remains of some poor traveler."
	icon_state = "arctic_skeleton"
	icon_living = "arctic_skeleton"
	maxHealth = 55
	health = 55
	weather_immunities = list("snow")
	gold_core_spawnable = NO_SPAWN
	melee_damage_lower = 17
	melee_damage_upper = 20
	death_message = "collapses into a pile of bones, its gear falling to the floor!"
	loot = list(/obj/effect/decal/remains/human,
				/obj/item/spear,
				/obj/item/clothing/shoes/winterboots,
				/obj/item/clothing/suit/hooded/wintercoat)
