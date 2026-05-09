/datum/ai_behavior/flock/find_deconstruct_target
	name = "deconstructing"
	goap_weight = FLOCK_BEHAVIOR_WEIGHT_DECONSTRUCT

/datum/ai_behavior/flock/find_deconstruct_target/setup(datum/ai_controller/controller, turf/overmind_target)
	. = ..()
	if(overmind_target)
		var/mob/living/basic/flock/drone/bird = controller.pawn
		if(is_valid_target(overmind_target))
			controller.set_blackboard_key(BB_FLOCK_OVERMIND_CONTROL, TRUE)
			controller.set_blackboard_key(BB_PATH_MAX_LENGTH, 200)
			bird.say("instruction confirmed: deconstruct object", forced = TRUE)
		else
			bird.say("invalid deconstruct target provided by sentient-level instruction", forced = TRUE)
			return FALSE

/datum/ai_behavior/flock/find_deconstruct_target/goap_precondition(datum/ai_controller/controller)
	var/mob/living/basic/flock/bird = controller.pawn
	return length(bird.flock?.marked_for_deconstruction)

/datum/ai_behavior/flock/find_deconstruct_target/goap_score(datum/ai_controller/controller)
	return score_distance(controller, get_target(controller))

/datum/ai_behavior/flock/find_deconstruct_target/score_distance(datum/ai_controller/controller, atom/target)
	. = ..()
	var/mob/living/basic/flock/bird = controller.pawn
	if(bird.flock?.marked_for_deconstruction[target])
	/*
	* because the result of scoring is based on max distance,
	* the score of any given tile is -100 to 0, with 0 being best.
	* Adding 200 basically allows a tile at twice the max distance to be considered.
	*/
		. += 200

/datum/ai_behavior/flock/find_deconstruct_target/proc/get_target(datum/ai_controller/controller, path_to = FALSE)
	var/mob/living/basic/flock/bird = controller.pawn

	var/list/options = list()
	for(var/atom/A as anything in bird.flock.marked_for_deconstruction)
		if(get_dist(A, bird) > controller.max_target_distance)
			continue

		if(bird.flock && !bird.flock.is_turf_free(get_turf(A)))
			continue

		options += A

	return get_best_target_by_distance_score(controller, options, path_to)

/datum/ai_behavior/flock/find_deconstruct_target/proc/is_valid_target(atom/target)
	return !ismob(target) && HAS_TRAIT(target, TRAIT_FLOCK_THING) && !HAS_TRAIT(target, TRAIT_FLOCK_NODECON)

/datum/ai_behavior/flock/find_deconstruct_target/perform(seconds_per_tick, datum/ai_controller/controller, turf/overmind_target)
	..()
	var/atom/target = overmind_target || get_target(controller, TRUE)
	if(!target)
		return AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_FLOCK_DECON_TARGET, target)

	var/mob/living/basic/flock/bird = controller.pawn
	if(bird.flock)
		bird.flock.reserve_turf(bird, get_turf(target), remove_on_change = FALSE)

	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/find_deconstruct_target/finish_action(datum/ai_controller/controller, succeeded, turf/overmind_target)
	. = ..()
	controller.clear_blackboard_key(BB_PATH_TO_USE)

	if(!succeeded && overmind_target)
		controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
		controller.clear_blackboard_key(BB_FLOCK_OVERMIND_CONTROL)

/datum/ai_behavior/flock/find_deconstruct_target/next_behavior(datum/ai_controller/controller, success)
	if(success)
		controller.queue_behavior(/datum/ai_behavior/flock/perform_deconstruct)

/datum/ai_behavior/flock/perform_deconstruct
	name = "deconstructing"
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/flock/perform_deconstruct/setup(datum/ai_controller/controller, ...)
	var/turf/target_turf = controller.blackboard[BB_FLOCK_DECON_TARGET]
	set_movement_target(controller, target_turf)
	return ..()

/datum/ai_behavior/flock/perform_deconstruct/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	..()
	var/mob/living/basic/flock/bird = controller.pawn
	var/turf/target = controller.blackboard[BB_FLOCK_DECON_TARGET]
	if(target)
		controller.clear_blackboard_key(BB_FLOCK_DECON_TARGET)
		var/datum/action/cooldown/flock/deconstruct/deconstruct_action = locate() in bird.actions
		spawn(-1)
			deconstruct_action.Trigger(target = target)

	if(DOING_INTERACTION(bird, "flock_deconstruct"))
		return AI_BEHAVIOR_DELAY

	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/perform_deconstruct/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	var/mob/living/basic/flock/drone/bird = controller.pawn
	bird.flock?.free_turf(bird)

	if(!succeeded && controller.blackboard[BB_FLOCK_OVERMIND_CONTROL] && !QDELETED(controller.pawn))
		bird.say("unable to reach target provided by sentient level instruction, aborting subroutine", forced = TRUE)

	controller.clear_blackboard_key(BB_FLOCK_DECON_TARGET)
	controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
	controller.clear_blackboard_key(BB_FLOCK_OVERMIND_CONTROL)

