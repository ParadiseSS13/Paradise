/datum/ai_behavior/flock/find_conversion_target
	name = "building"
	goap_weight

/datum/ai_behavior/flock/find_conversion_target/setup(datum/ai_controller/controller, turf/overmind_target)
	. = ..()
	if(overmind_target)
		var/mob/living/basic/flock/drone/bird = controller.pawn
		if(goap_is_valid_target(controller, overmind_target))
			controller.set_blackboard_key(BB_FLOCK_OVERMIND_CONTROL, TRUE)
			controller.set_blackboard_key(BB_PATH_MAX_LENGTH, 200)
			bird.say("instruction confirmed: convert object to substrate", forced = TRUE)
		else
			bird.say("invalid conversion target provided by sentient-level instruction", forced = TRUE)
			return FALSE

/datum/ai_behavior/flock/find_conversion_target/goap_precondition(datum/ai_controller/controller)
	var/mob/living/basic/flock/bird = controller.pawn
	return bird.substrate.has_points(FLOCK_SUBSTRATE_COST_CONVERT)

/datum/ai_behavior/flock/find_conversion_target/score_distance(datum/ai_controller/controller, atom/target)
	. = ..()
	var/mob/living/basic/flock/bird = controller.pawn
	if(bird.flock?.marked_for_conversion[target])
	/*
	* because the result of scoring is based on max distance,
	* the score of any given tile is -100 to 0, with 0 being best.
	* Adding 200 basically allows a tile at twice the max distance to be considered.
	*/
		. += 200

/datum/ai_behavior/flock/find_conversion_target/goap_get_potential_targets(datum/ai_controller/controller)
	var/mob/living/basic/flock/bird = controller.pawn
	var/datum/flock/bird_flock = bird.flock

	var/list/options = view(controller.target_search_radius, bird)
	var/list/priority_turfs = bird_flock?.get_priority_turfs()
	if(length(priority_turfs))
		options += priority_turfs

	for(var/turf/T as turf in view(controller.target_search_radius, bird))
		options += T

	return options

/datum/ai_behavior/flock/find_conversion_target/goap_is_valid_target(datum/ai_controller/controller, atom/target)
	var/turf/T = target
	if(!isturf(T))
		return FALSE

	if(!T.can_flock_convert())
		return FALSE

	if(isflockturf(T))
		return FALSE

	var/mob/living/basic/flock/bird = controller.pawn
	if(isnull(bird.flock))
		return TRUE

	if(bird.flock.claimed_floors[T] || bird.flock.claimed_walls[T])
		return FALSE

	return bird.flock.is_turf_free(T)

/datum/ai_behavior/flock/find_conversion_target/perform(seconds_per_tick, datum/ai_controller/controller, turf/overmind_target)
	..()
	var/turf/target = overmind_target || goap_get_ideal_target(controller, TRUE)
	if(!target)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_FLOCK_CONVERT_TARGET, target)

	var/mob/living/basic/flock/bird = controller.pawn
	if(bird.flock)
		bird.flock.reserve_turf(bird, target)

	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/find_conversion_target/finish_action(datum/ai_controller/controller, succeeded, turf/overmind_target)
	. = ..()
	controller.clear_blackboard_key(BB_PATH_TO_USE)
	if(!succeeded && overmind_target)
		controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
		controller.clear_blackboard_key(BB_FLOCK_OVERMIND_CONTROL)

/datum/ai_behavior/flock/find_conversion_target/next_behavior(datum/ai_controller/controller, success)
	if(success)
		controller.queue_behavior(/datum/ai_behavior/flock/perform_conversion)

/datum/ai_behavior/flock/perform_conversion
	name = "building"
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/flock/perform_conversion/setup(datum/ai_controller/controller, ...)
	var/turf/target_turf = controller.blackboard[BB_FLOCK_CONVERT_TARGET]
	set_movement_target(controller, target_turf)
	return ..()

/datum/ai_behavior/flock/perform_conversion/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	..()
	var/mob/living/basic/flock/bird = controller.pawn
	var/turf/target = controller.blackboard[BB_FLOCK_CONVERT_TARGET]
	if(target)
		controller.clear_blackboard_key(BB_FLOCK_CONVERT_TARGET)
		var/datum/action/cooldown/flock/convert/convert_action = locate() in bird.actions
		spawn(-1)
			convert_action.Trigger(target = target)

	if(DOING_INTERACTION(bird, "flock_convert"))
		return AI_BEHAVIOR_DELAY

	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/perform_conversion/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	var/mob/living/basic/flock/drone/bird = controller.pawn
	bird.flock?.free_turf(bird)

	if(!succeeded && controller.blackboard[BB_FLOCK_OVERMIND_CONTROL] && !QDELETED(controller.pawn))
		bird.say("unable to reach target provided by sentient level instruction, aborting subroutine", forced = TRUE)

	controller.clear_blackboard_key(BB_FLOCK_CONVERT_TARGET)
	controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
	controller.clear_blackboard_key(BB_FLOCK_OVERMIND_CONTROL)


//
// Subtype for creating a nest. Effectively a higher priority convert that only happens when the bird can lay an egg.
//

/datum/ai_behavior/flock/find_conversion_target/nest
	name = "nesting"
	goap_weight = FLOCK_BEHAVIOR_WEIGHT_NEST
	required_distance = 0

/datum/ai_behavior/flock/find_conversion_target/nest/goap_precondition(datum/ai_controller/controller)
	var/mob/living/basic/flock/bird = controller.pawn
	if(!bird.flock)
		return FALSE

	if(length(bird.flock.drones) > FLOCK_DRONE_LIMIT)
		return FALSE

	return bird.substrate.has_points(FLOCK_SUBSTRATE_COST_CONVERT + bird.flock.current_egg_cost)

/datum/ai_behavior/flock/find_conversion_target/nest/goap_is_valid_target(datum/ai_controller/controller, atom/target)
	var/turf/T = target
	return ..() && !T.is_blocked_turf(exclude_mobs = TRUE) && !locate(/obj/structure/flock/egg, T)

/datum/ai_behavior/flock/perform_conversion/nest
	name = "nesting"
	required_distance = 0

/datum/ai_behavior/flock/perform_conversion/nest/next_behavior(datum/ai_controller/controller, success)
	. = ..()
	if(success)
		controller.queue_behavior(/datum/ai_behavior/flock/find_existing_nest)
