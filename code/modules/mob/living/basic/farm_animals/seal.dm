/mob/living/basic/seal
	name = "seal"
	desc = "A beautiful white seal."
	icon_state = "seal"
	icon_living = "seal"
	icon_dead = "seal_dead"
	speak_emote = list("urks")
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat = 6)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	health = 50
	maxHealth = 50
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/seal

/mob/living/basic/seal/walrus
	name = "walrus"
	desc = "A big brown walrus."
	icon_state = "walrus"
	icon_living = "walrus"
	icon_dead = "walrus_dead"

/mob/living/basic/seal/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/ai_retaliate)
	/// Basic mobs need a language otherwise their speech is garbled
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])

/datum/ai_controller/basic_controller/seal
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/seal,
	)

/datum/ai_planning_subtree/random_speech/seal
	speech_chance = 2
	speak = list("Urk?", "urk.", "URK!")
	emote_see = list("flops around.")
