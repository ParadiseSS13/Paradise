/datum/ai_behavior/flock/stare
	name = "analyzing"
	action_cooldown = 20 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/flock/stare/goap_score(datum/ai_controller/controller)
	if(controller.behavior_cooldowns[src] > world.time)
		return 0

	return length(get_targets(controller)) > 0

/datum/ai_behavior/flock/stare/get_cooldown(datum/ai_controller/cooldown_for)
	return rand(2, 3) MINUTES

/datum/ai_behavior/flock/stare/proc/get_targets(datum/ai_controller/controller)
	. = list()
	for(var/mob/living/viewer in viewers(controller.pawn, controller.target_search_radius))
		if(isvox(viewer) || istype(viewer, /mob/living/simple_animal/parrot))
			. += viewer

/datum/ai_behavior/flock/stare/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	..()
	var/list/targets = get_targets(controller)
	if(length(targets))
		controller.set_blackboard_key(BB_FLOCK_STARE_TARGET, pick(targets))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/stare/next_behavior(datum/ai_controller/controller, success)
	if(success)
		return controller.queue_behavior(/datum/ai_behavior/flock/stare_at_bird)

/datum/ai_behavior/flock/stare_at_bird
	name = "analyzing"
	action_cooldown = 20 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/flock/stare_at_bird/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	..()
	var/mob/living/living_pawn = controller.pawn
	living_pawn.face_atom(controller.blackboard[BB_FLOCK_STARE_TARGET])
	var/atom/A = controller.blackboard[BB_FLOCK_STARE_TARGET]
	if(prob(30))
		living_pawn.manual_emote("stares at [A].")

	controller.clear_blackboard_key(BB_FLOCK_STARE_TARGET)

	return AI_BEHAVIOR_SUCCEEDED
