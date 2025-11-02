/// Keeps the parent within the distance of its owner as naturally as possible,
/// but teleporting if necessary.
/datum/component/leash
	/// The owner of the leash. If this is qdeleted, the leash is as well.
	var/atom/movable/owner

	/// The maximum distance you can move from your owner
	var/distance

	/// The object type to create on the old turf when forcibly teleporting out
	var/force_teleport_out_effect

	/// The object type to create on the new turf when forcibly teleporting out
	var/force_teleport_in_effect

	VAR_PRIVATE
		// Pathfinding can yield, so only move us closer if this is the best one
		current_path_tick = 0
		last_completed_path_tick = 0

		performing_path_move = FALSE

/datum/component/leash/Initialize(
	atom/movable/owner,
	distance = 3,
	force_teleport_out_effect,
	force_teleport_in_effect,
)
	. = ..()

	if(!ismovable(parent))
		stack_trace("Parent must be a movable")
		return COMPONENT_INCOMPATIBLE

	if(!ismovable(owner))
		stack_trace("[owner] (owner) is not a movable")
		return COMPONENT_INCOMPATIBLE

	if(!isnum(distance))
		stack_trace("[distance] (distance) must be a number")
		return COMPONENT_INCOMPATIBLE

	if(!isnull(force_teleport_out_effect) && !ispath(force_teleport_out_effect))
		stack_trace("force_teleport_out_effect must be null or a path, not [force_teleport_out_effect]")
		return COMPONENT_INCOMPATIBLE

	if(!isnull(force_teleport_in_effect) && !ispath(force_teleport_in_effect))
		stack_trace("force_teleport_in_effect must be null or a path, not [force_teleport_in_effect]")
		return COMPONENT_INCOMPATIBLE

	src.owner = owner
	src.distance = distance
	src.force_teleport_out_effect = force_teleport_out_effect
	src.force_teleport_in_effect = force_teleport_in_effect

	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(on_owner_qdel))

	var/static/list/container_connections = list(
		COMSIG_MOVABLE_MOVED = PROC_REF(on_owner_moved),
	)

	AddComponent(/datum/component/connect_containers, owner, container_connections)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_parent_pre_move))

	check_distance()

/datum/component/leash/Destroy()
	owner = null
	return ..()

/datum/component/leash/proc/set_distance(distance)
	ASSERT(isnum(distance))
	src.distance = distance
	check_distance()

/datum/component/leash/proc/on_owner_qdel()
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	qdel(src)

/datum/component/leash/proc/on_owner_moved(atom/movable/source)
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	check_distance()

/datum/component/leash/proc/on_parent_pre_move(atom/movable/source, atom/new_location)
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	if(performing_path_move)
		return NONE

	var/turf/new_location_turf = get_turf(new_location)
	if(get_dist(new_location_turf, owner) <= distance)
		return NONE

	if(ismob(source))
		to_chat(source, "<span class='warning'>You are too far away!</span>")

	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/component/leash/proc/check_distance()
	set waitfor = FALSE
	PRIVATE_PROC(TRUE)

	if(get_dist(parent, owner) <= distance)
		return

	var/atom/movable/atom_parent = parent
	if(isnull(owner.loc))
		atom_parent.moveToNullspace() // If our parent is in nullspace I guess we gotta go there too
		return
	if(isnull(atom_parent.loc))
		force_teleport_back("in nullspace") // If we're in nullspace, get outta there
		return

	SEND_SIGNAL(parent, COMSIG_LEASH_PATH_STARTED)

	current_path_tick += 1
	var/our_path_tick = current_path_tick

	var/list/path = get_path_to(parent, owner, mintargetdist = distance)

	if(last_completed_path_tick > our_path_tick)
		return

	last_completed_path_tick = our_path_tick

	commit_path(path)

/datum/component/leash/proc/commit_path(list/turf/path)
	SHOULD_NOT_SLEEP(TRUE)
	PRIVATE_PROC(TRUE)

	performing_path_move = TRUE

	var/atom/movable/movable_parent = parent

	for(var/turf/to_move as anything in path)
		// Could be an older path, don't make us teleport back
		if(!to_move.Adjacent(parent))
			continue

		if(!movable_parent.Move(to_move))
			force_teleport_back("bad path step")
			performing_path_move = FALSE
			return

	if(get_dist(parent, owner) > distance)
		force_teleport_back("incomplete path")

	performing_path_move = FALSE

/datum/component/leash/proc/force_teleport_back(reason)
	PRIVATE_PROC(TRUE)

	var/atom/movable/movable_parent = parent

	SSblackbox.record_feedback("tally", "leash_force_teleport_back", 1, reason)

	if(force_teleport_out_effect)
		new force_teleport_out_effect(movable_parent.loc)

	movable_parent.forceMove(get_turf(owner))

	if(force_teleport_in_effect)
		new force_teleport_in_effect(movable_parent.loc)

	SEND_SIGNAL(parent, COMSIG_LEASH_FORCE_TELEPORT)

