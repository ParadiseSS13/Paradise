/**
 * # Proximity monitor component
 *
 * Attaching this component to an atom means that the atom will be able to detect mobs/objs moving within a 1 tile of it.
 *
 * The component creates several `obj/effect/abstract/proximity_checker` objects, which follow the parent atom around, always making sure it's at the center.
 * When something crosses one of these `proximiy_checker`s, the parent has the `HasProximity()` proc called on it, with the crossing mob/obj as the argument.
 */
/datum/component/proximity_monitor
	var/atom/owner
	/// A list of currently created `/obj/effect/abstract/proximity_checker`s in use with this component.
	var/list/proximity_checkers

/datum/component/proximity_monitor/Initialize()
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	owner = parent
	create_prox_checkers()

/datum/component/proximity_monitor/Destroy(force, silent)
	QDEL_LIST(proximity_checkers)
	owner = null
	return ..()

/datum/component/proximity_monitor/RegisterWithParent()
	. = ..()
	if(ismovable(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/HandleMove)

/datum/component/proximity_monitor/UnregisterFromParent()
	. = ..()
	if(ismovable(parent))
		UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/**
 * Called when the `parent` receives the `COMSIG_MOVABLE_MOVED` signal, which occurs when it `Move()`s
 *
 * Code is only ran when there is no `Dir`, which occurs when the parent is teleported, gets placed into a storage item, dropped, or picked up.
 * Normal movement, for example moving 1 tile to the west, is handled by the `proximity_checker` objects.
 *
 * Arguments:
 * * source - this will be the `parent`
 * * OldLoc - the location the parent just moved from
 * * Dir - the direction the parent just moved in
 * * forced - if we were forced to move
 */
/datum/component/proximity_monitor/proc/HandleMove(datum/source, atom/OldLoc, Dir, forced)
	if(!Dir) // No dir means the parent teleported, or moved in a non-standard way like getting placed into disposals, onto a table, dropped, picked up, etc.
		recenter_prox_checkers()

/**
 * Called in Initialize(). Generates a set of `/obj/effect/abstract/proximity_checker` objects around the parent, and registers signals to them.
 */
/datum/component/proximity_monitor/proc/create_prox_checkers()
	proximity_checkers = list()
	for(var/turf/T in range(1, get_turf(parent)))
		var/obj/effect/abstract/proximity_checker/P = new(T, parent)
		proximity_checkers += P
		// Basic movement for the proximity_checker objects. The objects will move 1 tile in the direction the parent just moved.
		P.RegisterSignal(parent, COMSIG_MOVABLE_MOVED, /obj/effect/abstract/proximity_checker/.proc/HandleMove)

/**
 * Re-centers all of the parent's `proximity_checker`s around its current location.
 */
/datum/component/proximity_monitor/proc/recenter_prox_checkers()
	var/list/prox_checkers = owner.get_all_adjacent_turfs()
	for(var/checker in proximity_checkers)
		var/obj/effect/abstract/proximity_checker/P = checker
		P.loc = pick_n_take(prox_checkers)

/**
 * # Proximity checker abstract object
 *
 * Inteded for use with the proximity checker component (/datum/component/proximity_monitor).
 * Whenever a movable atom crosses this object, it calls `HasProximity()` on the object which is listening for proximity (`hasprox_receiver`).
 */
/obj/effect/abstract/proximity_checker
	name = "Proximity checker"
	/// Whether or not the proximity checker is listening for things crossing it.
	var/active
	/// The linked atom which has the proximity_monitor component, and will recieve the `HasProximity()` calls.
	var/atom/hasprox_receiver

// If this object is initialized without a `_hasprox_receiver` arg, it is qdel'd.
/obj/effect/abstract/proximity_checker/Initialize(mapload, atom/_hasprox_receiver)
	if(_hasprox_receiver)
		hasprox_receiver = _hasprox_receiver
		RegisterSignal(hasprox_receiver, COMSIG_PARENT_QDELETING, .proc/OnParentDeletion)
		if(isturf(hasprox_receiver.loc)) // if the reciever is inside a locker/crate/etc, they don't detect proximity
			active = TRUE
	else
		stack_trace("/obj/effect/abstract/proximity_checker created without a receiver")
		return INITIALIZE_HINT_QDEL
	return ..()

/obj/effect/abstract/proximity_checker/Destroy()
	hasprox_receiver = null
	return ..()

/**
 * Called when the `hasprox_receiver` receives the `COMSIG_PARENT_QDELETING` signal. When the receiver is deleted, so is this object.
 *
 * Arugments:
 * * source - this will be the `hasprox_receiver`
 * * force - the force flag taken from the qdel proc currently running on `hasprox_receiver`
 */
/obj/effect/abstract/proximity_checker/proc/OnParentDeletion(datum/source, force = FALSE)
	qdel(src)

/**
 * Something crossed over the proximity_checker. Notify the `hasprox_receiver` it has proximity with something. Only fires if the checker is `active`.
 */
/obj/effect/abstract/proximity_checker/Crossed(atom/movable/AM, oldloc)
	set waitfor = FALSE
	if(active)
		hasprox_receiver.HasProximity(AM)

/**
 * Moves the proximity_checker 1 tile in the `Dir` direction.
 *
 * If `Dir` is null it will be recentered around the receiver via the `recenter_prox_checkers()` proc.
 * If the new location of the receiver is NOT a turf, set `active` to FALSE, so that it does not receive proximity calls.
 * If the new location of the receiver IS a turf, set `active` to TRUE, so that it can receive proximity calls again.
 *
 * Arguments:
 * * source - this will be the `hasprox_receiver`
 * * OldLoc - the location the `hasprox_receiver` just moved from
 * * Dir - the direction the `hasprox_receiver` just moved in
 * * forced - if we were forced to move
 */
/obj/effect/abstract/proximity_checker/proc/HandleMove(datum/source, atom/OldLoc, Dir, forced)
	if(Dir)
		loc = get_step(src, Dir) // Basic movement 1 tile in some direction.
		return
	if(!isturf(hasprox_receiver.loc))
		active = FALSE // Receiver shouldn't detect proximity while picked up, in a backpack, closet, etc.
	else
		active = TRUE // Receiver can detect proximity again because it's on a turf.
