/datum/ai_behavior/flock/wander
	name = "wandering"
	required_distance = 0
	goap_weight = FLOCK_BEHAVIOR_WEIGHT_WANDER

/datum/ai_behavior/flock/wander/perform(delta_time, datum/ai_controller/controller, ...)
	..()
	var/turf/destination = get_destination(controller)
	if(destination)
		controller.set_move_target(destination)
		return BEHAVIOR_PERFORM_SUCCESS
	return BEHAVIOR_PERFORM_FAILURE

/datum/ai_behavior/flock/wander/next_behavior(datum/ai_controller/controller, success)
	if(success)
		controller.queue_behavior(/datum/ai_behavior/move_to_target/flock_wander)
		controller.queue_behavior(/datum/ai_behavior/frustration, BB_FLOCK_WANDER_FRUSTRATION, 3 SECONDS)

/datum/ai_behavior/flock/wander/goap_score(datum/ai_controller/controller)
	return 1

/datum/ai_behavior/flock/wander/proc/get_destination(datum/ai_controller/controller)
	var/datum/can_pass_info/info = new(controller.pawn, controller.get_access())
	var/turf/start_loc = get_turf(controller.pawn)
	var/list/options = list()

	for(var/turf/T in RANGE_TURFS(2, controller.pawn))
		if(get_dist(T, start_loc) < 2)
			continue

		if(isspaceturf(T))
			continue

		if(start_loc.LinkBlockedWithAccess(T, info))
			continue

		if(!T.can_flock_occupy(controller.pawn))
			continue

		options += T

	// In space, move towards the station!
	if(!length(options))
		var/obj/effect/landmark/observer_start/landmark = locate() in GLOB.landmarks_list
		var/target_turf = get_turf(landmark)
		return get_step_towards(get_step_towards(start_loc, target_turf), target_turf)

	var/list/access = controller.get_access()
	while(length(options))
		var/turf/T = pick_n_take(options)
		var/list/path = SSpathfinder.astar_pathfind_now(controller.pawn, T, 4, access = access, use_diagonals = FALSE)
		if(path)
			controller.clear_blackboard_key(BB_PATH_TO_USE)
			controller.set_blackboard_key(BB_PATH_TO_USE, path)
			return T

/datum/ai_behavior/move_to_target/flock_wander
	required_distance = 0

/datum/ai_behavior/move_to_target/flock_wander/setup(datum/ai_controller/controller, ...)
	. = ..()
	controller.set_blackboard_key(BB_PATH_MAX_LENGTH, 4)

/datum/ai_behavior/move_to_target/flock_wander/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_FLOCK_WANDER_FRUSTRATION)
	controller.clear_blackboard_key(BB_PATH_TO_USE)
	controller.clear_blackboard_key(BB_PATH_MAX_LENGTH)
