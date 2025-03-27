///Component that handles drifting
///Manages a movement loop that actually does the legwork of moving someone
///Alongside dealing with the post movement input blocking required to make things look nice
/datum/component/drift
	var/atom/inertia_last_loc
	var/old_dir
	var/datum/move_loop/move/drifting_loop
	///Have we been delayed? IE: active, but not working right this second?
	var/delayed = FALSE
	var/block_inputs_until

/// Accepts three args. The direction to drift in, if the drift is instant or not, and if it's not instant, the delay on the start
/datum/component/drift/Initialize(direction, instant = FALSE, start_delay = 0)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()

	var/flags = MOVEMENT_LOOP_NO_MOMENTUM_CHANGE
	if(instant)
		flags |= MOVEMENT_LOOP_START_FAST
	var/atom/movable/movable_parent = parent
	drifting_loop = GLOB.move_manager.move(moving = parent, direction = direction, delay = movable_parent.inertia_move_delay, subsystem = SSspacedrift, priority = MOVEMENT_SPACE_PRIORITY, flags = flags)

	if(!drifting_loop) //Really want to qdel here but can't
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_START, PROC_REF(drifting_start))
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_STOP, PROC_REF(drifting_stop))
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(before_move))
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(after_move))
	RegisterSignal(drifting_loop, COMSIG_PARENT_QDELETING, PROC_REF(loop_death))
	RegisterSignal(movable_parent, COMSIG_MOVABLE_NEWTONIAN_MOVE, PROC_REF(newtonian_impulse))
	if(drifting_loop.status & MOVELOOP_STATUS_RUNNING)
		drifting_start(drifting_loop) // There's a good chance it'll autostart, gotta catch that

	var/visual_delay = movable_parent.inertia_move_delay

	// Start delay is essentially a more granular version of instant
	// Isn't used in the standard case, just for things that have odd wants
	if(!instant && start_delay)
		drifting_loop.pause_for(start_delay)
		visual_delay = start_delay

	apply_initial_visuals(visual_delay)

/datum/component/drift/Destroy()
	inertia_last_loc = null
	if(!QDELETED(drifting_loop))
		qdel(drifting_loop)
	drifting_loop = null
	var/atom/movable/movable_parent = parent
	movable_parent.inertia_moving = FALSE
	return ..()

/datum/component/drift/proc/apply_initial_visuals(visual_delay)
	// If something "somewhere" doesn't want us to apply our glidesize delays, don't
	if(SEND_SIGNAL(parent, COMSIG_MOVABLE_DRIFT_VISUAL_ATTEMPT) & DRIFT_VISUAL_FAILED)
		return

	var/atom/movable/movable_parent = parent
	movable_parent.set_glide_size(MOVEMENT_ADJUSTED_GLIDE_SIZE(visual_delay, SSspacedrift.visual_delay))
	if(ismob(parent))
		var/mob/mob_parent = parent
		//Ok this is slightly weird, but basically, we need to force the client to glide at our rate
		//Make sure moving into a space move looks like a space move essentially
		//There is an inbuilt assumption that gliding will be added as a part of a move call, but eh
		//It's ok if it's not, it's just important if it is.
		mob_parent.client?.visual_delay = MOVEMENT_ADJUSTED_GLIDE_SIZE(visual_delay, SSspacedrift.visual_delay)

/datum/component/drift/proc/newtonian_impulse(datum/source, inertia_direction)
	SIGNAL_HANDLER  // COMSIG_MOVABLE_NEWTONIAN_MOVE
	var/atom/movable/movable_parent = parent
	inertia_last_loc = movable_parent.loc
	if(drifting_loop)
		drifting_loop.direction = inertia_direction
	if(!inertia_direction)
		qdel(src)
	return COMPONENT_MOVABLE_NEWTONIAN_BLOCK

/datum/component/drift/proc/drifting_start()
	SIGNAL_HANDLER  // COMSIG_MOVELOOP_START
	var/atom/movable/movable_parent = parent
	inertia_last_loc = movable_parent.loc
	RegisterSignal(movable_parent, COMSIG_MOVABLE_MOVED, PROC_REF(handle_move))
	// If you stop pulling something mid drift, I want it to retain that momentum
	RegisterSignal(movable_parent, COMSIG_ATOM_NO_LONGER_PULLING, PROC_REF(stopped_pulling))

/datum/component/drift/proc/drifting_stop()
	SIGNAL_HANDLER  // COMSIG_MOVELOOP_STOP
	var/atom/movable/movable_parent = parent
	movable_parent.inertia_moving = FALSE
	UnregisterSignal(movable_parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_UPDATED_GLIDE_SIZE, COMSIG_ATOM_NO_LONGER_PULLING))

/datum/component/drift/proc/before_move(datum/source)
	SIGNAL_HANDLER  // COMSIG_MOVELOOP_PREPROCESS_CHECK
	var/atom/movable/movable_parent = parent
	movable_parent.inertia_moving = TRUE
	old_dir = movable_parent.dir
	delayed = FALSE

/datum/component/drift/proc/after_move(datum/source, result, visual_delay)
	SIGNAL_HANDLER  // COMSIG_MOVELOOP_POSTPROCESS
	if(result == MOVELOOP_FAILURE)
		qdel(src)
		return

	var/atom/movable/movable_parent = parent
	movable_parent.setDir(old_dir)
	movable_parent.inertia_moving = FALSE
	if(movable_parent.Process_Spacemove(drifting_loop.direction, continuous_move = TRUE))
		glide_to_halt(visual_delay)
		return

	inertia_last_loc = movable_parent.loc

/datum/component/drift/proc/loop_death(datum/source)
	SIGNAL_HANDLER  // COMSIG_PARENT_QDELETING
	drifting_loop = null
	UnregisterSignal(parent, COMSIG_MOVABLE_NEWTONIAN_MOVE) // We won't block a component from replacing us anymore

/datum/component/drift/proc/handle_move(datum/source, old_loc, movement_dir, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER  // COMSIG_MOVABLE_MOVED
	// This can happen, because signals once sent cannot be stopped
	if(QDELETED(src))
		return
	var/atom/movable/movable_parent = parent
	if(!isturf(movable_parent.loc))
		qdel(src)
		return
	// If we experience a momentum change that's not a result of changing Z levels, delay the drifting loop so we don't double-move.
	if(momentum_change && !HAS_TRAIT(movable_parent, TRAIT_CURRENTLY_Z_MOVING))
		drifting_loop.pause_for(movable_parent.inertia_move_delay)

	if(!movable_parent.inertia_moving)
		qdel(src)
		return
	if(movable_parent.Process_Spacemove(drifting_loop.direction, continuous_move = TRUE))
		qdel(src)

/// If we're pulling something and stop, we want it to continue at our rate and such
/datum/component/drift/proc/stopped_pulling(datum/source, atom/movable/was_pulling)
	SIGNAL_HANDLER  // COMSIG_ATOM_NO_LONGER_PULLING
	// This does mean it falls very slightly behind, but otherwise they'll potentially run into us
	var/next_move_in = drifting_loop.timer - world.time + world.tick_lag
	was_pulling.newtonian_move(drifting_loop.direction, start_delay = next_move_in)

/datum/component/drift/proc/glide_to_halt(glide_for)
	if(!ismob(parent))
		qdel(src)
		return

	var/mob/mob_parent = parent
	var/client/our_client = mob_parent.client
	// If we're not active, don't do the glide because it'll look dumb as fuck
	if(!our_client || delayed)
		qdel(src)
		return

	block_inputs_until = world.time + glide_for
	QDEL_IN(src, glide_for + 1)
	qdel(drifting_loop)
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(allow_final_movement))

/datum/component/drift/proc/allow_final_movement(datum/source)
	SIGNAL_HANDLER  // COMSIG_MOB_CLIENT_PRE_MOVE
	// Some things want to allow movement out of spacedrift, we should let them
	if(SEND_SIGNAL(parent, COMSIG_MOVABLE_DRIFT_BLOCK_INPUT) & DRIFT_ALLOW_INPUT)
		return
	if(world.time < block_inputs_until)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
