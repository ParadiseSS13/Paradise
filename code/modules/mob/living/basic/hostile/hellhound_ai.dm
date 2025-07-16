/datum/ai_controller/basic_controller/simple/hellhound
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/hellhound_rest,
		/datum/ai_planning_subtree/find_and_hunt_target/prowl,
		/datum/ai_planning_subtree/attack_obstacle_in_path/prowl,
	)

/datum/ai_planning_subtree/hellhound_rest/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/pawn = controller.pawn
	if(pawn.stat == DEAD)
		return

	if(pawn.getBruteLoss() || pawn.getFireLoss())
		controller.queue_behavior(/datum/ai_behavior/hellhound_rest)
		return SUBTREE_RETURN_FINISH_PLANNING
	else
		controller.queue_behavior(/datum/ai_behavior/hellhound_stand)

/datum/ai_behavior/hellhound_rest
	action_cooldown = 2 SECONDS

/datum/ai_behavior/hellhound_rest/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	. = ..()
	var/mob/living/basic/hellhound/hound = controller.pawn
	if(!IS_HORIZONTAL(hound))
		hound.lay_down()

	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/hellhound_stand
	action_cooldown = 2 SECONDS

/datum/ai_behavior/hellhound_stand/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	. = ..()
	var/mob/living/basic/hellhound/hound = controller.pawn
	if(IS_HORIZONTAL(hound))
		hound.stand_up()

	return AI_BEHAVIOR_SUCCEEDED
