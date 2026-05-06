// Action sequence for laying an egg. If there are no open flock tiles nearby, the "nest" behavior will attempt to create one.
/datum/ai_behavior/flock/find_existing_nest
	name = "replicating"
	required_distance = 0
	goap_weight = FLOCK_BEHAVIOR_WEIGHT_REPLICATE

/datum/ai_behavior/flock/find_existing_nest/goap_precondition(datum/ai_controller/controller)
	var/mob/living/basic/flock/drone/bird = controller.pawn
	if(!bird.flock)
		return FALSE
	return length(bird.flock.drones) < FLOCK_DRONE_LIMIT && bird.substrate.has_points(FLOCK_SUBSTRATE_COST_CONVERT + bird.flock.get_egg_elligibility_cost())

/datum/ai_behavior/flock/find_existing_nest/goap_score(datum/ai_controller/controller)
	return score_distance(controller, get_target(controller))

/datum/ai_behavior/flock/find_existing_nest/proc/get_target(datum/ai_controller/controller, path_to = FALSE)
	var/list/options = list()
	for(var/turf/simulated/floor/flock/T in view(controller.target_search_radius, controller.pawn))
		if(!T.is_blocked_turf(source_atom = controller.pawn) && !locate(/obj/structure/flock/egg, T))
			options += T

	return get_best_target_by_distance_score(controller, options, path_to)

/datum/ai_behavior/flock/find_existing_nest/perform(delta_time, datum/ai_controller/controller)
	..()
	var/turf/target = get_target(controller, TRUE)
	if(!target)
		return BEHAVIOR_PERFORM_FAILURE

	controller.set_blackboard_key(BB_FLOCK_REPLICATE_TARGET, target)
	controller.set_move_target(target)

	return BEHAVIOR_PERFORM_SUCCESS

/datum/ai_behavior/flock/find_existing_nest/finish_action(datum/ai_controller/controller, succeeded, turf/overmind_target)
	. = ..()
	controller.clear_blackboard_key(BB_PATH_TO_USE)

/datum/ai_behavior/flock/next_behavior(datum/ai_controller/controller, success)
	if(success)
		controller.queue_behavior(/datum/ai_behavior/flock/perform_replicate)

/datum/ai_behavior/flock/perform_replicate
	name = "replicating"
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 0

/datum/ai_behavior/flock/perform_replicate/perform(delta_time, datum/ai_controller/controller, ...)
	. = ..()
	var/mob/living/basic/flock/bird = controller.pawn
	var/turf/target = controller.blackboard[BB_FLOCK_REPLICATE_TARGET]
	if(target)
		controller.clear_blackboard_key(BB_FLOCK_REPLICATE_TARGET)
		var/datum/action/cooldown/flock/nest/nest_action = locate() in bird.actions
		spawn(-1)
			nest_action.Trigger(target = target)

	if(DOING_INTERACTION(bird, "flock_lay_egg"))
		return BEHAVIOR_PERFORM_COOLDOWN

	return BEHAVIOR_PERFORM_SUCCESS

/datum/ai_behavior/flock/perform_nest/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_FLOCK_REPLICATE_TARGET)
