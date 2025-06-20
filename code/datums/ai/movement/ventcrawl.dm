/datum/ai_movement/ventcrawl
	max_pathing_attempts = 10
	update_moveloop_delay = FALSE

/datum/ai_movement/ventcrawl/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	// var/delay = controller.movement_delay / 4 // mobs typically move a lot faster in pipes, so divide by 3
	var/delay = controller.blackboard[BB_VENTCRAWL_DELAY] || 1 // mobs typically move a lot faster in pipes
	var/datum/move_loop/loop = GLOB.move_manager.ventcrawl(moving, current_movement_target, delay, skip_first = TRUE, subsystem = SSai_movement, extra_info = controller)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))

/datum/ai_movement/ventcrawl/allowed_to_move(datum/move_loop/has_target/ventcrawl/source)
	// maybe check if the tile it would move it into make it exit the ventcrawling?? Probably a good idea since it can get sabo'd
	// this check will do for now.
	if(!length(source.movement_path))
		return FALSE
	var/atom/A = source.movement_path[1]
	return !QDELETED(A)

/datum/ai_movement/ventcrawl/increment_pathing_failures(datum/ai_controller/controller)
	. = ..()
	var/obj/machinery/atmospherics/exit = controller.blackboard[BB_VENTCRAWL_EXIT]
	var/datum/pipeline/exit_pipeline = exit?.returnPipenet()
	var/obj/machinery/atmospherics/current = controller.pawn.loc
	if(current?.returnPipenet() in exit_pipeline?.get_connected_pipelines()) // they're still connected... let it try to find another route.
		return
	// they're not connected, give us another chance to find a way out.
	controller.set_blackboard_key(BB_VENTCRAWL_ENTRANCE, null)
	controller.set_blackboard_key(BB_VENTCRAWL_EXIT, null)
	controller.cancel_actions()
