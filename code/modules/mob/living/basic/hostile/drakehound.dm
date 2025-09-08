/mob/living/basic/drakehound_breacher
	name = "Drakehound Breacher"
	desc = "A unathi raider with a viscious streak."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "drakehound"
	icon_living = "drakehound"
	icon_dead = "drakehound_dead" // Does not actually exist. del_on_death.
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	response_help_continuous = "pushes the"
	response_help_continuous = "push the"
	response_harm_continuous = "slashes"
	response_harm_simple = "slash"
	speed = 0
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 30
	melee_damage_upper = 30
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	minimum_survivable_temperature = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speak_emote = list("hisses")
	ai_controller = /datum/ai_controller/basic_controller/simple/drakehound
	loot = list(
			/obj/effect/mob_spawn/human/corpse/drakehound,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)
	basic_mob_flags = DEL_ON_DEATH
	faction = list("pirate")
	sentience_type = SENTIENCE_OTHER
	step_type = FOOTSTEP_MOB_SHOE

/mob/living/basic/drakehound_breacher/Initialize(mapload)
	. = ..()
	add_language("Sinta'unathi")
	set_default_language(GLOB.all_languages["Sinta'unathi"])
	AddComponent(/datum/component/aggro_emote, aggro_sound = 'sound/effects/unathihiss.ogg', emote_chance = 100)
	if(prob(50))
		loot = list(
			/obj/item/salvage/loot/pirate,
			/obj/effect/mob_spawn/human/corpse/drakehound,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)

/mob/living/basic/drakehound_breacher/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/datum/ai_controller/basic_controller/simple/drakehound
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/drakehound,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/random_speech/drakehound
	speech_chance = 10
	speak = list(
		"I'll send you back to the pits!",
		"Finally, some action!",
		"You're gonna be quick work!",
		"Oh, now you fucked up!",
		"Maybe don't board the clearly dangerous looking ship?",
		"Heart Smash is better, you don't know good music.",
		"We wouldn't be stuck here if we just zigged when we zagged.",
		"Well, atleast I'm away from my brother!",
		"Got any smokes?")
