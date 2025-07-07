/datum/ai_planning_subtree/random_speech/pig
	speech_chance = 2
	speak = list("oink?", "oink", "OINK")
	sound = list('sound/creatures/pig.ogg')
	emote_hear = list("oinks.")
	emote_see = list("rolls around.")

/datum/ai_controller/basic_controller/pig
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/pig,
	)

/mob/living/basic/pig
	name = "pig"
	desc = "Oink oink."
	icon_state = "pig"
	icon_living = "pig"
	icon_dead = "pig_dead"
	ai_controller = /datum/ai_controller/basic_controller/pig
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/ham = 6)
	health = 50
	maxHealth = 50
	melee_damage_lower = 1
	melee_damage_upper = 2
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	unintelligble_phrases = list("Oink?", "Oink", "OINK")
	unintelligble_speak_verbs = list("oinks")

/mob/living/basic/pig/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_SHOE)
