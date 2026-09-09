/datum/ai_behavior/flock/resist
	name = "resisting"
	action_cooldown = 15 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/flock/resist/goap_score(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	if(SHOULD_RESIST(living_pawn) || length(living_pawn.grabbed_by) || isobj(living_pawn.loc))
		return 5
	return 0

/datum/ai_behavior/flock/resist/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	..()
	controller.queue_behavior(/datum/ai_behavior/resist)
	return AI_BEHAVIOR_SUCCEEDED

