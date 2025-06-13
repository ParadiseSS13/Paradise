/datum/component/tether
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/atom/movable/tethered_to
	// Durability decreases with every on_range. Snaps when durability = 0.
	var/durability = INFINITY
	var/max_range = 2
	var/tether_icon_state

	var/datum/movement_detector/tether_tracker
	var/datum/movement_detector/parent_tracker
	var/datum/beam/beam
	var/atom/movable/tether_visual_target
	var/tether_name
	var/last_movement = 0

/datum/component/tether/Initialize(tethered_atom_movable, range = 2, durability = INFINITY, tether_icon_state = "tether", tether_name = "tether")
	. = ..()
	if(!isatom(parent) || !ismovable(tethered_atom_movable))
		return COMPONENT_INCOMPATIBLE

	src.tethered_to = tethered_atom_movable
	src.max_range = range
	src.durability = durability // movement is bugged right now. Durability wears out 3 times faster than expected. 1 durability should last 1 tile.
	src.tether_icon_state = tether_icon_state
	src.tether_name = tether_name

	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_movement))
	RegisterSignal(tethered_atom_movable, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_tethered_movement))
	RegisterSignal(tethered_atom_movable, COMSIG_ATOM_ATTACK_HAND, PROC_REF(can_equip))
	parent_tracker = new /datum/movement_detector(parent, CALLBACK(src, PROC_REF(parent_check_bounds)))
	tether_tracker = new /datum/movement_detector(tethered_atom_movable, CALLBACK(src, PROC_REF(check_bounds)))
	parent_tracker.fix_signal()
	make_beam(tether_tracker.fix_signal() || tethered_to)

	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(terminate))
	RegisterSignal(tethered_atom_movable, list(COMSIG_PARENT_QDELETING, COMSIG_TETHER_STOP), PROC_REF(terminate))

	if(get_dist(get_turf(parent), get_turf(tethered_to)) <= max_range)
		return
	tether_move_towards_parent()

/datum/component/tether/Destroy(force, silent)
	QDEL_NULL(tether_tracker)
	QDEL_NULL(parent_tracker)
	if(!QDELETED(beam))
		qdel(beam)
		beam = null
	SEND_SIGNAL(tethered_to, COMSIG_TETHER_DESTROYED)
	tether_visual_target = null
	tethered_to = null
	return ..()

/datum/component/tether/proc/make_beam(target)
	if(target == tether_visual_target)
		return
	tether_visual_target = target
	if(beam)
		UnregisterSignal(beam, COMSIG_PARENT_QDELETING)
		QDEL_NULL(beam)
	var/atom/atom = parent
	beam = atom.Beam(tether_visual_target, icon_state = tether_icon_state, time = INFINITY, use_get_turf = TRUE)
	RegisterSignal(beam, COMSIG_PARENT_QDELETING, PROC_REF(terminate))

// /datum/component/tether/proc/on_movement(atom/source, atom/oldloc, dir, forced)
/datum/component/tether/proc/on_movement(atom/movable/source, newloc)
	// check if the item is in range. If not, try to move it towards the parent.
	if(get_dist(get_turf(tethered_to), newloc) <= max_range)
		return
	if(source.pulledby == tethered_to.loc)
		return
	if(tether_move_towards_parent(newloc))
		return
	if(get_dir(parent, newloc) & get_dir(parent, tethered_to))
		return
	var/atom/atom = parent
	atom?.setDir(get_dir(parent, newloc))
	to_chat(atom, "<span class='warning'>You can't move in that direction with the [tethered_to] tethered to you!</span>")
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/component/tether/proc/pre_tethered_movement(atom/movable/source, newloc)
	// check if the item would be in range at its new tile. If not, return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	if(get_dist(get_turf(parent), newloc) <= max_range)
		return
	if(get_dir(tethered_to, newloc) & get_dir(tethered_to, parent))
		return
	durability_cost()
	var/atom/atom = parent
	atom?.setDir(get_dir(parent, newloc))
	to_chat(atom, "<span class='warning'>You can't move in that direction with the [tethered_to] tethered to you!</span>")
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/component/tether/proc/can_equip(atom/source, mob/user)
	// Check to make sure we dont go into an inventory outside of our range
	if(get_dist(get_turf(parent), get_turf(user)) > max_range)
		to_chat(user, "<span class='warning'>You try to pick up [tethered_to], you can't pull it's [tether_name] any farther!</span>")
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/tether/proc/parent_check_bounds(atom/movable/source, atom/mover, atom/old_loc, direction)
	// check to see if the parent has moved out of range (while inside another objects contents). If it has, pull the tether towards the parent.
	if(get_dist(get_turf(parent), get_turf(tethered_to)) <= max_range)
		return
	if(source.pulledby == tethered_to.loc)
		return
	tether_move_towards_parent()

/datum/component/tether/proc/check_bounds(atom/movable/source, atom/mover, atom/old_loc, direction)
	// check to see if the tethered object is out of range.
	// If it is, make it be dropped from a mob's hand, or open a locker its in.
	make_beam(mover)
	if(get_dist(get_turf(parent), get_turf(tethered_to)) <= max_range)
		return
	if(ismovable(mover))
		var/atom/movable/a_mover = mover
		if(a_mover.pulledby == parent || a_mover.pulling == parent)
			return
	tether_move_towards_parent()

/datum/component/tether/proc/tether_move_towards_parent(parent_newloc)
	if(QDELETED(tethered_to) || !istype(tethered_to) || last_movement == world.time)
		return TRUE
	var/atom/current_loc = tethered_to.loc
	var/i = 0
	while(!isturf(current_loc) && current_loc != null && current_loc != current_loc.loc)
		if(i++ > 100)
			return TRUE
		if(ismob(current_loc))
			var/mob/M = current_loc
			M.drop_item_to_ground(tethered_to)
			current_loc = tethered_to.loc
			break
		if(istype(current_loc, /obj/item/storage))
			var/obj/item/storage/S = current_loc
			S.remove_from_storage(tethered_to, get_turf(tethered_to))
			current_loc = tethered_to.loc
			break
		if(istype(current_loc, /obj/structure/closet))
			var/obj/structure/closet/C = current_loc
			if(C.can_open())
				C.open()
				current_loc = tethered_to.loc
				break
		if(ismovable(current_loc))
			var/atom/movable/AM = current_loc
			if(AM.anchored)
				return FALSE
			if(isturf(AM.loc))
				last_movement = world.time
				durability_cost()
				step_towards(AM, get_turf(parent)) // holy shitcode
				return get_dist(get_turf(parent_newloc || parent), get_turf(tethered_to)) <= max_range
		current_loc = current_loc.loc
	if(get_dist(get_turf(parent), get_turf(tethered_to)) <= max_range)
		return TRUE
	last_movement = world.time
	durability_cost()
	if(!step_towards(tethered_to, get_turf(parent))) // shitcode
		return durability_cost(2) // use 3 total durability
	return TRUE

/datum/component/tether/proc/terminate(source, force)
	if(QDELETED(src))
		return
	qdel(src)

/datum/component/tether/proc/durability_cost(cost = 1)
	if(durability == INFINITY)
		return
	durability -= cost
	if(durability <= 0 && !QDELETED(tethered_to))
		tethered_to.visible_message("<span class='warning'>[tethered_to]'s [tether_name] wears out and snaps back!</span>")
		terminate()
		return TRUE // it breaks, let the parent move outside of the range again
	return FALSE
