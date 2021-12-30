/**
 *  Current plan to get atom movement in containers working
 *  When an item being orbited is placed into a container, it moves into that container.
 *  It will then:
 *  	- register a MOVABLE_MOVED signal for the parent
 *  	- register a ATOM_EXITED signal for the parent, triggered if the child leaves.
 * 	If the parent moves:
 * 		- if the parent moves into another object:
 * 			- register another MOVABLE_MOVED for the new container
 * 			- register an ATOM_EXITED signal for the parent
 *      - if the parent simply moves
 * 			- parent_move_react should be called
 * 	If, at any point, some parent is removed from its container
 *		- Our ATOM_EXITED signal should fire for the container itself
 * 		- This signal should remove all references up the stack
 *		- Our MOVABLE_MOVED should trigger and bring the orbiters with us
 *
 *	To summarize:
 *		- MOVABLE_MOVED will deal with each object moving.
 * 			- If triggered on an object, it should move any orbiters.
 *			- If this movement involves leaving a container,
 *		- ATOM_EXITED will deal with upstream cleanup
 *			- If triggered, any upstream signals should be unregistered.
 *
 *
 */

#define ORBIT_LOCK_IN (1<<0)
#define ORBIT_FORCE_MOVE (1<<1)

/datum/component/orbiter
	can_transfer = TRUE
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// List of observers orbiting the parent
	var/list/orbiter_list
	/// Cached transforms from before the orbiter started orbiting, to be restored on stopping their orbit
	var/list/orbit_data

/**
A: atom to orbit
radius: range to orbit at, radius of the circle formed by orbiting
clockwise: whether you orbit clockwise or anti clockwise
rotation_speed: how fast to rotate
rotation_segments: the resolution of the orbit circle, less = a more block circle, this can be used to produce hexagons (6 segments) triangles (3 segments), and so on, 36 is the best default.
pre_rotation: Chooses to rotate src 90 degress towards the orbit dir (clockwise/anticlockwise), useful for things to go "head first" like ghosts
lockinorbit: Forces src to always be on A's turf, otherwise the orbit cancels when src gets too far away (eg: ghosts)
*/
/datum/component/orbiter/Initialize(atom/movable/orbiter, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lock_in_orbit = FALSE, force_move = FALSE)
	if (!istype(orbiter) || !isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE

	orbiter_list = list()
	orbit_data = list()

	begin_orbit(orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lock_in_orbit, force_move)

/datum/component/orbiter/RegisterWithParent()
	var/atom/target = parent
	register_signals(target)

/datum/component/orbiter/UnregisterFromParent()
	var/atom/target = parent
	remove_signals(target)

/datum/component/orbiter/Destroy()
	remove_signals(parent)
	for(var/i in orbiter_list)
		end_orbit(i)
	orbiter_list = null
	orbit_data = null
	return ..()

/datum/component/orbiter/InheritComponent(datum/component/orbiter/new_comp, original, atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	// No transfer happening
	if(!new_comp)
		begin_orbit(arglist(args.Copy(3)))
		return

	orbiter_list += new_comp.orbiter_list
	orbit_data += new_comp.orbit_data
	new_comp.orbiter_list = list()
	new_comp.orbit_data = list()

/datum/component/orbiter/PostTransfer()
	if(!isatom(parent) || isarea(parent) || !get_turf(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/orbiter/proc/begin_orbit(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lock_in_orbit, force_move)
	if(!istype(orbiter))
		return

	var/was_refreshing = FALSE
	var/atom/currently_orbiting = locateUID(orbiter.orbiting_uid)

	if(currently_orbiting)
		if(orbiter in orbiter_list)
			was_refreshing = TRUE
			end_orbit(orbiter, TRUE)
		else
			var/datum/component/orbiter/orbit_comp = currently_orbiting.GetComponent(/datum/component/orbiter)
			orbit_comp.end_orbit(orbiter)

	orbiter_list += orbiter

	// make sure orbits get cleaned up nicely if the parent qdels
	RegisterSignal(orbiter, COMSIG_PARENT_QDELETING, .proc/end_orbit)

	var/orbit_flags = 0
	if(lock_in_orbit)
		orbit_flags |= ORBIT_LOCK_IN
	if(force_move)
		orbit_flags |= ORBIT_FORCE_MOVE

	orbiter.orbiting_uid = parent.UID()
	store_orbit_data(orbiter, orbit_flags)

	// Head first!
	if(pre_rotation)
		var/matrix/M = matrix(orbiter.transform)
		var/pre_rot = 90
		if(!clockwise)
			pre_rot = -90
		M.Turn(pre_rot)
		orbiter.transform = M

	var/matrix/shift = matrix(orbiter.transform)
	shift.Translate(0,radius)
	orbiter.transform = shift

	SEND_SIGNAL(parent, COMSIG_ATOM_ORBIT_BEGIN, orbiter)

	// If we changed orbits, we didn't stop our rotation, and don't need to start it up again
	if(!was_refreshing)
		orbiter.SpinAnimation(rotation_speed, -1, clockwise, rotation_segments, parallel = FALSE)

	var/target_loc = get_turf(parent)
	var/current_loc = orbiter.loc
	if(force_move)
		orbiter.forceMove(target_loc)
	else
		orbiter.loc = target_loc
		SEND_SIGNAL(orbiter, COMSIG_MOVABLE_MOVED, current_loc, target_loc, null)

/**
 * End the orbit and clean up our transformation.
 * If this removes the last atom orbiting us, then qdel ourselves.
 * If refreshing == TRUE, variables will be cleaned up as necessary, but src won't be qdeled.
 */
/datum/component/orbiter/proc/end_orbit(atom/movable/orbiter, refreshing = FALSE)
	SIGNAL_HANDLER

	if(!(orbiter in orbiter_list))
		return

	if(orbiter)
		if(!QDELETED(parent))
			SEND_SIGNAL(parent, COMSIG_ATOM_ORBIT_STOP, orbiter)

		orbiter.transform = get_cached_transform(orbiter)

		orbiter.stop_orbit()
		UnregisterSignal(orbiter, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(orbiter, COMSIG_PARENT_QDELETING)

		orbiter.orbiting_uid = null

		if(!refreshing)
			orbiter.SpinAnimation(0, 0, parallel = FALSE)

	// If it's null, still remove it from the list
	orbiter_list -= orbiter
	orbit_data -= orbiter

	if(!length(orbiter_list) && !QDELING(src) && !refreshing)
		qdel(src)

/// Signal handler for 	COMSIG_MOVABLE_MOVED. Special wrapper to handle the arguments captured within.
/datum/component/orbiter/proc/parent_move_react(atom/movable/orbited, atom/old_loc, direction)
	set waitfor = FALSE // Transfer calls this directly and it doesnt care if the ghosts arent done moving
	handle_parent_move(orbited, old_loc, orbited.loc, direction)

/// The actual implementation function of the move react.
/// This implementation is separate so the orbited atom's old location and new location can be passed in separately.
/datum/component/orbiter/proc/handle_parent_move(atom/movable/orbited, atom/old_loc, atom/new_loc, direction)

	if(new_loc == old_loc)
		return

	var/turf/new_turf = get_turf(orbited)
	if(!new_turf)
		// don't follow someone to nullspace
		qdel(src)

	var/atom/cur_loc = new_loc

	// This is confusing so imagine there's the NAD (1) and a box (2)
	// When 1 is added to 2, we register the typical orbit COMSIG_MOVABLE_MOVED onto 2.
	// This in essence makes 2 the atom that ghosts "orbit" and follow in movement.
	// We also add a COMSIG_ATOM_EXITED to 2, which tracks if 1 is removed from 2.
	// When fired, this signal cleans up any signals on and above 2, and updates 1 to again be
	// what ghosts orbit.

	if(orbited in orbiter_list)
		to_chat(usr, "<span class='warning'>Orbited object somehow made its way into the hierarchy</span>")

	// If the object's location is a turf, then it's probably the top-level object.
	if(!isturf(new_loc))
		remove_signals(old_loc)
		cur_loc = register_signals(orbited)

		// Still in the hierarchy, maybe we were moved around?


		// Check down the chain to see if we've been moved out of the hierarchy
		// (are we still the parent of the object being orbited?)
		// (of course, if we're the object being orbited, we don't care!)

	var/orbit_params
	for(var/atom/movable/movable_orbiter in orbiter_list)
		if(QDELETED(movable_orbiter) || movable_orbiter.loc == new_turf)
			continue

		orbit_params = get_orbit_params(movable_orbiter)

		if(orbit_params & ORBIT_FORCE_MOVE)
			movable_orbiter.forceMove(cur_loc)
		else
			var/orbiter_loc = movable_orbiter.loc
			movable_orbiter.loc = cur_loc
			SEND_SIGNAL(movable_orbiter, COMSIG_MOVABLE_MOVED, orbiter_loc, cur_loc, null)

		if(CHECK_TICK && orbited.loc != cur_loc)
			// We moved again during the checktick, cancel current operation
			break

/**
* Called when the orbiter themselves moves
*/
/datum/component/orbiter/proc/orbiter_move_react(atom/movable/orbiter, atom/oldloc, direction)
	SIGNAL_HANDLER

	if(orbiter.loc == get_turf(parent))
		return

	if(orbiter in orbiter_list)
		// Only end the spin animation when we're actually ending an orbit, not just changing targets
		orbiter.SpinAnimation(0, 0, parallel = FALSE)
		end_orbit(orbiter)

/// Go up the hierarchy from start and unregister our orbiting signals.
/datum/component/orbiter/proc/remove_signals(atom/start)
	var/atom/cur_atom = start
	while(cur_atom && !isturf(cur_atom.loc) && !(cur_atom.loc in orbiter_list))
		UnregisterSignal(cur_atom, COMSIG_ATOM_EXITED)
		UnregisterSignal(cur_atom, COMSIG_MOVABLE_MOVED)
		cur_atom = cur_atom.loc

/// Register signals up the hierarchy.
/// If any of the atoms between the top-level one and the orbited one move,
/// we want to pass our current orbiters down the chain.
/// Returns the new "leader"
/datum/component/orbiter/proc/register_signals(atom/start)
	var/atom/cur_atom = start
	while(!isturf(cur_atom.loc) && !(cur_atom.loc in orbiter_list))
		RegisterSignal(cur_atom, COMSIG_MOVABLE_MOVED, .proc/on_intermediate_move, TRUE)
		RegisterSignal(cur_atom, COMSIG_ATOM_EXITED, .proc/on_remove_child, TRUE)
		cur_atom = cur_atom.loc

	// Set the topmost to be our new leader
	RegisterSignal(cur_atom, COMSIG_MOVABLE_MOVED, .proc/parent_move_react, TRUE)
	RegisterSignal(cur_atom, COMSIG_ATOM_EXITED, .proc/on_remove_child, TRUE)
	return cur_atom

/// Callback fired when an item is removed from a tracked atom.
/// Removes all associated signals up the chain, and applies signas onto
/datum/component/orbiter/proc/on_remove_child(atom/movable/exiting, atom/new_loc)
	SIGNAL_HANDLER  // COMSIG_ATOM_EXITED

	// ensure the child is actually connected to the orbited atom
	if(!is_in_hierarchy(exiting) || (exiting in orbiter_list))
		return
	// Remove all signals upwards of the child and re-register them as the new parent
	remove_signals(exiting)
	RegisterSignal(exiting, COMSIG_MOVABLE_MOVED, .proc/parent_move_react, TRUE)
	RegisterSignal(exiting, COMSIG_ATOM_EXITED, .proc/on_remove_child, TRUE)
	INVOKE_ASYNC(src, .proc/handle_parent_move, exiting, exiting.loc, new_loc)

/// Called when an intermediate (somewhere between the topmost and the orbited) atom moves.
/// This atom will now be the one "orbited"
/datum/component/orbiter/proc/on_intermediate_move(atom/movable/tracked, atom/old_loc)
	SIGNAL_HANDLER  // COMSIG_MOVABLE_MOVED

	// Make sure we don't trigger off an orbiter following!
	if(!is_in_hierarchy(tracked) || (tracked in orbiter_list))
		return

	remove_signals(old_loc)  // TODO this doesn't work if something's removed from hand
	register_signals(parent)  // Re-register signals from the bottom up
	INVOKE_ASYNC(src, .proc/handle_parent_move, tracked, old_loc, tracked.loc)

/// Check if atom_to_find is somewhere above src.
/datum/component/orbiter/proc/is_in_hierarchy(atom/movable/atom_to_find)
	var/atom/parent_check = atom_to_find
	while(parent_check)
		if(parent_check == parent)
			return TRUE
		parent_check = parent_check.loc
	return FALSE

/// Some helper functions to keep some sanity in using lists like this

/**
 * Store a collection of data for an orbiter.
 * orbiter: orbiter atom itself. The orbiter's transform at this point will be captured and cached.
 * orbit_flags: bitfield consisting of flags describing the orbit.
 */
/datum/component/orbiter/proc/store_orbit_data(atom/movable/orbiter, orbit_flags)
	var/list/new_orbit_data = list(
		orbiter.transform,  // cached transform
		orbit_flags			// params about the orbit
	)
	orbit_data[orbiter] = new_orbit_data
	return new_orbit_data

/**
 * Get cached transform of the given orbiter.
 */
/datum/component/orbiter/proc/get_cached_transform(atom/movable/orbiter)
	if(orbiter)
		var/list/orbit_params = orbit_data[orbiter]
		if(orbit_params)
			return orbit_params[1]

/**
 * Get the given orbiter's orbit parameters bitfield
 */
/datum/component/orbiter/proc/get_orbit_params(atom/movable/orbiter)
	if(orbiter)
		var/list/orbit_params = orbit_data[orbiter]
		if(orbit_params)
			return orbit_params[2]


/////////////////////////////////////////
// Atom procs/vars

/// Who the current atom is orbiting
/atom/movable/var/orbiting_uid = null

/**
 * A: atom to orbit
 * radius: range to orbit at, radius of the circle formed by orbiting
 * clockwise: whether you orbit clockwise or anti clockwise
 * rotation_speed: how fast to rotate
 * rotation_segments: the resolution of the orbit circle, less = a more block circle, this can be used to produce hexagons (6 segments) triangles (3 segments), and so on, 36 is the best default.
 * pre_rotation: Chooses to rotate src 90 degress towards the orbit dir (clockwise/anticlockwise), useful for things to go "head first" like ghosts
 * lockinorbit: Forces src to always be on A's turf, otherwise the orbit cancels when src gets too far away (eg: ghosts)
 */
/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lock_in_orbit = FALSE, force_move = FALSE)
	if(!istype(A) || !get_turf(A) || A == src)
		return
	// Adding a new component every time works as our dupe type will make us just inherit the new orbiter
	return A.AddComponent(/datum/component/orbiter, src, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lock_in_orbit, force_move)

/atom/movable/proc/stop_orbit(datum/component/orbiter/orbits)
	return // We're just a simple hook

/**
 * Simple helper proc to get a list of everything directly orbiting the current atom, without checking contents, or null if nothing is.
 */
/atom/proc/get_orbiters()
	var/datum/component/orbiter/C = GetComponent(/datum/component/orbiter)
	if(C && C.orbiter_list)
		return C.orbiter_list
	else
		return null

/**
 * Recursive getter method to return a list of all ghosts orbiting this atom, including any which may be orbiting other objects.
 *
 * This will work fine without manually passing arguments.
 */
/atom/proc/get_orbiters_recursive(list/processed, source = TRUE)
	var/list/output = list()
	if(!processed)
		processed = list()
	if(src in processed)
		return output

	processed += src
	// Make sure we don't shadow outer orbiters
	for(var/atom/movable/atom_orbiter in get_orbiters())
		if(isobserver(atom_orbiter))
			output += atom_orbiter
		output += atom_orbiter.get_orbiters_recursive(processed, source = FALSE)
	return output

#undef ORBIT_LOCK_IN
#undef ORBIT_FORCE_MOVE
