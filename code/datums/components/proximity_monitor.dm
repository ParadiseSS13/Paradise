/**
 * # Basic Proximity Monitor
 *
 * Attaching this component to an atom means that the atom will be able to detect mobs or objects moving within a specified radius of it.
 *
 * The component creates several [/obj/effect/abstract/proximity_checker] objects, which follow the `parent` AKA `hasprox_receiver` around, always making sure it's at the center.
 * When something crosses one of these proximiy checkers, the `hasprox_receiver` will have the `HasProximity()` proc called on it, with the crossing mob/obj as the argument.
 */
/datum/component/proximity_monitor
	can_transfer = TRUE
	var/name = "Proximity detection field"
	/// The primary atom the component is attached to and that will be receiving `HasProximity()` calls. Same as the `parent`.
	var/atom/hasprox_receiver
	/**
	 * A list which contains references to movable atoms which the `hasprox_receiver` has moved into.
	 * Used to handle complex situations where the receiver is nested several layers deep into an object.
	 * For example: inside of a box, that's inside of a bag, which is worn on a human. In this situation there are 3 locations we need to listen to for movement.
	 */
	var/list/nested_receiver_locs
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
	nested_receiver_locs = list()
	create_prox_checkers()

	if(isturf(hasprox_receiver.loc))
		toggle_checkers(TRUE)
	else if(always_active)
		toggle_checkers(TRUE)
	else
		toggle_checkers(FALSE)

/datum/component/proximity_monitor/Destroy(force, silent)
	hasprox_receiver = null
	nested_receiver_locs.Cut()
	QDEL_LIST_CONTENTS(proximity_checkers)
	return ..()

/datum/component/proximity_monitor/RegisterWithParent()
	if(ismovable(hasprox_receiver))
		RegisterSignal(hasprox_receiver, COMSIG_MOVABLE_MOVED, PROC_REF(on_receiver_move))
		RegisterSignal(hasprox_receiver, COMSIG_MOVABLE_DISPOSING, PROC_REF(on_disposal_enter))
		RegisterSignal(hasprox_receiver, COMSIG_MOVABLE_EXIT_DISPOSALS, PROC_REF(on_disposal_exit))
	map_nested_locs()

/datum/component/proximity_monitor/UnregisterFromParent()
	if(ismovable(hasprox_receiver))
		UnregisterSignal(hasprox_receiver, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_DISPOSING, COMSIG_MOVABLE_EXIT_DISPOSALS))
	clear_nested_locs()

/**
 * Called when the `hasprox_receiver` moves.
 *
 * Arguments:
 * * datum/source - this will be the `hasprox_receiver`
 * * atom/old_loc - the location the receiver just moved from
 * * dir - the direction the receiver just moved in
 */
/datum/component/proximity_monitor/proc/on_receiver_move(datum/source, atom/old_loc, dir)
	SIGNAL_HANDLER

	// It was just a normal tile-based move, so we return here.
	if(dir)
		move_prox_checkers(dir)
		return

	// Moving onto a turf.
	if(!isturf(old_loc) && isturf(hasprox_receiver.loc))
		toggle_checkers(TRUE)
		clear_nested_locs()

	// Moving into an object.
	else if(always_active)
		toggle_checkers(TRUE)
		map_nested_locs()

	// The receiver moved into something, but isn't `always_active`, so deactivate the checkers.
	else
		toggle_checkers(FALSE)

	recenter_prox_checkers()

/**
 * Called when an atom in `nested_receiver_locs` list moves, if one exists.
 *
 * Arguments:
 * * atom/moved_atom - one of the atoms in `nested_receiver_locs`
 * * atom/old_loc - the location `moved_atom` just moved from
 * * dir - the direction `moved_atom` just moved in
 */
/datum/component/proximity_monitor/proc/on_nested_loc_move(atom/moved_atom, atom/old_loc, dir)
	SIGNAL_HANDLER

	// It was just a normal tile-based move, so we return here.
	if(dir)
		move_prox_checkers(dir)
		return

	// Moving onto a turf.
	if(!isturf(old_loc) && isturf(moved_atom.loc))
		toggle_checkers(TRUE)

	map_nested_locs()
	recenter_prox_checkers()

/**
 * Called when the receiver or an atom in the `nested_receiver_locs` list moves into a disposals holder object.
 *
 * This proc receives arguments, but they aren't needed.
 */
/datum/component/proximity_monitor/proc/on_disposal_enter(datum/source)
	SIGNAL_HANDLER

	toggle_checkers(FALSE)

/**
 * Called when the receiver or an atom in the `nested_receiver_locs` list moves out of a disposals holder object.
 *
 * This proc receives arguments, but they aren't needed.
 */
/datum/component/proximity_monitor/proc/on_disposal_exit(datum/source)
	SIGNAL_HANDLER

	toggle_checkers(TRUE)

/**
 * Registers signals to any nested locations the `hasprox_receiver` is in, excluding turfs, so they can be monitored for movement.
 */
/datum/component/proximity_monitor/proc/map_nested_locs()
	clear_nested_locs()
	var/atom/loc_to_check = hasprox_receiver.loc

	while(loc_to_check && !isturf(loc_to_check))
		if(loc_to_check in nested_receiver_locs)
			continue
		nested_receiver_locs += loc_to_check
		RegisterSignal(loc_to_check, COMSIG_MOVABLE_MOVED, PROC_REF(on_nested_loc_move))
		RegisterSignal(loc_to_check, COMSIG_MOVABLE_DISPOSING, PROC_REF(on_disposal_enter))
		RegisterSignal(loc_to_check, COMSIG_MOVABLE_EXIT_DISPOSALS, PROC_REF(on_disposal_exit))
		loc_to_check = loc_to_check.loc

/**
 * Removes and unregisters signals from all objects currently in the `nested_receiver_locs` list.
 */
/datum/component/proximity_monitor/proc/clear_nested_locs()
	for(var/nested_loc in nested_receiver_locs)
		UnregisterSignal(nested_loc, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_DISPOSING, COMSIG_MOVABLE_EXIT_DISPOSALS))
	nested_receiver_locs = list()

/**
 * Relays basic directional movement from the `hasprox_receiver` or `host`, to all objects in the `proximity_checkers` list.
 *
 * Arguments:
 * * move_dir - the direction the checkers should move in
 */
/datum/component/proximity_monitor/proc/move_prox_checkers(move_dir)
	for(var/obj/P as anything in proximity_checkers)
		P.loc = get_step(P, move_dir)

/**
 * Update all of the component's proximity checker's to either become active or not active.
 *
 * Arguments:
 * * new_active - the value to be assigned to the proximity checker's `active` variable
 */
/datum/component/proximity_monitor/proc/toggle_checkers(new_active)
	for(var/obj/effect/abstract/proximity_checker/P as anything in proximity_checkers)
		P.active = new_active

/**
 * Specifies a new radius for the field. Creates or deletes proximity_checkers accordingly.
 *
 * This proc *can* have a high cost due to the `new`s and `qdel`s of the proximity checkers, depending on the number of calls you need to make to it.
 *
 * Arguments:
 * new_radius - the new value that `proximity_radius` should be set to.
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
	var/obj/effect/abstract/proximity_checker/P = new checker_type(T, src)
	proximity_checkers += P
	return P

/**
 * Called in Initialize(). Generates a set of [proximity checker][/obj/effect/abstract/proximity_checker] objects around the parent.
 */
/datum/component/proximity_monitor/proc/create_prox_checkers()
	LAZYINITLIST(proximity_checkers)
	var/turf/parent_turf = get_turf(parent)
	// For whatever reason their turf is null. Create the checkers in nullspace for now. When the parent moves to a valid turf, they can be recenetered.
	if(!parent_turf)
		// Since we can't use `in range` in nullspace, we need to calculate the number of checkers to create with the below formula.
		var/checker_amount = (1 + radius * 2) ** 2
		for(var/i in 1 to checker_amount)
			create_single_prox_checker(null)
		return
	for(var/T in RANGE_TURFS(radius, parent_turf))
		create_single_prox_checker(T)

/**
 * Re-centers all of the `proximity_checker`s around the parent's current location.
 */
/datum/component/proximity_monitor/proc/recenter_prox_checkers()
	var/turf/parent_turf = get_turf(parent)
	if(!parent_turf)
		toggle_checkers(FALSE)
		return // Need a sanity check here for certain situations like objects moving into disposal holders. Their turf will be null in these cases.
	var/index = 1
	for(var/T in RANGE_TURFS(radius, parent_turf))
		var/obj/checker = proximity_checkers[index++]
		checker.loc = T

/**
 * # Basic Proximity Checker
 *
 * Inteded for use with the proximity checker component [/datum/component/proximity_monitor].
 * Whenever a movable atom crosses this object, it calls `HasProximity()` on the object which is listening for proximity (`hasprox_receiver`).
 *
 * Because these objects try to make the smallest footprint possible, when these objects move **they should use direct `loc` setting only, and not `forceMove`!**
 * The overhead for forceMove is very unnecessary, because for example turfs and areas don't need to know when these have entered or exited them, etc.
 * These are invisible objects who's sole purpose is to simply inform the receiver that something has moved within X tiles of the it.
 */
/obj/effect/abstract/proximity_checker
	name = "proximity checker"
	/// The component that this object is in use with, and that will receive `HasProximity()` calls.
	var/datum/component/proximity_monitor/monitor
	/// Whether or not the proximity checker is listening for things crossing it.
	var/active

/obj/effect/abstract/proximity_checker/Initialize(mapload, datum/component/proximity_monitor/P)
	. = ..()
	monitor = P

/obj/effect/abstract/proximity_checker/Destroy()
	monitor.proximity_checkers -= src
	monitor = null
	return ..()

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
	if(active && AM != monitor.hasprox_receiver && !(AM in monitor.nested_receiver_locs))
		monitor.hasprox_receiver.HasProximity(AM)

/// A custom proximity monitor used for tracking players around a table of cards.

/datum/component/proximity_monitor/table
	/// How far away you can be (in terms of table squares).
	var/max_table_distance
	/// How far away you can be (euclidean distance).
	var/max_total_distance
	/// The UID of the deck
	var/deck_uid
	/// Whether the monitors created should be visible. Used for debugging.
	var/monitors_visible = FALSE

/datum/component/proximity_monitor/table/Initialize(_radius = 1, _always_active = FALSE, _max_table_distance = 5)
	max_table_distance = _max_table_distance
	max_total_distance = _max_table_distance
	. = ..(_radius, _always_active)
	if(istype(parent, /obj/item/deck))
		// this is important for tracking traits and attacking multiple cards. so it's not a true UID, sue me
		var/obj/item/deck/D = parent
		deck_uid = D.main_deck_id
	else
		deck_uid = parent.UID()
	addtimer(CALLBACK(src, PROC_REF(refresh)), 0.5 SECONDS)

/datum/component/proximity_monitor/table/proc/refresh()
	var/list/tables = list()
	var/list/prox_mon_spots = list()
	crawl_along(get_turf(parent), tables, prox_mon_spots, 0)
	QDEL_LIST_CONTENTS(proximity_checkers)
	create_prox_checkers()

/// Crawl along an extended table, and return a list of all turfs that we should start tracking.
/datum/component/proximity_monitor/table/proc/crawl_along(turf/current_turf, list/visited_tables = list(), list/prox_mon_spots = list(), distance_from_start)
	var/obj/structure/current_table = locate(/obj/structure/table) in current_turf

	if(QDELETED(current_table))
		// if there's no table here, we're still adjacent to a table, so this is a spot you could play from
		prox_mon_spots |= current_turf
		return

	if(current_table in visited_tables)
		return

	visited_tables |= current_table
	prox_mon_spots |= current_turf

	if(distance_from_start + 1 > max_table_distance)
		return

	for(var/direction in GLOB.alldirs)
		var/turf/next_turf = get_step(current_table, direction)
		if(!istype(next_turf))
			continue
		if(get_dist_euclidian(get_turf(parent), next_turf) > max_total_distance)
			continue
		.(next_turf, visited_tables, prox_mon_spots, distance_from_start + 1)

/datum/component/proximity_monitor/table/create_prox_checkers()
	update_prox_checkers(FALSE)

/**
 * Update the proximity monitors making up this component.
 * Arguments:
 * * clear_existing - If true, any existing proximity monitors attached to this will be deleted.
 */
/datum/component/proximity_monitor/table/proc/update_prox_checkers(clear_existing = TRUE)
	var/list/tables = list()
	var/list/prox_mon_spots = list()
	if(length(proximity_checkers))
		QDEL_LIST_CONTENTS(proximity_checkers)

	var/atom/movable/atom_parent = parent

	// if we don't have a parent, just treat it normally
	if(!isturf(atom_parent.loc) || !locate(/obj/structure/table) in get_turf(parent))
		return


	LAZYINITLIST(proximity_checkers)
	crawl_along(get_turf(parent), tables, prox_mon_spots, 0)

	// For whatever reason their turf is null. Create the checkers in nullspace for now. When the parent moves to a valid turf, they can be recenetered.
	for(var/T in prox_mon_spots)
		create_single_prox_checker(T, /obj/effect/abstract/proximity_checker/table)

	for(var/atom/table in tables)
		RegisterSignal(table, COMSIG_PARENT_QDELETING, PROC_REF(on_table_qdel), TRUE)

/datum/component/proximity_monitor/table/on_receiver_move(datum/source, atom/old_loc, dir)
	update_prox_checkers()

/datum/component/proximity_monitor/table/RegisterWithParent()
	if(ismovable(hasprox_receiver))
		RegisterSignal(hasprox_receiver, COMSIG_MOVABLE_MOVED, PROC_REF(on_receiver_move))

/datum/component/proximity_monitor/table/proc/on_table_qdel()
	SIGNAL_HANDLER  // COMSIG_PARENT_QDELETED
	update_prox_checkers()

/obj/effect/abstract/proximity_checker/table
	/// The UID for the deck, used in the setting and removal of traits
	var/deck_uid

/obj/effect/abstract/proximity_checker/table/Initialize(mapload, datum/component/proximity_monitor/table/P)
	. = ..()
	deck_uid = P.deck_uid
	// catch any mobs on our tile
	for(var/mob/living/L in get_turf(src))
		register_on_mob(L)

	if(P.monitors_visible)
		icon = 'icons/obj/playing_cards.dmi'
		icon_state = "tarot_the_unknown"
		invisibility = INVISIBILITY_MINIMUM
		layer = MOB_LAYER

/obj/effect/abstract/proximity_checker/table/Destroy()
	var/obj/effect/abstract/proximity_checker/table/same_monitor
	for(var/obj/effect/abstract/proximity_checker/table/mon in get_turf(src))
		if(mon != src && mon.deck_uid == src)
			// if we have another monitor on our space that shares our deck,
			// transfer the signals to it.
			same_monitor = mon

	for(var/mob/living/L in get_turf(src))
		remove_from_mob(L)
		if(!isnull(same_monitor))
			same_monitor.register_on_mob(L)
	return ..()

/obj/effect/abstract/proximity_checker/table/proc/register_on_mob(mob/living/L)
	ADD_TRAIT(L, TRAIT_PLAYING_CARDS, "deck_[deck_uid]")
	RegisterSignal(L, COMSIG_MOVABLE_MOVED, PROC_REF(on_move_from_monitor), TRUE)
	RegisterSignal(L, COMSIG_PARENT_QDELETING, PROC_REF(remove_from_mob), TRUE)


/obj/effect/abstract/proximity_checker/table/proc/remove_from_mob(mob/living/L)
	if(QDELETED(L))
		return
	// otherwise, clean up
	REMOVE_TRAIT(L, TRAIT_PLAYING_CARDS, "deck_[deck_uid]")
	UnregisterSignal(L, COMSIG_MOVABLE_MOVED)

/obj/effect/abstract/proximity_checker/table/Crossed(atom/movable/AM, oldloc)
	if(!isliving(AM))
		return

	var/mob/mover = AM

	// This should hopefully ensure that multiple decks around each other don't overlap
	register_on_mob(mover)

/// Triggered when someone moves from a tile that contains our monitor.
/obj/effect/abstract/proximity_checker/table/proc/on_move_from_monitor(atom/movable/tracked, atom/old_loc)
	SIGNAL_HANDLER  // COMSIG_MOVABLE_MOVED
	for(var/obj/effect/abstract/proximity_checker/table/mon in get_turf(tracked))
		// if we're moving onto a turf that shares our stuff, keep the signals and stuff registered
		if(mon.deck_uid == deck_uid)
			return

	// otherwise, clean up
	remove_from_mob(tracked)
