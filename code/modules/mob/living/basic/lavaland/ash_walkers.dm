/mob/living/basic/ash_walker
	name = "ash walker"
	desc = "These reptillian creatures appear to be related to the Unathi, but seem significantly less evolved."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "ashwalker"
	icon_living = "ashwalker"
	icon_dead = "ashwalker_dead" // Does not actually exist. del_on_death.
	icon_gib = "ashwalker_gib" // Does not actually exist. del_on_death.
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	speed = -0.8
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 15
	melee_attack_cooldown_min = 1 SECONDS
	melee_attack_cooldown_max = 1.5 SECONDS
	attack_verb_continuous = "stabs"
	attack_verb_simple = "stab"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	a_intent = INTENT_HARM
	ai_controller = /datum/ai_controller/basic_controller/simple/ash_walker
	faction = list("ashwalker")
	weather_immunities = list("lava","ash")
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	loot = list(/obj/effect/mob_spawn/human/corpse/ashwalker,
		/obj/item/spear,
		/obj/item/stack/ore/iron{layer = ABOVE_MOB_LAYER})
	basic_mob_flags = DEL_ON_DEATH
	sentience_type = SENTIENCE_OTHER
	step_type = FOOTSTEP_MOB_SHOE

/mob/living/basic/ash_walker/Initialize(mapload)
	. = ..()
	add_language("Sinta'unathi")
	set_default_language(GLOB.all_languages["Sinta'unathi"])
	gender = pick(MALE, FEMALE)
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/ash_walker/tough
	name = "ash walker hunter"
	icon_state = "ashwalker_tough"
	icon_living = "ashwalker_tough"
	damage_coeff = list(BRUTE = 0.9, BURN = 0.6, TOX = 1, CLONE = 1, STAMINA = 1, OXY = 1)
	melee_damage_lower = 15
	melee_damage_upper = 20
	loot = list(/obj/effect/mob_spawn/human/corpse/ashwalker,
		/obj/item/spear,
		/obj/item/stack/ore/plasma{layer = ABOVE_MOB_LAYER})

/mob/living/basic/ash_walker/veteran
	name = "ash walker slayer"
	icon_state = "ashwalker_veteran"
	icon_living = "ashwalker_veteran"
	damage_coeff = list(BRUTE = 0.8, BURN = 0.4, TOX = 1, CLONE = 1, STAMINA = 1, OXY = 1)
	armor_penetration_flat = 15
	melee_damage_lower = 15
	melee_damage_upper = 20
	loot = list(/obj/effect/mob_spawn/human/corpse/ashwalker,
		/obj/item/spear,
		/obj/item/stack/ore/silver{layer = ABOVE_MOB_LAYER})

/mob/living/basic/ash_walker/elite
	name = "ash walker dragonslayer"
	icon_state = "ashwalker_elite"
	icon_living = "ashwalker_elite"
	damage_coeff = list(BRUTE = 0.5, BURN = 0, TOX = 1, CLONE = 1, STAMINA = 1, OXY = 1)
	armor_penetration_flat = 25
	melee_damage_lower = 20
	melee_damage_upper = 25
	loot = list(/obj/effect/mob_spawn/human/corpse/ashwalker,
		/obj/item/spear,
		/obj/item/stack/ore/gold{layer = ABOVE_MOB_LAYER})

/datum/ai_controller/basic_controller/simple/ash_walker
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/generic_resist,
		/datum/ai_planning_subtree/random_speech/ash_walker,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl/lavaland,
	)

/datum/ai_planning_subtree/random_speech/ash_walker
	speech_chance = 10
	emote_see = list("grunts.", "hisses.", "inspects their claws.")
	speak = list(
		"As the necropolis wills.",
		"It's been too long since we've had a good hunt.",
		"Don't sleep in the shade too long. The cold dreams will find you.",
		"I heard the dust singing across the rocks today.",
		"The young ones think the lava fields are a brave place. They will find good hunts there.",
		"Did you see that star fall?",
		"Sometimes, I feel like they're watching me.",
		"I heard someone got a goliath the other day. Delicious.",
		"Think we'll see an offworlder today?",
		"Words are cheap.")
