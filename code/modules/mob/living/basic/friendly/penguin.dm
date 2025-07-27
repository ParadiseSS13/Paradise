// Penguins

/mob/living/basic/pet/penguin
	name = "penguin"
	real_name = "penguin"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	speak_emote = list("squawks", "gakkers")
	faction = list("penguin")
	ai_controller = /datum/ai_controller/basic_controller/penguin
	see_in_dark = 5
	icon = 'icons/mob/penguins.dmi'
	step_type = FOOTSTEP_MOB_BAREFOOT

/mob/living/basic/pet/penguin/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/waddling)

/mob/living/basic/pet/penguin/emperor
	name = "Emperor penguin"
	desc = "Emperor of all he surveys."
	icon_state = "penguin"
	icon_living = "penguin"
	icon_dead = "penguin_dead"
	butcher_results = list()
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/basic/pet/penguin/eldrich
	name = "Albino penguin"
	desc = "Found in the depths of mountains."
	response_help_continuous = "taps"
	response_help_simple = "tap"
	response_disarm_continuous = "pokes"
	response_disarm_simple = "poke"
	response_harm_continuous = "flails at"
	response_harm_simple = "flail at"
	icon_state = "penguin_elder"
	icon_living = "penguin_elder"
	icon_dead = "penguin_dead"
	faction = list("penguin", "cult")

/mob/living/basic/pet/penguin/emperor/shamebrero
	name = "Shamebrero penguin"
	desc = "Shameful of all he surveys."
	icon_state = "penguin_shamebrero"
	icon_living = "penguin_shamebrero"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/pet/penguin/baby
	name = "Penguin chick"
	desc = "Can't fly and can barely waddles, but the prince of all chicks."
	icon_state = "penguin_baby"
	icon_living = "penguin_baby"
	icon_dead = "penguin_baby_dead"
	density = FALSE
	pass_flags = PASSMOB

/datum/ai_controller/basic_controller/penguin
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/penguin,
	)

/datum/ai_planning_subtree/random_speech/penguin
	speech_chance = 5
	speak = list("Gah Gah!", "NOOT NOOT!", "NOOT!", "Noot", "noot", "Prah!", "Grah!")
	emote_hear = list("squawks", "gakkers")
	emote_see = list("shakes its beak.", "flaps it's wings.", "preens itself.")

/datum/ai_controller/basic_controller/penguin/eldrich
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/penguin/eldrich,
	)

/datum/ai_planning_subtree/random_speech/penguin/eldrich
	speak = list("Gah Gah!", "Tekeli-li! Tekeli-li!", "Tekeli-li!", "Teke", "li")
