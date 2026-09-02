/mob/living/basic/bunny
	name = "bunny"
	real_name = "bunny"
	desc = "Awww a cute bunny."
	icon_state = "m_bunny"
	icon_living = "m_bunny"
	icon_dead = "bunny_dead"
	icon_resting = "bunny_stretch"
	faction = list("neutral", "jungle")
	see_in_dark = 6
	maxHealth = 10
	health = 10
	ai_controller = /datum/ai_controller/basic_controller/bunny
	butcher_results = list(/obj/item/food/meat = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	mob_size = MOB_SIZE_TINY
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 223		// Below -50 Degrees Celcius
	maximum_survivable_temperature = 323	// Above 50 Degrees Celcius
	can_hide = TRUE
	holder_type = /obj/item/holder/bunny
	gold_core_spawnable = FRIENDLY_SPAWN
	ventcrawler = VENTCRAWLER_ALWAYS

/mob/living/basic/bunny/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/bunny/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M, TRUE)
	return ..()

/mob/living/basic/bunny/syndi // for the syndicake factory bunny so its not being shot
	faction = list("syndicate")
	gold_core_spawnable = NO_SPAWN

/datum/ai_controller/basic_controller/bunny
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/rabbit,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
	)

/datum/ai_planning_subtree/random_speech/rabbit
	speech_chance = 10
	speak = list("Mrrp.", "CHIRP!", "Mrrp?") // rabbits make some weird noises dude i don't know what to tell you
	emote_hear = list("hops.", "thumps.")
	emote_see = list("hops around.", "bounces up and down.", "flips their ears up")
