/mob/living/basic/pet/sloth
	name = "sloth"
	desc = "An adorable, sleepy creature."
	icon_state = "sloth"
	icon_living = "sloth"
	icon_dead = "sloth_dead"
	gender = MALE
	speak_emote = list("yawns")
	faction = list("neutral", "jungle")
	butcher_results = list(/obj/item/food/meat = 3)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	ai_controller = /datum/ai_controller/basic_controller/sloth
	gold_core_spawnable = FRIENDLY_SPAWN
	melee_damage_upper = 5
	health = 50
	maxHealth = 50
	speed = 2
	step_type = FOOTSTEP_MOB_CLAW

/mob/living/basic/pet/sloth/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/ai_retaliate)

//IAA Sloth
/mob/living/basic/pet/sloth/paperwork
	name = "Paperwork"
	desc = "Internal Affairs' pet sloth. About as useful as the rest of the agents."
	gold_core_spawnable = NO_SPAWN

/datum/ai_controller/basic_controller/sloth
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/random_speech/sloth,
	)

/datum/ai_planning_subtree/random_speech/sloth
	speech_chance = 1
	speak = list("Ahhhh")
	emote_hear = list("snores.", "yawns.")
	emote_see = list("dozes off.", "looks around sleepily.")
