//Look Sir, free crabs!
/mob/living/basic/crab
	name = "crab"
	desc = "A hard-shelled crustacean. Seems quite content to lounge around all the time."
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	speak_emote = list("clicks")
	butcher_results = list(/obj/item/food/meat = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"
	response_harm_continuous = "stomps"
	response_harm_simple = "stomp"
	friendly_verb_continuous = "pinches"
	friendly_verb_simple = "pinch"
	ventcrawler = VENTCRAWLER_ALWAYS
	can_hide = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/crab

/mob/living/basic/crab/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/sideways_movement)

/mob/living/basic/crab/valid_respawn_target_for(mob/user)
	. = ..()
	return TRUE

// COFFEE! SQUEEEEEEEEE!
/mob/living/basic/crab/coffee
	name = "Coffee"
	real_name = "Coffee"
	desc = "It's Coffee, the other pet!"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/crab/evil
	name = "Evil Crab"
	real_name = "Evil Crab"
	desc = "Unnerving, isn't it? It has to be planning something nefarious..."
	icon_state = "evilcrab"
	icon_living = "evilcrab"
	icon_dead = "evilcrab_dead"
	response_help_continuous = "pokes"
	response_help_simple = "poke"
	response_disarm_continuous = "shoves"
	response_disarm_simple = "shove"
	gold_core_spawnable = HOSTILE_SPAWN

/// Crabs don't do much, but they want to live. They will flee when attacked, but will opportunistically melee attack people who do
/datum/ai_controller/basic_controller/crab
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED | AI_FLAG_PAUSE_DURING_DO_AFTER
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/random_speech/crab,
	)


/datum/ai_planning_subtree/random_speech/crab
	speech_chance = 5
	emote_hear = list("clicks")
	emote_see = list("clacks")
