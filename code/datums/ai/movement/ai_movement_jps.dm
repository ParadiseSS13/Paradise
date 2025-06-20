/**
 * This movement datum represents smart-pathing
 */
/datum/ai_movement/jps
	max_pathing_attempts = 20
	var/maximum_length = AI_MAX_PATH_LENGTH
	/// how we deal with diagonal movement, whether we try to avoid them or follow through with them
	var/diagonal_flags = DIAGONAL_REMOVE_CLUNKY

/datum/ai_movement/jps/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/delay = controller.movement_delay

	var/datum/move_loop/has_target/jps/loop = GLOB.move_manager.jps_move(moving,
		current_movement_target,
		delay,
		repath_delay = 0.5 SECONDS,
		// TODO: "simulated_only" refers to only considering atmos-simulated tiles in pathfinding.
		// At some point we need to make it easy to tell, here, if a given atom controlled
		// by an AI should consider itself "spaceproof" enough to traverse turfs
		// without air, but should be definintely keyed to every mob's own survival
		// requirements.
		simulated_only = FALSE,
		max_path_length = maximum_length,
		minimum_distance = controller.get_minimum_distance(),
		access = controller.get_access(),
		subsystem = SSai_movement,
		diagonal_handling = diagonal_flags,
		extra_info = controller,
	)

	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_JPS_REPATH, PROC_REF(repath_incoming))

	return loop

/datum/ai_movement/jps/proc/repath_incoming(datum/move_loop/has_target/jps/source)
	SIGNAL_HANDLER // COMSIG_MOVELOOP_JPS_REPATH
	var/datum/ai_controller/controller = source.extra_info

	source.access = controller.get_access()
	source.minimum_distance = controller.get_minimum_distance()
