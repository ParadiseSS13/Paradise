/datum/ai_controller/basic_controller/gutlunch
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/make_babies,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/random_speech/gutlunch,
	)

/datum/ai_controller/basic_controller/gutlunch/on_mob_eat()
	. = ..()
	var/mob/living/basic/mining/gutlunch/gut = pawn
	gut.udder.generateMilk()
	gut.regenerate_icons()

/datum/ai_controller/basic_controller/gutlunch/gubbuck
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/mining/gutlunch/guthen),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/mining/gutlunch/grublunch),
		BB_MAX_CHILDREN = 5,
	)

/datum/ai_controller/basic_controller/gutlunch/guthen
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/mining/gutlunch/gubbuck),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/mining/gutlunch/grublunch),
		BB_MAX_CHILDREN = 5,
	)

/datum/ai_controller/basic_controller/gutlunch/gutlunch_baby
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/mining/gutlunch),
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
	)

/datum/ai_planning_subtree/random_speech/gutlunch
	emote_hear = list("trills.")
	emote_see = list("sniffs.", "burps.")
