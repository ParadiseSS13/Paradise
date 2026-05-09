/datum/ai_behavior/flock/find_storage_item
	name = "rummaging"
	goap_weight = FLOCK_BEHAVIOR_WEIGHT_RUMMAGE

/datum/ai_behavior/flock/find_storage_item/goap_score(datum/ai_controller/controller)
	return score_distance(controller, get_target(controller))

/datum/ai_behavior/flock/find_storage_item/goap_precondition(datum/ai_controller/controller)
	var/mob/living/basic/flock/drone/bird = controller.pawn
	var/datum/flockdrone_part/absorber/absorber = locate() in bird.parts
	return !absorber.held_item

/datum/ai_behavior/flock/find_storage_item/proc/get_target(datum/ai_controller/controller, path_to = FALSE)
	var/mob/living/basic/flock/bird = controller.pawn

	var/list/options = list()
	for(var/obj/item/storage/item in view(controller.target_search_radius, bird))
		if(!length(item.contents))
			continue

		options += item

	return get_best_target_by_distance_score(controller, options, path_to)

/datum/ai_behavior/flock/find_storage_item/perform(seconds_per_tick, datum/ai_controller/controller, turf/overmind_target)
	..()
	var/atom/target = get_target(controller, TRUE)
	if(!target)
		return AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_FLOCK_RUMMAGE_TARGET, target)
	set_movement_target(controller, target)
	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/find_storage_item/finish_action(datum/ai_controller/controller, succeeded, turf/overmind_target)
	. = ..()
	controller.clear_blackboard_key(BB_PATH_TO_USE)

/datum/ai_behavior/flock/find_storage_item/next_behavior(datum/ai_controller/controller, success)
	if(success)
		controller.queue_behavior(/datum/ai_behavior/flock/perform_rummage)

/datum/ai_behavior/flock/perform_rummage
	name = "rummaging"
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/flock/perform_rummage/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	..()
	var/mob/living/basic/flock/bird = controller.pawn
	var/obj/item/target = controller.blackboard[BB_FLOCK_RUMMAGE_TARGET]
	if(!target)
		return AI_BEHAVIOR_FAILED

	if(DOING_INTERACTION(bird, "flock_rummage"))
		return AI_BEHAVIOR_DELAY

	rummage_till_empty(controller, bird, target)
	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/flock/perform_rummage/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_FLOCK_RUMMAGE_TARGET)

/datum/ai_behavior/flock/perform_rummage/proc/rummage_till_empty(datum/ai_controller/controller, mob/living/basic/flock/bird, obj/item/target)
	set waitfor = FALSE

	while(target == controller.blackboard[BB_FLOCK_RUMMAGE_TARGET] && length(target.contents))
		if(!do_after(bird, 1 SECONDS, target = target, interaction_key = "flock_rummage"))
			return

		if(target != controller.blackboard[BB_FLOCK_RUMMAGE_TARGET] || !length(target.contents))
			return

		var/obj/item/contained_item = target.contents[1]
		contained_item.forceMove(bird.drop_location())

