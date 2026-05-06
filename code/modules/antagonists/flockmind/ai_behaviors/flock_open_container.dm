/datum/ai_behavior/flock/find_closed_container
	name = "opening container"
	goap_weight = FLOCK_BEHAVIOR_WEIGHT_OPEN_CONTAINER

/datum/ai_behavior/flock/find_closed_container/goap_score(datum/ai_controller/controller)
	return score_distance(controller, get_target(controller))

/datum/ai_behavior/flock/find_closed_container/goap_precondition(datum/ai_controller/controller)
	var/mob/living/basic/flock/drone/bird = controller.pawn
	var/datum/flockdrone_part/absorber/absorber = locate() in bird.parts
	return !absorber.held_item

/datum/ai_behavior/flock/find_closed_container/proc/get_target(datum/ai_controller/controller, path_to = FALSE)
	var/mob/living/basic/flock/bird = controller.pawn

	var/list/options = list()
	for(var/obj/structure/closet/container in view(controller.target_search_radius, bird))
		if(container.opened || container.welded || container.locked)
			continue

		options += container

	return get_best_target_by_distance_score(controller, options, path_to)

/datum/ai_behavior/flock/find_closed_container/perform(delta_time, datum/ai_controller/controller, turf/overmind_target)
	..()
	var/atom/target = get_target(controller, TRUE)
	if(!target)
		return BEHAVIOR_PERFORM_FAILURE

	controller.set_blackboard_key(BB_FLOCK_CONTAINER_TARGET, target)
	controller.set_move_target(target)
	return BEHAVIOR_PERFORM_SUCCESS

/datum/ai_behavior/flock/find_closed_container/finish_action(datum/ai_controller/controller, succeeded, turf/overmind_target)
	. = ..()
	controller.clear_blackboard_key(BB_PATH_TO_USE)

/datum/ai_behavior/flock/find_closed_container/next_behavior(datum/ai_controller/controller, success)
	if(success)
		controller.queue_behavior(/datum/ai_behavior/flock/perform_open_container)

/datum/ai_behavior/flock/perform_open_container
	name = "opening container"
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/flock/perform_open_container/perform(delta_time, datum/ai_controller/controller, ...)
	..()
	var/mob/living/basic/flock/bird = controller.pawn
	var/obj/structure/closet/target = controller.blackboard[BB_FLOCK_CONTAINER_TARGET]
	if(target)
		bird.animate_interact(target, INTERACT_HELP)
		target.open(bird, TRUE)
	else
		return BEHAVIOR_PERFORM_FAILURE
	return BEHAVIOR_PERFORM_SUCCESS

/datum/ai_behavior/flock/perform_open_container/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_FLOCK_CONTAINER_TARGET)
