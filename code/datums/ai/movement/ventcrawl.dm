/datum/ai_movement/ventcrawl
	max_pathing_attempts = 10

/datum/ai_movement/ventcrawl/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/min_dist = controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE]
	var/delay = controller.movement_delay
	var/datum/move_loop/loop = GLOB.move_manager.ventcrawl(moving, current_movement_target, min_dist, delay, subsystem = SSai_movement, extra_info = controller)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))

/datum/ai_movement/ventcrawl/allowed_to_move(datum/move_loop/has_target/ventcrawl/source)
	// maybe check if the tile it would move it into make it exit the ventcrawling?? Probably a good idea since it can get sabo'd
	// this check will do for now.
	var/atom/A = source.movement_path[1]
	return !QDELETED(A)
