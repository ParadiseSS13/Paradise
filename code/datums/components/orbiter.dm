/**
 * Code to handle atoms orbiting other atoms, following them as they move.
 * The basic logic is simple. We register a signal, COMSIG_MOVABLE_MOVED onto orbited atoms.
 * 	When the orbited atom moves, any ghosts orbiting them are moved to their turf.
 * We also register a MOVED signal onto the ghosts to cancel their orbit if they move themselves.
 * Complexities come in for items within other items (such as the NAD in a box in a backpack on an assistant pretending to be the captain),
 * 	as items in containers do **not** fire COMSIG_MOVABLE_MOVED when their container moves.
 *
 * The signal logic for items in containers is as follows:
 * Assume 1 is some item (for example, the NAD) and 2 is a box.
 * When 1 is added to 2, we register the typical orbit COMSIG_MOVABLE_MOVED onto 2.
 * 	This in essence makes 2 the "leader", the atom that ghosts follow in movement.
 *  As 2 is moved around (say, dragged on the floor) ghosts will follow it.
 * We also register a new intermediate COMSIG_MOVABLE_MOVED signal onto 1 that tracks if 1 is moved.
 * 	Remember, this will only fire if 1 is moved around containers, since it's impossible for it to actually move on its own.
 * 	If 1 is moved out of 2, this signal makes 1 the new leader.
 * Lastly, we add a COMSIG_ATOM_EXITED to 2, which tracks if 1 is removed from 2.
 * 	This EXITED signal cleans up any orbiting signals on and above 2.
 * If 2 is added to another item, (say a backpack, 3)
 * 	3 becomes the new leader
 * 	2 becomes an intermediate
 * 	1 is unchanged (but still carries the orbiter datum)
 *
 *
 * You may be asking yourself: is this overengineered?
 * In part, yes. However, MOVED signals don't get fired for items in containers, so this is
 * 	really the next best way.
 * Also, is this really optimal?
 *	As much as it can be, I believe. This signal-shuffling will not happen for any item that is just moving from turf to turf,
 * 	which should apply to 95% of cases (read: ghosts orbiting mobs).
 */

#define ORBIT_LOCK_IN 		(1<<0)
#define ORBIT_FORCE_MOVE 	(1<<1)

/datum/component/orbiter
	can_transfer = TRUE
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// List of observers orbiting the parent
	var/list/orbiter_list
	/// Cached transforms from before the orbiter started orbiting, to be restored on stopping their orbit
	var/list/orbit_data

/// See atom/movable/proc/orbit for parameter definitions
/datum/component/orbiter/Initialize(atom/movable/orbiter, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lock_in_orbit = FALSE, force_move = FALSE, orbit_layer = FLY_LAYER)
	if(!istype(orbiter) || !isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE

	orbiter_list = list()
	orbit_data = list()

	begin_orbit(orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lock_in_orbit, force_move, orbit_layer)

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

/// See atom/movable/proc/orbit for parameter definitions
/datum/component/orbiter/InheritComponent(datum/component/orbiter/new_comp, original, atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lock_in_orbit, force_move, orbit_layer)
	// No transfer happening
	if(!new_comp)
		begin_orbit(arglist(args.Copy(3)))
		return

	orbiter_list += new_comp.orbiter_list
	orbit_data += new_comp.orbit_data
	new_comp.orbiter_list = list()
	new_comp.orbit_data = list()
	QDEL_NULL(new_comp)

/datum/component/orbiter/PostTransfer()
	if(!isatom(parent) || isarea(parent) || !get_turf(parent))
		return COMPONENT_INCOMPATIBLE

/// See atom/movable/proc/orbit for parameter definitions
/datum/component/orbiter/proc/begin_orbit(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lock_in_orbit, force_move, orbit_layer)
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
	RegisterSignal(orbiter, COMSIG_PARENT_QDELETING, PROC_REF(end_orbit))

	var/orbit_flags = 0
	if(lock_in_orbit)
		orbit_flags |= ORBIT_LOCK_IN
	if(force_move)
		orbit_flags |= ORBIT_FORCE_MOVE

	orbiter.orbiting_uid = parent.UID()
	store_orbit_data(orbiter, orbit_flags)

	if(!lock_in_orbit)
		RegisterSignal(orbiter, COMSIG_MOVABLE_MOVED, PROC_REF(orbiter_move_react))

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

	orbiter.layer = orbit_layer

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
		// Setting loc directly doesn't fire COMSIG_MOVABLE_MOVED, so we need to do it ourselves
		SEND_SIGNAL(orbiter, COMSIG_MOVABLE_MOVED, current_loc, target_loc, null)
	orbiter.animate_movement = SYNC_STEPS

/**
 * End the orbit and clean up our transformation.
 * If this removes the last atom orbiting us, then qdel ourselves.
 * 	Howver, if refreshing == TRUE, src will not be qdeleted if this leaves us with 0 orbiters.
 */
/datum/component/orbiter/proc/end_orbit(atom/movable/orbiter, refreshing = FALSE)
	SIGNAL_HANDLER

	if(!(orbiter in orbiter_list))
		return

	if(orbiter)
		orbiter.animate_movement = SLIDE_STEPS
		if(!QDELETED(parent))
			SEND_SIGNAL(parent, COMSIG_ATOM_ORBIT_STOP, orbiter)

		orbiter.transform = get_cached_transform(orbiter)
		orbiter.layer = get_orbiter_layer(orbiter)

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

/**
 * The actual implementation function of the move react.
 * **if you're trying to call this from a signal, call parent_move_react instead.**
 * This implementation is separate so the orbited atom's old location and new location can be passed in separately.
 */
/datum/component/orbiter/proc/handle_parent_move(atom/movable/orbited, atom/old_loc, atom/new_loc, direction)

	if(new_loc == old_loc)
		return

	var/turf/new_turf = get_turf(new_loc)
	if(!new_turf)
		// don't follow someone to nullspace
		qdel(src)

	var/atom/cur_loc = new_loc

	// If something's only moving between turfs, don't bother changing signals, just move ghosts.
	// Honestly, that should apply to 95% of orbiting cases, which should be a nice optimization.
	if(!(isturf(old_loc) && isturf(new_loc)))

		// Clear any signals that may still exist upstream of where this object used to be
		remove_signals(old_loc)
		// ...and create a new signal hierarchy upstream of where the object is now.
		// cur_loc is the current "leader" atom
		cur_loc = register_signals(orbited)

	var/orbit_params
	var/orbiter_turf
	new_turf = get_turf(cur_loc)
	for(var/atom/movable/movable_orbiter in orbiter_list)
		orbiter_turf = get_turf(movable_orbiter)
		if(QDELETED(movable_orbiter) || orbiter_turf == new_turf)
			continue

		orbit_params = get_orbit_params(movable_orbiter)

		if(orbit_params & ORBIT_FORCE_MOVE)
			movable_orbiter.forceMove(new_turf)
		else
			var/orbiter_loc = movable_orbiter.loc
			movable_orbiter.loc = new_turf
			SEND_SIGNAL(movable_orbiter, COMSIG_MOVABLE_MOVED, orbiter_loc, new_turf, null)

		if(CHECK_TICK && new_turf != get_turf(movable_orbiter))
			// We moved again during the checktick, cancel current operation
			break
/**
 * Signal handler for COMSIG_MOVABLE_MOVED. Special wrapper to handle the arguments that come from the signal.
 * If you want to call this directly, just call handle_parent_move.
 */
/datum/component/orbiter/proc/parent_move_react(atom/movable/orbited, atom/old_loc, direction)
	set waitfor = FALSE // Transfer calls this directly and it doesnt care if the ghosts arent done moving
	handle_parent_move(orbited, old_loc, orbited.loc, direction)

/**
* Called when the orbiter themselves moves.
*/
/datum/component/orbiter/proc/orbiter_move_react(atom/movable/orbiter, atom/oldloc, direction)
	SIGNAL_HANDLER	// COMSIG_MOVABLE_MOVED

	if(get_turf(orbiter) == get_turf(parent) || get_turf(orbiter) == get_turf(oldloc) || get_turf(orbiter) == oldloc || orbiter.loc == oldloc)
		return

	if(orbiter in orbiter_list)
		// Only end the spin animation when we're actually ending an orbit, not just changing targets
		orbiter.SpinAnimation(0, 0, parallel = FALSE)
		end_orbit(orbiter)

/**
 * Remove all orbit-related signals in the object hierarchy above start.
 */
/datum/component/orbiter/proc/remove_signals(atom/start)
	var/atom/cur_atom = start
	while(cur_atom && !isturf(cur_atom) && !(cur_atom in orbiter_list) && cur_atom != parent)
		UnregisterSignal(cur_atom, COMSIG_ATOM_EXITED)
		UnregisterSignal(cur_atom, COMSIG_MOVABLE_MOVED)
		cur_atom = cur_atom.loc

/**
 * Register signals up the hierarchy, adding them to each parent (and their parent, and so on) up to the turf they're on.
 * The last atom in the hierarchy (the one whose .loc is the turf) becomes the leader, the atom ghosts will follow.
 * Registers on_intermediate_move for every non-leader atom so that if they move (removing them from the hierarchy), they will be set as the new leader.
 * Also registers on_remove_child to remove signals up the hierarchy when a child gets removed.
 * start: the first atom to register signals on. If start isn't inside of anything (or if its .loc is a turf), then it will become the leader.
 * Returns the new "leader", the atom that ghosts will follow.
 */
/datum/component/orbiter/proc/register_signals(atom/start)
	if(isturf(start))
		return
	var/atom/cur_atom = start
	while(cur_atom.loc && !isturf(cur_atom.loc) && !(cur_atom.loc in orbiter_list))
		RegisterSignal(cur_atom, COMSIG_MOVABLE_MOVED, PROC_REF(on_intermediate_move), TRUE)
		RegisterSignal(cur_atom, COMSIG_ATOM_EXITED, PROC_REF(on_remove_child), TRUE)
		cur_atom = cur_atom.loc

	// Set the topmost atom (right before the turf) to be our new leader
	RegisterSignal(cur_atom, COMSIG_MOVABLE_MOVED, PROC_REF(parent_move_react), TRUE)
	RegisterSignal(cur_atom, COMSIG_ATOM_EXITED, PROC_REF(on_remove_child), TRUE)
	return cur_atom

/**
 * Callback fired when an item is removed from a tracked atom.
 * Removes all orbit-related signals up its hierarchy and moves orbiters to the current child.
 * As this will never be called by a turf, this should not conflict with parent_move_react.
 */
/datum/component/orbiter/proc/on_remove_child(atom/movable/exiting, atom/new_loc)
	SIGNAL_HANDLER  // COMSIG_ATOM_EXITED

	// ensure the child is actually connected to the orbited atom
	if(!is_in_hierarchy(exiting) || (exiting in orbiter_list))
		return
	// Remove all signals upwards of the child and re-register them as the new parent
	remove_signals(exiting)
	RegisterSignal(exiting, COMSIG_MOVABLE_MOVED, PROC_REF(parent_move_react), TRUE)
	RegisterSignal(exiting, COMSIG_ATOM_EXITED, PROC_REF(on_remove_child), TRUE)
	INVOKE_ASYNC(src, PROC_REF(handle_parent_move), exiting, exiting.loc, new_loc)

/**
 * Called when an intermediate (somewhere between the topmost and the orbited) atom moves.
 * This atom will now become the leader.
 */
/datum/component/orbiter/proc/on_intermediate_move(atom/movable/tracked, atom/old_loc)
	SIGNAL_HANDLER  // COMSIG_MOVABLE_MOVED

	// Make sure we don't trigger off an orbiter following!
	if(!is_in_hierarchy(tracked) || (tracked in orbiter_list))
		return

	remove_signals(old_loc)  // TODO this doesn't work if something's removed from hand
	RegisterSignal(tracked, COMSIG_MOVABLE_MOVED, PROC_REF(parent_move_react), TRUE)
	RegisterSignal(tracked, COMSIG_ATOM_EXITED, PROC_REF(on_remove_child), TRUE)
	INVOKE_ASYNC(src, PROC_REF(handle_parent_move), tracked, old_loc, tracked.loc)

/**
 * Returns TRUE if atom_to_find is transitively a parent of src.
 */
/datum/component/orbiter/proc/is_in_hierarchy(atom/movable/atom_to_find)
	var/atom/check = parent
	while(check)
		if(check == atom_to_find)
			return TRUE
		check = check.loc
	return FALSE

///////////////////////////////////
/// orbit data helper functions
///////////////////////////////////

/**
 * Store a collection of data for an orbiter.
 * orbiter: orbiter atom itself. The orbiter's transform and layer at this point will be captured and cached.
 * orbit_flags: bitfield consisting of flags describing the orbit.
 */
/datum/component/orbiter/proc/store_orbit_data(atom/movable/orbiter, orbit_flags)
	var/list/new_orbit_data = list(
		orbiter.transform,  // cached transform
		orbit_flags,		// params about the orbit
		orbiter.layer		// cached layer from the orbiter
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

/**
 * Get the layer the given orbiter was on before they started orbiting
 */
/datum/component/orbiter/proc/get_orbiter_layer(atom/movable/orbiter)
	if(orbiter)
		var/list/orbit_params = orbit_data[orbiter]
		if(orbit_params)
			return orbit_params[3]

///////////////////////////////////
// Atom procs/vars
///////////////////////////////////

/// UID for the atom which the current atom is orbiting
/atom/movable/var/orbiting_uid = null

/**
 * Set an atom to orbit around another one. This atom will follow the base atom's movement and rotate around it.
 *
 * orbiter: atom which will be doing the orbiting
 * radius: range to orbit at, radius of the circle formed by orbiting
 * clockwise: whether you orbit clockwise or anti clockwise
 * rotation_speed: how fast to rotate
 * rotation_segments: the resolution of the orbit circle, less = a more block circle, this can be used to produce hexagons (6 segments) triangles (3 segments), and so on, 36 is the best default.
 * pre_rotation: Chooses to rotate src 90 degress towards the orbit dir (clockwise/anticlockwise), useful for things to go "head first" like ghosts
 * lock_in_orbit: Forces src to always be on A's turf, otherwise the orbit cancels when src gets too far away (eg: ghosts)
 * force_move: If true, ghosts will be ForceMoved instead of having their .loc updated directly.
 * orbit_layer: layer that the orbiter should be on. The original layer will be restored on orbit end.
 */
/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lock_in_orbit = FALSE, force_move = FALSE, orbit_layer = FLY_LAYER)
	if(!istype(A) || !get_turf(A) || A == src)
		return
	// Adding a new component every time works as our dupe type will make us just inherit the new orbiter
	return A.AddComponent(/datum/component/orbiter, src, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lock_in_orbit, force_move, orbit_layer)

/**
 * Stop this atom from orbiting whatever it's orbiting.
 */
/atom/movable/proc/stop_orbit()
	var/atom/orbited = locateUID(orbiting_uid)
	if(!orbited)
		return
	var/datum/component/orbiter/C = orbited.GetComponent(/datum/component/orbiter)
	if(!C)
		return
	C.end_orbit(src)

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
 * Remove an orbiter from the atom it's orbiting.
 */
/atom/proc/remove_orbiter(atom/movable/orbiter)
	var/datum/component/orbiter/C = GetComponent(/datum/component/orbiter)
	if(C && C.orbiter_list && (orbiter in C.orbiter_list))
		C.end_orbit(orbiter)

/**
 * Recursive getter method to return a list of all ghosts transitively orbiting this atom.
 * This will find orbiters either directly orbiting the followed atom, or any orbiters orbiting them (and so on).
 *
 * This shouldn't be passed arugments.
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
			output |= atom_orbiter
		output += atom_orbiter.get_orbiters_recursive(processed, source = FALSE)
	return output

/**
 * Check every object in the hierarchy above ourselves for orbiters, and return the full list of them.
 * If an object is being held in a backpack, returns orbiters of the backpack, the person
 * If recursive == TRUE, this will also check recursively through any ghosts seen to make sure we find *everything* upstream
 */
/atom/proc/get_orbiters_up_hierarchy(list/processed, source = TRUE, recursive = FALSE)
	var/list/output = list()
	if(!processed)
		processed = list()
	if(src in processed || isturf(src))
		return output

	processed += src
	for(var/atom/movable/atom_orbiter in get_orbiters())
		if(isobserver(atom_orbiter))
			if(recursive)
				output += atom_orbiter.get_orbiters_recursive()
			output += atom_orbiter

	if(loc)
		output += loc.get_orbiters_up_hierarchy(processed, source = FALSE)

	return output

#undef ORBIT_LOCK_IN
#undef ORBIT_FORCE_MOVE
