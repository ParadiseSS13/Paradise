/// This datum is an abstract class that can be overriden for different types of movement.
/datum/ai_movement
	/// Assoc list ist of controllers that are currently moving as key, and what they are moving to as value.
	var/list/moving_controllers = list()
	/// How many times a given controller can fail on their route before they just give up.
	var/max_pathing_attempts
	/// Should this movement update the delay when a moveloop is about to happen?
	var/update_moveloop_delay = TRUE

/// Override this to setup the moveloop you want to use.
/datum/ai_movement/proc/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	SHOULD_CALL_PARENT(TRUE)
	controller.consecutive_pathing_attempts = 0
	controller.set_blackboard_key(BB_CURRENT_MIN_MOVE_DISTANCE, min_distance)
	moving_controllers[controller] = current_movement_target

/datum/ai_movement/proc/stop_moving_towards(datum/ai_controller/controller)
	controller.consecutive_pathing_attempts = 0
	moving_controllers -= controller
	// We got deleted as we finished an action
	if(!QDELETED(controller.pawn))
		GLOB.move_manager.stop_looping(controller.pawn, SSai_movement)

/datum/ai_movement/proc/increment_pathing_failures(datum/ai_controller/controller)
	controller.consecutive_pathing_attempts++
	if(controller.consecutive_pathing_attempts >= max_pathing_attempts)
		controller.cancel_actions()

/// Returns TRUE if the movement should be allowed, FALSE otherwise.
/datum/ai_movement/proc/allowed_to_move(datum/move_loop/source)
	SHOULD_BE_PURE(TRUE)

	var/atom/movable/pawn = source.moving
	var/datum/ai_controller/controller = source.extra_info

	var/can_move = TRUE
	if((controller.ai_traits & AI_FLAG_STOP_MOVING_WHEN_PULLED) && pawn.pulledby)
		can_move = FALSE

	if(!isturf(pawn.loc)) // No moving if not on a turf
		can_move = FALSE

	if(isliving(pawn))
		var/mob/living/pawn_mob = pawn
		if(!(pawn_mob.mobility_flags & MOBILITY_MOVE))
			can_move = FALSE

	return can_move

/// Anything to do before moving; any checks if the pawn should be able to
/// move should be placed in allowed_to_move() and called by this proc.
/datum/ai_movement/proc/pre_move(datum/move_loop/source)
	SIGNAL_HANDLER // COMSIG_MOVELOOP_PREPROCESS_CHECK
	SHOULD_NOT_OVERRIDE(TRUE)

	var/datum/ai_controller/controller = source.extra_info

	// Check if this controller can actually run, so we don't chase people with corpses
	if(!controller.able_to_run)
		controller.cancel_actions()
		qdel(source) // stop moving
		return MOVELOOP_SKIP_STEP

	if(update_moveloop_delay)
		source.delay = controller.movement_delay

	if(allowed_to_move(source))
		return NONE
	increment_pathing_failures(controller)
	return MOVELOOP_SKIP_STEP

/// Anything to do post-movement.
/datum/ai_movement/proc/post_move(datum/move_loop/source, succeeded)
	SIGNAL_HANDLER // COMSIG_MOVELOOP_POSTPROCESS
	if(succeeded != FALSE)
		return
	var/datum/ai_controller/controller = source.extra_info
	increment_pathing_failures(controller)
