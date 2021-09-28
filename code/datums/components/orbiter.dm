/atom/datum/component/orbiter/orbiters
/datum/component/orbiter
	can_transfer = TRUE
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/list/orbiter_list

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

	begin_orbit(orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lock_in_orbit, force_move)

/datum/component/orbiter/RegisterWithParent()
	var/atom/target = parent
	target.orbiters = src

/datum/component/orbiter/UnregisterFromParent()
	var/atom/target = parent
	target.orbiters = null

/datum/component/orbiter/Destroy()
	var/atom/owner = parent
	if(owner.orbiters == src)
		owner.orbiters = null
	for(var/i in orbiter_list)
		end_orbit(i)
	orbiter_list = null
	return ..()

/datum/component/orbiter/InheritComponent(datum/component/orbiter/new_comp, original, atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	// No transfer happening
	if(!new_comp)
		begin_orbit(arglist(args.Copy(3)))
		return

	for(var/o in new_comp.orbiter_list)
		var/atom/movable/incoming_orbiter = o
		incoming_orbiter.orbiting = src

	orbiter_list += new_comp.orbiter_list
	new_comp.orbiter_list = list()

/datum/component/orbiter/PostTransfer()
	if(!isatom(parent) || isarea(parent) || !get_turf(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/orbiter/proc/begin_orbit(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lock_in_orbit, force_move)

	if(!istype(orbiter))
		return

	if(orbiter.orbiting)
		if (orbiter.orbiting == src)
			end_orbit(orbiter, TRUE)
		else
			end_orbit(orbiter)

	// Start building up the orbiter
	orbiter_list += orbiter
	orbiter.orbiting = src
	var/matrix/initial_transform = matrix(orbiter.transform)
	orbiter.cached_transform = initial_transform
	var/lastloc = orbiter.loc

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

	orbiter.SpinAnimation(rotation_speed, -1, clockwise, rotation_segments, parallel = FALSE)

	while(orbiter.orbiting && orbiter.orbiting == src && orbiter.loc)
		var/targetloc = get_turf(parent)
		if(!lock_in_orbit && orbiter.loc != lastloc && orbiter.loc != targetloc)
			break
		if(force_move)
			orbiter.forceMove(targetloc)
		else
			orbiter.loc = targetloc
		lastloc = orbiter.loc
		sleep(0.6)

	// if(orbiter.orbiting == src) //make sure we haven't started orbiting something else.
	end_orbit(orbiter)

/**
End the orbit and clean up our transformation
*/
/datum/component/orbiter/proc/end_orbit(atom/movable/orbiter, refreshing=FALSE)
	var/matrix/cached_transform = orbiter.cached_transform

	if(!(orbiter in orbiter_list))
		return

	orbiter.SpinAnimation(0, 0, parallel = FALSE)
	orbiter.transform = cached_transform

	SEND_SIGNAL(parent, COMSIG_ATOM_ORBIT_STOP, orbiter)

	// Clean up and reset the atom doing the orbiting
	orbiter_list -= orbiter
	orbiter.stop_orbit()
	orbiter.orbiting = null

	// if (!refreshing && length(orbiter_list) == 0 && !QDELING(src))
	// 	qdel(src)

///////////


//This is just so you can stop an orbit.
//orbit() can run without it (swap orbiting for A)
//but then you can never stop it and that's just silly.
/atom/movable/var/atom/orbiting = null
/atom/movable/var/cached_transform = null
/atom/var/datum/component/orbiter/orbiters = null

/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lockinorbit = FALSE, forceMove = FALSE)
	if(!istype(A) || !get_turf(A) || A == src)
		return
	// orbit_target = A
	return A.AddComponent(/datum/component/orbiter, src, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lockinorbit, forceMove)

/atom/movable/proc/stop_orbit(datum/component/orbiter/orbits)
	// orbit_target = null
	// orbits.orbiter_list -= src
	// src.orbiting = null
	return // We're just a simple hook

/atom/proc/transfer_observers_to(atom/target)
	if(!orbiters || !istype(target) || !get_turf(target) || target == src)
		return
	target.TakeComponent(orbiters)

/// Utility to get orbiters
/**
 * Recursive getter method to return a list of all ghosts orbitting this atom
 *
 * This will work fine without manually passing arguments.
 */
/atom/proc/get_all_orbiters(list/processed, source = TRUE)
	var/list/output = list()
	if (!processed)
		processed = list()
	if (src in processed)
		return output
	processed += src
	// Make sure we don't shadow outer orbiters
	var/datum/component/orbiter/atom_orbiters = orbiters
	if (orbiters)
		output += atom_orbiters.orbiter_list
		for (var/atom/atom_orbiter as anything in atom_orbiters.orbiter_list)
			output += atom_orbiter.get_all_orbiters(processed, source = FALSE)
	return output
