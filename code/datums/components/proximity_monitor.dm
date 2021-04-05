/**
 * # Basic Proximity Monitor
 *
 * Attaching this component to an atom means that the atom will be able to detect mobs or objects moving within a specified radius of it.
 *
 * The component creates several [/obj/effect/abstract/proximity_checker] objects, which follow the parent (or host) atom around, always making sure it's at the center.
 * When something crosses one of these proximiy checkers, the `hasprox_receiver` will have the `HasProximity()` proc called on it, with the crossing mob/obj as the argument.
 */
/datum/component/proximity_monitor
	can_transfer = TRUE
	var/name = "Proximity detection field"
	/// The primary atom the component is attached to and that will be receiving `HasProximity()` calls. Usually the `parent`.
	var/atom/hasprox_receiver
	/**
	 * The atom that the component is listening to for movement. Null by default, but this can change.
	 * For example, if the receiver gets put into a humans's pocket, the host will become the human.
	 */
	var/atom/host
	/// The radius of the field, in tiles.
	var/radius
	/// A list of currently created [/obj/effect/abstract/proximity_checker] in use with this component.
	var/list/proximity_checkers
	/// The type of checker object that should be used for the main field.
	var/field_checker_type = /obj/effect/abstract/proximity_checker
	/// Should the parent always detect proximity and update the field on movement, even if it's not on a turf?
	var/always_active

/datum/component/proximity_monitor/Initialize(_radius = 1, _always_active = FALSE)
	. = ..()
	if(!ismovable(parent) && !isturf(parent)) // No areas or datums allowed.
		return COMPONENT_INCOMPATIBLE
	ASSERT(_radius >= 1)
	hasprox_receiver = parent
	radius = _radius
	always_active = _always_active
	create_prox_checkers()

	if(isturf(hasprox_receiver.loc))
		return
	if(!always_active)
		toggle_checkers(FALSE)
		return
	// We only want a host to track if we're `always_active`.
	host = get_atom_on_turf(host)

/datum/component/proximity_monitor/Destroy(force, silent)
	hasprox_receiver = null
	host = null
	QDEL_LIST(proximity_checkers)
	return ..()

/datum/component/proximity_monitor/RegisterWithParent()
	. = ..()
	// Override vars are set to TRUE here to allow for component transfering.
	if(ismovable(hasprox_receiver))
		RegisterSignal(hasprox_receiver, COMSIG_MOVABLE_MOVED, .proc/handle_move, TRUE)
	if(host && ismovable(host))
		RegisterSignal(host, COMSIG_MOVABLE_MOVED, .proc/handle_move, TRUE)

/datum/component/proximity_monitor/UnregisterFromParent()
	. = ..()
	if(ismovable(hasprox_receiver))
		UnregisterSignal(hasprox_receiver, COMSIG_MOVABLE_MOVED)
	if(host && ismovable(host))
		UnregisterSignal(host, COMSIG_MOVABLE_MOVED)

/datum/component/proximity_monitor/PostTransfer()
	if(!ismovable(parent) && !isturf(parent))
		return COMPONENT_INCOMPATIBLE
	host = null
	hasprox_receiver = parent
	if(!isturf(hasprox_receiver.loc))
		host = get_atom_on_turf(host)
	recenter_prox_checkers()

/**
 * Called when the `hasprox_receiver` moves. If a `host` exists, its movement will also call this proc.
 *
 * Arguments:
 * * datum/source - this will be the `parent`
 * * atom/OldLoc - the location the parent just moved from
 * * Dir - the direction the parent just moved in
 * * forced - if we were forced to move
 */
/datum/component/proximity_monitor/proc/handle_move(datum/source, atom/OldLoc, Dir, forced)
	SIGNAL_HANDLER

	if(Dir)
		move_prox_checkers(Dir)
		return // It was just a normal tile-based move, return.

	// The field is always active while the receiver is on a turf.
	if(isturf(hasprox_receiver.loc))
		toggle_checkers(TRUE)
		if(host && ismovable(host))
			UnregisterSignal(host, COMSIG_MOVABLE_MOVED)
			host = null
	// The receiver moved inside of another atom, set the host to that atom so we can track its movement.
	else if(always_active)
		toggle_checkers(TRUE)
		host = get_atom_on_turf(hasprox_receiver)
		if(ismovable(host) && host != OldLoc)
			RegisterSignal(host, COMSIG_MOVABLE_MOVED, .proc/handle_move)
	// Deactivate the field, leave it where it is, and stop listening for movement.
	else
		toggle_checkers(FALSE)

	recenter_prox_checkers()

/**
 * Relays basic directional movement from the `hasprox_receiver` or `host`, to all objects in the `proximity_checkers` list.
 *
 * Arguments:
 * * move_dir - the direction the checkers should move in
 */
/datum/component/proximity_monitor/proc/move_prox_checkers(move_dir)
	for(var/checker in proximity_checkers)
		var/obj/effect/abstract/proximity_checker/P = checker
		P.loc = get_step(P, move_dir)

/**
 * Update all of the component's proximity checker's to either become active or not active.
 *
 * Arguments:
 * * new_active - the value to be assigned to the proximity checker's `active` variable
 */
/datum/component/proximity_monitor/proc/toggle_checkers(new_active)
	for(var/checker in proximity_checkers)
		var/obj/effect/abstract/proximity_checker/P = checker
		P.active = new_active

/**
 * Specifies a new radius for the field. Creates or deletes proximity_checkers accordingly.
 *
 * This proc *can* have a high cost due to the `new`s and `qdel`s of the proximity checkers, depending on the number of calls you need to make to it.
 *
 * Arguments:
 * new_raidus - the new value that `proximity_raidus` should be set to.
 */
/datum/component/proximity_monitor/proc/set_radius(new_radius)
	ASSERT(new_radius >= 1)

	var/new_field_size = (1 + new_radius * 2) ** 2
	var/old_field_size = length(proximity_checkers)
	radius = new_radius

	// Radius is decreasing.
	if(new_field_size < old_field_size)
		for(var/i in 1 to (old_field_size - new_field_size))
			qdel(proximity_checkers[length(proximity_checkers)]) // Pop the last entry.
	// Radius is increasing.
	else
		var/turf/parent_turf = get_turf(parent)
		for(var/i in 1 to (new_field_size - old_field_size))
			create_single_prox_checker(parent_turf)
	recenter_prox_checkers()

/**
 * Creates a single proximity checker object, at the given location and of the given type. Adds it to the proximity checkers list.
 *
 * Arguments:
 * * turf/T - the turf the checker should be created on
 * * checker_type - the type of [/obj/item/abstract/proximity_checker] to create
 */
/datum/component/proximity_monitor/proc/create_single_prox_checker(turf/T, checker_type = field_checker_type)
	var/obj/effect/abstract/proximity_checker/P = new checker_type(T, parent, src)
	proximity_checkers += P
	return P

/**
 * Called in Initialize(). Generates a set of [/obj/effect/abstract/proximity_checker] objects around the parent, and registers signals to them.
 */
/datum/component/proximity_monitor/proc/create_prox_checkers()
	LAZYINITLIST(proximity_checkers)
	var/turf/parent_turf = get_turf(parent)
	for(var/T in RANGE_TURFS(radius, parent_turf))
		create_single_prox_checker(T)

/**
 * Re-centers all of the `proximity_checker`s around the parent's current location.
 */
/datum/component/proximity_monitor/proc/recenter_prox_checkers()
	var/turf/parent_turf = get_turf(parent)
	var/index = 1
	for(var/T in RANGE_TURFS(radius, parent_turf))
		var/obj/checker = proximity_checkers[index++]
		checker.loc = T


/**
 * # Advanced Proximity Monitor
 *
 * This component functions similar to the basic version, however it has some extra features:
 *
 * First of all, if the field radius is more than 1 tile, you have the option to make a distinction between inner proximity checkers, versus ones along the edge.
 * You can specifiy which type of [/obj/effect/abstract/proximity_checker] objects you want to use for both inner, and edge checkers.
 *
 * Secondly, the advanced proximity monitor has the ability to use processing (the `process` proc). This is optional however.
 * Each proximity checker object can process itself or other things on it's turf as needed. It's up to you on how you want to use it.
 * Inner and edge checkers can process thing seperately. You can turn off processing for field checkers and have only edge checkers process, and vice versa.
 */
/datum/component/proximity_monitor/advanced
	name = "Advanced energy field"
	field_checker_type = /obj/effect/abstract/proximity_checker/advanced/inner_field
	/// The type of checker object that should be used for the field edges.
	var/edge_checker_type = /obj/effect/abstract/proximity_checker/advanced/edge_field
	/// Make a distinction between edge checkers and field checkers seperately.
	var/uses_edge_checkers = FALSE
	/// Do any of the proximity_checker objects need to process things sitting on their tile?
	var/requires_processing = FALSE
	/// Should the main field checkers process things on their tile?
	var/process_field_checkers = FALSE
	/// Should the edge field checkers process things on their tile?
	var/process_edge_checkers = FALSE
	/// A list of proximity_checkers in the inner field. Excludes checkers on the edge of the field.
	var/list/field_checkers
	/// A list of proximity_checkers on the edge of the field.
	var/list/edge_checkers

/datum/component/proximity_monitor/advanced/Initialize(_radius = 1, _always_active = FALSE)
	. = ..()
	if(requires_processing)
		START_PROCESSING(SSfields, src)

/datum/component/proximity_monitor/advanced/Destroy(force, silent)
	STOP_PROCESSING(SSfields, src)
	QDEL_NULL(field_checkers)
	QDEL_NULL(edge_checkers)
	return ..()

/datum/component/proximity_monitor/advanced/create_prox_checkers()
	if(!uses_edge_checkers)
		..() // We don't need to make a distinction between field and edge checkers, use the parent.
		if(process_field_checkers)
			field_checkers = proximity_checkers.Copy() // Still allows for field checkers to use processing.
		return

	LAZYINITLIST(proximity_checkers)
	LAZYINITLIST(field_checkers)
	LAZYINITLIST(edge_checkers)

	var/turf/parent_turf = get_turf(parent)
	for(var/T in RANGE_TURFS(radius, parent_turf))
		if(get_dist(T, parent_turf) == radius)
			edge_checkers += create_single_prox_checker(T, edge_checker_type)
			continue
		field_checkers += create_single_prox_checker(T)

/datum/component/proximity_monitor/advanced/recenter_prox_checkers()
	if(!uses_edge_checkers)
		return ..() // We don't need to make a distinction between field and edge checkers, use the parent.

	var/turf/parent_turf = get_turf(parent)
	var/inner_index = 1
	var/edge_index = 1

	for(var/T in RANGE_TURFS(radius, parent_turf))
		var/obj/checker
		if(get_dist(T, parent_turf) == radius) // If it's at this distance, it's on the edge of the field.
			checker = edge_checkers[edge_index++]
			checker.loc = T
			continue
		checker = field_checkers[inner_index++]
		checker.loc = T

/datum/component/proximity_monitor/advanced/process()
	if(process_field_checkers)
		for(var/checker in field_checkers)
			var/obj/effect/abstract/proximity_checker/advanced/inner_field/F = checker
			process_inner_checker(F)
	if(process_edge_checkers)
		for(var/checker in field_checkers)
			var/obj/effect/abstract/proximity_checker/advanced/edge_field/F = checker
			process_edge_checker(F)

/**
 * Base proc. All processing-related actions associated with inner proximity checkers should go here.
 *
 * Arguments:
 * * obj/effect/abstract/proximity_checker/advanced/inner_field/F - the proximity checker to process
 */
/datum/component/proximity_monitor/advanced/proc/process_inner_checker(obj/effect/abstract/proximity_checker/advanced/inner_field/F)
	return

/**
 * Base proc. All processing-related actions associated with edge proximity checkers should go here.
 *
 * Arguments:
 * * obj/effect/abstract/proximity_checker/advanced/edge_field/F - the proximity checker to process
 */
/datum/component/proximity_monitor/advanced/proc/process_edge_checker(obj/effect/abstract/proximity_checker/advanced/edge_field/F)
	return

/**
 * Base proc. Checks if `AM` can pass the inner field checker.
 *
 * Arguments:
 * * atom/movable/AM - the atom trying to pass the inner field checker object
 * * obj/effect/abstract/proximity_checker/advanced/inner_field/F - the proximity checker object `AM` is trying to pass
 * * turf/entering - the turf `AM` is entering from
 */
/datum/component/proximity_monitor/advanced/proc/inner_field_canpass(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/inner_field/F, turf/entering)
	return TRUE

/**
 * Base proc. Called when something crosses an inner field checker.
 *
 * Arguments:
 * * atom/movable/AM - the atom crossing the inner field checker object
 * * obj/effect/abstract/proximity_checker/advanced/inner_field/F - the proximity checker object `AM` getting crossed
 */
/datum/component/proximity_monitor/advanced/proc/inner_field_crossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/inner_field/F)
	return TRUE

/**
 * Base proc. Called when something uncrosses an inner field checker.
 *
 * Arguments:
 * * atom/movable/AM - the atom uncrossing the inner field checker object
 * * obj/effect/abstract/proximity_checker/advanced/inner_field/F - the proximity checker object `AM` getting uncrossed
 */
/datum/component/proximity_monitor/advanced/proc/inner_field_uncrossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/inner_field/F)
	return TRUE

/**
 * Base proc. Checks if `AM` can pass the edge field checker.
 *
 * Arguments:
 * * atom/movable/AM - the atom trying to pass the edge field checker object
 * * obj/effect/abstract/proximity_checker/advanced/edge_field/F - the proximity checker object `AM` is trying to pass
 * * turf/entering - the turf `AM` is entering from
 */
/datum/component/proximity_monitor/advanced/proc/edge_field_canpass(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/edge_field/F, turf/entering)
	return TRUE

/**
 * Base proc. Called when something crosses an edge field checker.
 *
 * Arguments:
 * * atom/movable/AM - the atom crossing the edge field checker object
 * * obj/effect/abstract/proximity_checker/advanced/edge_field/F - the proximity checker object `AM` getting crossed
 */
/datum/component/proximity_monitor/advanced/proc/edge_field_crossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/edge_field/F)
	return TRUE

/**
 * Base proc. Called when something uncrosses an edge field checker.
 *
 * Arguments:
 * * atom/movable/AM - the atom uncrossing the edge field checker object
 * * obj/effect/abstract/proximity_checker/advanced/edge_field/F - the proximity checker object `AM` getting uncrossed
 */
/datum/component/proximity_monitor/advanced/proc/edge_field_uncrossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/edge_field/F)
	return TRUE


/**
 * # Basic Proximity Checker
 *
 * Inteded for use with the proximity checker component [/datum/component/proximity_monitor].
 * Whenever a movable atom crosses this object, it calls `HasProximity()` on the object which is listening for proximity (`hasprox_receiver`).
 */
/obj/effect/abstract/proximity_checker
	name = "proximity checker"
	/// The component that this object is in use with, and that will receive `HasProximity()` calls.
	var/datum/component/proximity_monitor/monitor
	/// Whether or not the proximity checker is listening for things crossing it.
	var/active

// If this object is initialized without a `_hasprox_receiver` arg, it is qdel'd.
/obj/effect/abstract/proximity_checker/Initialize(mapload, atom/_hasprox_receiver, datum/component/proximity_monitor/P)
	if(!_hasprox_receiver)
		stack_trace("[src] created without a receiver")
		return INITIALIZE_HINT_QDEL
	. = ..()
	monitor = P
	RegisterSignal(monitor, COMSIG_PARENT_QDELETING, .proc/on_receiver_deletion)

/obj/effect/abstract/proximity_checker/Destroy()
	monitor.proximity_checkers -= src
	monitor = null
	return ..()

/**
 * Called when the `hasprox_receiver` receives the `COMSIG_PARENT_QDELETING` signal. When the receiver is deleted, so is this object.
 *
 * Arugments:
 * * datum/source - this will be the `hasprox_receiver`
 * * force - the force flag taken from the qdel proc currently running on `hasprox_receiver`
 */
/obj/effect/abstract/proximity_checker/proc/on_receiver_deletion(datum/source, force = FALSE)
	SIGNAL_HANDLER

	qdel(src)

/**
 * Called when something crossed over the proximity_checker. Notifies the `hasprox_receiver` it has proximity with something.
 *
 * Arguments:
 * * atom/movable/AM - the atom crossing the proximity checker
 * * oldloc - the location `AM` used to be at
 */
/obj/effect/abstract/proximity_checker/Crossed(atom/movable/AM, oldloc)
	set waitfor = FALSE
	. = ..()
	if(active && AM != monitor.host && AM != monitor.hasprox_receiver)
		monitor.hasprox_receiver.HasProximity(AM)

/**
 * # Advanced Proximity Checker
 *
 * Like basic proximity checkers, these objects can also detect proximity.
 * However these are meant for when you need to have some additional (more advanced) behavior on top of what basic proximity checkers can do.
 */
/obj/effect/abstract/proximity_checker/advanced
	name = "advanced proximity phecker"
	/// `hasprox_receivers`s advanced proximity monitor component.
	var/datum/component/proximity_monitor/advanced/advanced_monitor

/obj/effect/abstract/proximity_checker/advanced/Initialize(mapload, atom/_hasprox_receiver, datum/component/proximity_monitor/advanced/P, _always_active)
	if(!P)
		stack_trace("[src] created without a component argument")
		return INITIALIZE_HINT_QDEL
	advanced_monitor = P
	return ..()


/**
 * # Inner Field Proximity Checker
 *
 * An advanced proximity checker object which sits on the the inner tiles of a field.
 */
/obj/effect/abstract/proximity_checker/advanced/inner_field
	name = "inner field"

/obj/effect/abstract/proximity_checker/advanced/inner_field/Destroy()
	advanced_monitor.field_checkers -= src
	return ..()

/obj/effect/abstract/proximity_checker/advanced/inner_field/Crossed(atom/movable/AM, oldloc)
	. = ..()
	return advanced_monitor.inner_field_crossed(AM, src)

/obj/effect/abstract/proximity_checker/advanced/inner_field/Uncrossed(atom/movable/AM, oldloc)
	. = ..()
	return advanced_monitor.inner_field_uncrossed(AM, src)

/obj/effect/abstract/proximity_checker/advanced/inner_field/CanPass(atom/movable/mover, turf/target, height)
	. = ..()
	return advanced_monitor.inner_field_canpass(mover, src, target)

/**
 * # Edge Field Proximity Checker
 *
 * An advanced proximity checker object which sits on the outer edge tiles of a field.
 */
/obj/effect/abstract/proximity_checker/advanced/edge_field
	name = "edge field"

/obj/effect/abstract/proximity_checker/advanced/edge_field/Destroy()
	advanced_monitor.edge_checkers -= src
	return ..()

/obj/effect/abstract/proximity_checker/advanced/edge_field/Crossed(atom/movable/AM, oldloc)
	. = ..()
	return advanced_monitor.edge_field_crossed(AM, src)

/obj/effect/abstract/proximity_checker/advanced/edge_field/Uncrossed(atom/movable/AM)
	. = ..()
	return advanced_monitor.edge_field_uncrossed(AM, src)

/obj/effect/abstract/proximity_checker/advanced/edge_field/CanPass(atom/movable/mover, turf/target, height)
	. = ..()
	return advanced_monitor.edge_field_canpass(mover, src, target)
