/**
 * This movement datum represents smart-pathing
 */
/datum/ai_movement/astar
	max_pathing_attempts = 20

	/// If FALSE, diagonals will be split into 2 cardinal moves.
	var/use_diagonals = TRUE

/datum/ai_movement/astar/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/delay = controller.movement_delay
	var/max_path_length_override = controller.blackboard[BB_PATH_MAX_LENGTH]

	var/datum/move_loop/has_target/astar/loop = GLOB.move_manager.astar_move(
		moving,
		current_movement_target,
		delay,
		repath_delay = 0.5 SECONDS,
		max_path_length = isnull(max_path_length_override) ? AI_MAX_PATH_LENGTH : max_path_length_override,
		minimum_distance = controller.get_minimum_distance(),
		access = controller.get_access(),
		simulated_only = !HAS_TRAIT(controller.pawn, TRAIT_FLYING),
		subsystem = SSai_movement,
		extra_info = controller,
		initial_path = controller.blackboard[BB_PATH_TO_USE],
		use_diagonals = use_diagonals,
	)

	controller.clear_blackboard_key(BB_PATH_TO_USE)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_ASTAR_REPATH, PROC_REF(repath_incoming))

/datum/ai_movement/astar/proc/repath_incoming(datum/move_loop/has_target/astar/source)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = source.extra_info

	source.access = controller.get_access()
	source.minimum_distance = controller.get_minimum_distance()

