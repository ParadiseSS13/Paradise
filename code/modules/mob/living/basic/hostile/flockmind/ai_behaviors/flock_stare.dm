/datum/ai_behavior/flock/stare
	name = "analyzing"
	goap_weight = FLOCK_BEHAVIOR_WEIGHT_STARE

/datum/ai_behavior/flock/stare/goap_score(datum/ai_controller/controller)
	if(controller.behavior_cooldowns[src] > world.time)
		return 0

	return length(get_targets(controller)) > 0

/datum/ai_behavior/flock/stare/get_cooldown(datum/ai_controller/cooldown_for)
	return rand(2, 3) MINUTES

/datum/ai_behavior/flock/stare/proc/get_targets(datum/ai_controller/controller)
	. = list()
	for(var/mob/living/viewer in viewers(controller.pawn, controller.target_search_radius))
		if(isteshari(viewer) || isvox(viewer) || istype(viewer, /mob/living/simple_animal/parrot))
			. += viewer

/datum/ai_behavior/flock/stare/perform(delta_time, datum/ai_controller/controller, ...)
	..()
	var/list/targets = get_targets(controller)
	if(length(targets))
		controller.set_blackboard_key(BB_FLOCK_STARE_TARGET, pick(targets))
		return BEHAVIOR_PERFORM_COOLDOWN | BEHAVIOR_PERFORM_SUCCESS

	return BEHAVIOR_PERFORM_FAILURE

/datum/ai_behavior/flock/stare/next_behavior(datum/ai_controller/controller, success)
	if(success)
		return controller.queue_behavior(/datum/ai_behavior/flock/stare_at_bird)

/datum/ai_behavior/flock/stare_at_bird
	name = "analyzing"
	action_cooldown = 1 SECOND

/datum/ai_behavior/flock/stare_at_bird/perform(delta_time, datum/ai_controller/controller, ...)
	..()
	var/mob/living/living_pawn = controller.pawn
	if(!controller.blackboard[BB_FLOCK_STARING_ACTIVE])
		controller.set_blackboard_key(BB_FLOCK_STARING_ACTIVE, world.time + (10 SECONDS))

		if(prob(30))
			living_pawn.manual_emote("whistles.")

	if(!controller.blackboard[BB_FLOCK_STARE_TARGET])
		return BEHAVIOR_PERFORM_SUCCESS

	if(!can_see(living_pawn,controller.blackboard[BB_FLOCK_STARE_TARGET]))
		return BEHAVIOR_PERFORM_SUCCESS

	if(controller.blackboard[BB_FLOCK_STARING_ACTIVE] <= world.time)
		return BEHAVIOR_PERFORM_SUCCESS

	living_pawn.face_atom(controller.blackboard[BB_FLOCK_STARE_TARGET])
	return BEHAVIOR_PERFORM_COOLDOWN

/datum/ai_behavior/flock/stare_at_bird/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_FLOCK_STARING_ACTIVE)
	controller.clear_blackboard_key(BB_FLOCK_STARE_TARGET)
