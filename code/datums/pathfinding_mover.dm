/**
 * A generalized datum for pathfinding, and moving to a target.
 */

/datum/pathfinding_mover
	/// Can be a simplemob bot, a drone, or even a pathfinding modsuit module (currently only implemented for drones)
	VAR_PRIVATE/atom/movable/owner
	/// The target turf we are after
	VAR_PRIVATE/turf/target

	/// List of turfs through which a mod 'steps' to reach the waypoint
	VAR_PRIVATE/list/path = list()
	/// max amount of tries before resetting path to null
	var/max_tries = 10
	/// How many times have we tried to move?
	VAR_PRIVATE/tries = 0
	/// How many 2-tick delays per move (5 = 1 second)
	var/move_speed = 2
	/// A counter for move_speed via modulo
	VAR_PRIVATE/move_ticks = 0

	/// Callback invoked on failure
	var/datum/callback/on_set_path_null
	/// Callback invoked on success
	var/datum/callback/on_success

	/// The delay called as part of Move()
	VAR_PRIVATE/atom/movable/owner_move_delay = 0
	/// Do we consider movement delay? Disable for non-mobs
	var/consider_movement_delay = TRUE
	/// Requires `consider_movement_delay = TRUE`, saves the last movement delay to prevent diagonal weirdness
	VAR_PRIVATE/last_movement_delay


/datum/pathfinding_mover/New(_owner, _target)
	target = _target

	owner = _owner
	if(ismob(owner))
		var/mob/M = owner
		owner_move_delay = M.movement_delay()
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(signal_qdel))

/datum/pathfinding_mover/Destroy(force, ...)
	UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/pathfinding_mover/proc/generate_path(...)
	set_path(get_path_to(arglist(list(owner, target) + args)))
	return (length(path) > 0)

/datum/pathfinding_mover/proc/set_target(atom/new_target)
	if(!isatom(new_target))
		target = null
		return
	target = get_turf(new_target)

/datum/pathfinding_mover/proc/set_path(list/newpath)
	PRIVATE_PROC(TRUE)

	if(newpath == null)
		on_set_path_null?.Invoke() // This is seperate to prevent invoking the callback if calling from generate_path
	path = newpath ? newpath : list()
	if(!length(path)) // Because newpath could be an empty list
		STOP_PROCESSING(SSfastprocess, src)
	tries = 0

/**
 * Start moving towards our target, returns false if the path does not lead to the target
 */
/datum/pathfinding_mover/proc/start()
	if(!target || !length(path)) // Pathfinding failed or a path/destination was not set.
		set_path(null)
		return FALSE

	var/turf/last_node = get_turf(path[length(path)]) // This is the turf at the end of the path
	if(target != last_node) // The path should lead us to our given destination. If this is not true, we must stop.
		set_path(null)
		return FALSE

	START_PROCESSING(SSfastprocess, src)
	return TRUE

/**
 * Using fast process, see if we should take the next step yet
 */
/datum/pathfinding_mover/process(wait) // 2 on fast process
	move_ticks++
	if(move_speed && (move_ticks < move_speed))
		return
	if(consider_movement_delay && (last_movement_delay > (move_ticks * wait)))
		return
	move_ticks = 0

	if(tries >= max_tries)
		set_path(null)
		return // PROCESS_KILL called with set_path(null)

	if(get_turf(owner) == target) // We have arrived, no need to move again.
		on_success?.Invoke(src)
		return PROCESS_KILL

	generalized_step()

/**
 * Take our next step in our pathfinding algorithm
 */
/datum/pathfinding_mover/proc/generalized_step() // Step, increase tries if failed
	PRIVATE_PROC(TRUE)
	if(!length(path))
		return

	var/targetted_direction = get_dir(owner, path[1])

	var/delay = owner_move_delay
	if(IS_DIR_DIAGONAL(targetted_direction))
		delay *= SQRT_2

	if(!owner.Move(path[1], targetted_direction, delay))
		tries++
		return
	tries = 0
	if(consider_movement_delay)
		last_movement_delay = delay

	// Increment the path
	path.Cut(1, 2)
