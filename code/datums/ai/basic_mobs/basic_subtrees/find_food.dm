/// Similar to finding a target but looks for food types in the blackboard.
/datum/ai_planning_subtree/find_food
	/// Behavior we use to find the food
	var/datum/ai_behavior/finding_behavior = /datum/ai_behavior/find_and_set/in_list
	/// Key of foods list
	var/food_list_key = BB_BASIC_FOODS
	/// Key where we store our food
	var/found_food_key = BB_TARGET_FOOD
	/// Key holding any emotes we play after eating food
	var/emotes_blackboard_list = BB_EAT_EMOTES
	/// Key where we store our search range
	var/search_range = BB_SEARCH_RANGE

/datum/ai_planning_subtree/find_food/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/list/foods_list = controller.blackboard[food_list_key]
	if(!length(foods_list))
		CRASH("the types of food has not been supplied in the [food_list_key] key!")
	if(controller.blackboard[BB_NEXT_FOOD_EAT] > world.time)
		return

	if(!controller.blackboard_key_exists(found_food_key))
		controller.queue_behavior(finding_behavior, found_food_key, foods_list, controller.blackboard[BB_SEARCH_RANGE])
		return

	controller.queue_behavior(/datum/ai_behavior/interact_with_target/eat_food, found_food_key, emotes_blackboard_list)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/interact_with_target/eat_food
	/// default list of actions we take after eating
	var/list/food_actions = list(
		"eats up happily!",
		"chomps with glee!",
	)

/datum/ai_behavior/interact_with_target/eat_food/perform(seconds_per_tick, datum/ai_controller/controller, target_key, emotes_blackboard_list)
	. = ..()
	if(. & AI_BEHAVIOR_FAILED)
		return
	var/list/emotes_to_pick = controller.blackboard[emotes_blackboard_list] || food_actions
	if(!length(emotes_to_pick))
		return
	var/mob/living/living_pawn = controller.pawn
	living_pawn.custom_emote(EMOTE_VISIBLE, pick(emotes_to_pick))
