#define ORBIT_LOCK_IN 1
#define ORBIT_FORCE_MOVE 2

/datum/component/orbiter
	can_transfer = TRUE
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// List of observers orbiting the parent
	var/list/orbiter_list
	/// Cached transforms from before the orbiter started orbiting, to be restored on stopping their orbit
	var/list/transform_cache

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
	transform_cache = list()

	begin_orbit(orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lock_in_orbit, force_move)

/datum/component/orbiter/RegisterWithParent()
	var/atom/target = parent
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/parent_move_react)
	if(!target.orbiters)
		target.orbiters = src

/datum/component/orbiter/UnregisterFromParent()
	var/atom/target = parent
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	if(target.orbiters == src)
		target.orbiters = null

/datum/component/orbiter/Destroy()
	var/atom/owner = parent
	if(owner.orbiters == src)
		owner.orbiters = null
	for(var/i in orbiter_list)
		end_orbit(i)
	orbiter_list = null
	transform_cache = null
	return ..()

/datum/component/orbiter/InheritComponent(datum/component/orbiter/new_comp, original, atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	// No transfer happening
	if(!new_comp)
		// Make sure we clean up anything that the new component might have messed up
		// In particular, the new component probably messed up our parent
		RegisterWithParent()
		begin_orbit(arglist(args.Copy(3)))
		return

	for(var/o in new_comp.orbiter_list)
		var/atom/movable/incoming_orbiter = o
		incoming_orbiter.orbiting = src

	orbiter_list += new_comp.orbiter_list
	transform_cache += new_comp.transform_cache
	new_comp.orbiter_list = list()
	new_comp.transform_cache = list()

/datum/component/orbiter/PostTransfer()
	if(!isatom(parent) || isarea(parent) || !get_turf(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/orbiter/proc/begin_orbit(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lock_in_orbit, force_move)
	if(!istype(orbiter))
		return

	var/was_refreshing = FALSE

	if(orbiter.orbiting)
		if(orbiter.orbiting == src)
			// If we're just orbiting the same thing, we need to reset the previous state
			// before we set it again (especially for transforms)
			was_refreshing = TRUE
			end_orbit(orbiter, TRUE)
		else
			// Let the original orbiter clean up as needed
			orbiter.orbiting.end_orbit(orbiter)

	orbiter_list += orbiter
	orbiter.orbiting = src

	// Save the orbiter's transform so we can restore it when they stop orbiting
	transform_cache[orbiter] = orbiter.transform

	if(lock_in_orbit)
		orbiter.orbit_params |= ORBIT_LOCK_IN
	if(force_move)
		orbiter.orbit_params |= ORBIT_FORCE_MOVE

	RegisterSignal(orbiter, COMSIG_MOVABLE_MOVED, .proc/orbiter_move_react)

	//Head first!
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
	if(force_move)
		orbiter.forceMove(target_loc)
	else
		orbiter.loc = target_loc

/**
* End the orbit and clean up our transformation.
* If this removes the last atom orbiting us, then qdel ourselves.
* If refreshing == TRUE, variables will be cleaned up as necessary, but src won't be qdeled.
*/
/datum/component/orbiter/proc/end_orbit(atom/movable/orbiter, refreshing = FALSE)
	if(!(orbiter in orbiter_list))
		return

	var/matrix/cached_transform = transform_cache[orbiter]

	orbiter.transform = cached_transform

	orbiter.orbiting = null
	orbiter.orbit_params = 0
	orbiter.stop_orbit()
	UnregisterSignal(orbiter, COMSIG_MOVABLE_MOVED)

	SEND_SIGNAL(parent, COMSIG_ATOM_ORBIT_STOP, orbiter)

	orbiter_list -= orbiter
	transform_cache -= orbiter

	if(!length(orbiter_list) && !QDELING(src) && !refreshing)
		qdel(src)

/// Called when the orbited user moves
/datum/component/orbiter/proc/parent_move_react(atom/movable/orbited, atom/old_loc, direction)

	set waitfor = FALSE // Transfer calls this directly and it doesnt care if the ghosts arent done moving

	if(orbited.loc == old_loc)
		return

	var/turf/new_turf = get_turf(orbited)
	if(!new_turf)
		qdel(src)

	var/atom/cur_loc = orbited.loc
	for(var/atom/movable/movable_orbiter in orbiter_list)
		if(QDELETED(movable_orbiter) || movable_orbiter.loc == new_turf)
			continue

		if(movable_orbiter.orbit_params & ORBIT_FORCE_MOVE)
			movable_orbiter.forceMove(cur_loc)
		else
			movable_orbiter.loc = cur_loc

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

	if(orbiter.orbiting && orbiter.orbiting == src)
		// Only end the spin animation when we're actually ending an orbit, not just changing targets
		orbiter.SpinAnimation(0, 0, parallel = FALSE)
		end_orbit(orbiter)


/////////////////////////////////////////
// Atom procs/vars

/// Who the current atom is orbiting
/atom/movable/var/datum/component/orbiter/orbiting = null
/atom/movable/var/orbit_params = 0

/// who's orbiting the current atom
/atom/var/datum/component/orbiter/orbiters = null

/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lock_in_orbit = FALSE, force_move = FALSE)
	if(!istype(A) || !get_turf(A) || A == src)
		return
	// Adding a new component every time works as our dupe type will make us just inherit the new orbiter
	return A.AddComponent(/datum/component/orbiter, src, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lock_in_orbit, force_move)

/atom/movable/proc/stop_orbit(datum/component/orbiter/orbits)
	return // We're just a simple hook

/**
 * Recursive getter method to return a list of all ghosts orbiting this atom
 *
 * This will work fine without manually passing arguments.
 */
/atom/proc/get_all_orbiters(list/processed, source = TRUE)
	var/list/output = list()
	if(!processed)
		processed = list()
	if(src in processed)
		return output

	processed += src
	// Make sure we don't shadow outer orbiters
	var/datum/component/orbiter/atom_orbiters = orbiters
	if(atom_orbiters && atom_orbiters.orbiter_list)
		for(var/atom/atom_orbiter in atom_orbiters.orbiter_list)
			if(isobserver(atom_orbiter))
				output += atom_orbiter
			output += atom_orbiter.get_all_orbiters(processed, source = FALSE)
	return output

#undef ORBIT_LOCK_IN
#undef ORBIT_FORCE_MOVE
