/mob/living/basic/turkey
	name = "turkey"
	desc = "Benjamin Franklin would be proud."
	icon_state = "turkey"
	icon_living = "turkey"
	icon_dead = "turkey_dead"
	icon_resting = "turkey_rest"
	speak_emote = list("gobble")
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat = 4)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	health = 50
	maxHealth = 50
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	step_type = FOOTSTEP_MOB_CLAW
	ai_controller = /datum/ai_controller/basic_controller/turkey

/mob/living/basic/turkey/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/ai_retaliate)
	/// Basic mobs need a language otherwise their speech is garbled
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])

/datum/ai_controller/basic_controller/turkey
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/turkey,
	)

/datum/ai_planning_subtree/random_speech/turkey
	speech_chance = 2
	speak = list("gobble?", "gobble", "GOBBLE")
	emote_see = list("struts around.")
