/datum/ai_behavior/flock/find_harvest_target
	name = "harvesting"
	goap_weight = FLOCK_BEHAVIOR_WEIGHT_HARVEST

/datum/ai_behavior/flock/find_harvest_target/setup(datum/ai_controller/controller, obj/item/overmind_target)
	. = ..()
	if(overmind_target)
		var/mob/living/basic/flock/drone/bird = controller.pawn
		if(isitem(overmind_target) && isturf(overmind_target.loc))
			controller.set_blackboard_key(BB_FLOCK_OVERMIND_CONTROL, TRUE)
			controller.set_blackboard_key(BB_PATH_MAX_LENGTH, 200)
			bird.say("instruction confirmed: convert object to substrate", forced = TRUE)
		else
			bird.say("invalid harvest target provided by sentient-level instruction", forced = TRUE)
			return FALSE

/datum/ai_behavior/flock/find_harvest_target/goap_precondition(datum/ai_controller/controller)
	var/mob/living/basic/flock/drone/bird = controller.pawn
	var/datum/flockdrone_part/absorber/absorber = locate() in bird.parts
	return !absorber.held_item

/datum/ai_behavior/flock/find_harvest_target/goap_score(datum/ai_controller/controller)
	return score_distance(controller, get_target(controller))

/datum/ai_behavior/flock/find_harvest_target/proc/get_target(datum/ai_controller/controller, path_to = FALSE)
	var/mob/living/basic/flock/bird = controller.pawn

	var/list/options = list()
	for(var/obj/item/I in view(controller.target_search_radius, bird))
		if(isturf(I.loc) && !I.anchored)
			options += I

	return get_best_target_by_distance_score(controller, options, path_to)

/datum/ai_behavior/flock/find_harvest_target/perform(seconds_per_tick, datum/ai_controller/controller, obj/item/overmind_target)
	..()
	var/atom/target = overmind_target || get_target(controller, TRUE)
	if(!target)
		return AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_FLOCK_HARVEST_TARGET, target)
	set_movement_target(target)
	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/find_harvest_target/finish_action(datum/ai_controller/controller, succeeded, obj/item/overmind_target)
	. = ..()
	controller.clear_blackboard_key(BB_PATH_TO_USE)

	if(!succeeded && overmind_target)
		controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
		controller.clear_blackboard_key(BB_FLOCK_OVERMIND_CONTROL)

/datum/ai_behavior/flock/find_harvest_target/next_behavior(datum/ai_controller/controller, success)
	if(success)
		controller.queue_behavior(/datum/ai_behavior/flock/perform_harvest)

/datum/ai_behavior/flock/perform_harvest
	name = "harvesting"
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/flock/perform_harvest/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	..()
	var/mob/living/basic/flock/drone/bird = controller.pawn
	var/obj/item/target = controller.blackboard[BB_FLOCK_HARVEST_TARGET]
	if(!isturf(target?.loc))
		return AI_BEHAVIOR_FAILED

	var/datum/flockdrone_part/absorber/absorber = locate() in bird.parts
	if(!absorber.try_pickup_item(target))
		return AI_BEHAVIOR_FAILED

	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/perform_harvest/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_FLOCK_HARVEST_TARGET)


	if(!succeeded && controller.blackboard[BB_FLOCK_OVERMIND_CONTROL] && !QDELETED(controller.pawn))
		var/mob/living/basic/flock/bird = controller.pawn
		bird.say("unable to reach target provided by sentient level instruction, aborting subroutine", forced = TRUE)

	controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
	controller.clear_blackboard_key(BB_FLOCK_OVERMIND_CONTROL)
