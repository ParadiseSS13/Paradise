#define MAX_SHELF_ITEMS 6

/datum/component/shelver
	/// A list whose keys are a 4-tuple of (left, bottom, right, top) bounding boxes to position details.
	/// Position details include "x" and "y" as pixel offsets, and "layer" as appearance layer for a placed object.
	var/list/placement_zones = list()
	/// A list of slots, one per placement zone. Either empty, or containing the UID of the object in that place.
	var/list/used_places = list()
	/// A list of types which are are valid to place on this shelf.
	var/list/allowed_types = list()
	/// The default scale transformation for objects placed on the shelf.
	var/default_scale = 0.70
	/// The default rotation transformation for objects placed on the shelf.
	var/default_rotation = 0
	/// Whether objects auto-shelved by the component are placed in random order on the shelf.
	var/random_pickup_locations = FALSE

/datum/component/shelver/Initialize(list/allowed_types_ = null, random_pickup_locations_ = FALSE)
	if(!isstructure(parent))
		return COMPONENT_INCOMPATIBLE
	used_places.len = length(placement_zones)
	if(length(allowed_types_))
		allowed_types += allowed_types_
	random_pickup_locations = random_pickup_locations_

/datum/component/shelver/RegisterWithParent()
	RegisterSignal(parent, COMSIG_SHELF_ATTEMPT_PICKUP, PROC_REF(on_shelf_attempt_pickup))
	RegisterSignal(parent, COMSIG_ATTACK_BY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_SHELF_ITEM_REMOVED, PROC_REF(on_shelf_item_removed))
	RegisterSignal(parent, COMSIG_SHELF_ADDED_ON_MAPLOAD, PROC_REF(prepare_autoshelf))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/shelver/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER  // COMSIG_PARENT_EXAMINE
	var/list/results = list()
	for(var/uid in used_places)
		if(uid)
			var/obj/item/I = locateUID(uid)
			if(istype(I))
				results += "\a [I.name]"

	if(!length(results))
		return

	var/joined_results = english_list(results)
	examine_list += "<span class='notice'>It currently holds: [joined_results].</span>"

/datum/component/shelver/proc/prepare_autoshelf()
	SIGNAL_HANDLER // COMSIG_SHELF_ADDED_ON_MAPLOAD

	// See /obj/structure/closet/Initialize for explanation of
	// addtimer use here
	END_OF_TICK(CALLBACK(src, PROC_REF(shelf_items)))

/datum/component/shelver/proc/shelf_items()
	var/obj/structure/structure_parent = parent

	var/list/nearby_empty_tiles = list()
	for(var/turf/turf_in_view in view(2, get_turf(structure_parent)))
		if(!isfloorturf(turf_in_view))
			continue
		var/blocked_los = FALSE
		for(var/turf/potential_blockage as anything in get_line(get_turf(structure_parent), turf_in_view))
			if(potential_blockage.is_blocked_turf(exclude_mobs = TRUE, source_atom = parent))
				blocked_los = TRUE
				break
		if(!blocked_los)
			nearby_empty_tiles += turf_in_view

	var/itemcount = 1
	for(var/obj/item/I in structure_parent.loc)
		if(I.density || I.anchored || I == structure_parent)
			continue
		if(itemcount > MAX_SHELF_ITEMS)
			// If we can't fit it on the shelf, toss it somewhere nearby
			if(length(nearby_empty_tiles))
				var/turf/T = pick(nearby_empty_tiles)
				I.pixel_x = 0
				I.pixel_y = 0
				I.forceMove(T)
		if(!(SEND_SIGNAL(structure_parent, COMSIG_SHELF_ATTEMPT_PICKUP, I) & SHELF_PICKUP_FAILURE))
			itemcount++

/datum/component/shelver/proc/on_shelf_attempt_pickup(datum/source, obj/item/to_add)
	SIGNAL_HANDLER // COMSIG_SHELF_ATTEMPT_PICKUP

	if(!istype(to_add))
		return SHELF_PICKUP_FAILURE

	var/free_slot = get_free_slot()
	if(!free_slot)
		return SHELF_PICKUP_FAILURE

	var/coords = placement_zones[free_slot]
	var/position_details = placement_zones[coords]
	add_item(to_add, free_slot, position_details)

/datum/component/shelver/proc/get_free_slot()
	var/list/free_slots = list()
	for(var/i in 1 to length(used_places))
		if(!used_places[i])
			free_slots += i

	if(!length(free_slots))
		return

	if(random_pickup_locations)
		return pick(free_slots)

	return free_slots[1]

/datum/component/shelver/proc/on_shelf_item_removed(datum/source, uid)
	SIGNAL_HANDLER // COMSIG_SHELF_ITEM_REMOVED

	for(var/i in 1 to length(used_places))
		if(used_places[i] == uid)
			used_places[i] = null

			var/obj/O = parent
			if(istype(O))
				O.update_appearance(UPDATE_ICON)

/datum/component/shelver/proc/on_attackby(datum/source, obj/item/attacker, mob/user, params)
	SIGNAL_HANDLER // COMSIG_ATTACK_BY

	if(isrobot(user))
		return COMPONENT_SKIP_AFTERATTACK
	if(attacker.flags & ABSTRACT)
		return COMPONENT_SKIP_AFTERATTACK
	if(user.a_intent == INTENT_HARM)
		return

	if(length(allowed_types) && !(attacker.type in allowed_types))
		to_chat(user, "<span class='notice'>[attacker] won't fit on [parent]!</span>")
		return COMPONENT_SKIP_AFTERATTACK

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])

	var/i = 0
	for(var/coords in placement_zones)
		i++
		if(icon_x >= coords[1] && icon_x <= coords[3] && icon_y >= coords[2] && icon_y <= coords[4])
			if(used_places[i])
				to_chat(user, "<span class='notice'>There's already something there on [parent].</span>")
				return COMPONENT_SKIP_AFTERATTACK

			var/position_details = placement_zones[coords]
			if(user.drop_item())
				add_item(attacker, i, position_details)
				user.visible_message(
					"<span class='notice'>[user] places [attacker] on [parent].</span>",
					"<span class='notice'>You place [attacker] on [parent].</span>",
				)
				return COMPONENT_SKIP_AFTERATTACK

/**
 * Add an item to the shelf.
 *
 * Arguments:
 * * to_add - The item to add. Adding will fail if not an `/obj/item`.
 * * placement_idx - The slot on the shelf to add the item to.
 * * position_details - A list containing the "x" and "y" pixel offsets of the position, and the "layer" the object will be set to, if applicable.
 */
/datum/component/shelver/proc/add_item(obj/item/to_add, placement_idx, list/position_details)
	if(!istype(to_add))
		return
	to_add.forceMove(get_turf(parent))
	to_add.AddComponent(/datum/component/shelved, parent)
	to_add.pixel_x = position_details["x"]
	to_add.pixel_y = position_details["y"]
	to_add.appearance_flags |= PIXEL_SCALE
	if("layer" in position_details)
		to_add.layer = position_details["layer"]
	used_places[placement_idx] = to_add.UID()
	var/obj/O = parent
	if(istype(O))
		O.update_appearance(UPDATE_ICON)

	if(default_scale)
		to_add.transform *= default_scale
	if(default_rotation)
		to_add.transform = turn(to_add.transform, default_rotation)

	SEND_SIGNAL(to_add, COMSIG_SHELF_ITEM_ADDED, default_scale)

/datum/component/shelver/basic_shelf
	placement_zones = list(
		// Bottom Shelf
		list(1,  1, 10, 16) = list("x" = -9, "y" = -5, "layer" = BELOW_OBJ_LAYER),
		list(11, 1, 20, 16) = list("x" = 0, "y" = -5, "layer" = BELOW_OBJ_LAYER),
		list(21, 1, 32, 16) = list("x" = 9, "y" = -5, "layer" = BELOW_OBJ_LAYER),

		// Top Shelf
		list(1,  17, 10, 32) = list("x" = -9, "y" = 9),
		list(11, 17, 20, 32) = list("x" = 0, "y" = 9),
		list(21, 17, 32, 32) = list("x" = 9, "y" = 9),
	)

/datum/component/shelver/gun_rack
	placement_zones = list(
		list(1,  1, 10, 32) = list("x" = -8, "y" = -1),
		list(11, 1, 20, 32) = list("x" = 0, "y" = -1),
		list(21, 1, 32, 32) = list("x" = 8, "y" = -1),
	)
	default_scale = 0.80
	default_rotation = -90

/datum/component/shelver/spear_rack
	placement_zones = list(
		list(1,  1, 13, 32) = list("x" = -6, "y" = 2, "layer" = BELOW_OBJ_LAYER),
		list(14, 1, 20, 32) = list("x" = 0, "y" = 2, "layer" = BELOW_OBJ_LAYER),
		list(21, 1, 32, 32) = list("x" = 6, "y" = 2, "layer" = BELOW_OBJ_LAYER),
	)
	default_scale = 0.80
	default_rotation = -45

/// A component for items stored on shelves, propagated by [/datum/component/shelver] components.
/datum/component/shelved
	/// The UID of the object acting as the shelf
	var/shelf_uid
	/// A copy of the shelved object's original transform, to restore after removing from the shelf.
	var/matrix/original_transform
	/// A copy of the shelved object's original layer, to restore after removing from the shelf.
	var/original_layer
	/// A copy of the shelved object's original appearance flags, to restore after removing from the shelf.
	var/original_appearance_flags
	/// Are we currently being moved by a shuttle? Prevents us from falling off the shelf in transport.
	var/shuttle_moving = FALSE

/datum/component/shelved/Initialize(atom/shelf)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/O = parent

	shelf_uid = shelf.UID()
	original_transform = O.transform
	original_layer = O.layer
	original_appearance_flags = O.appearance_flags

/datum/component/shelved/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(on_item_pickup))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_movable_moved))
	RegisterSignal(parent, COMSIG_MOVABLE_ON_SHUTTLE_MOVE, PROC_REF(on_movable_shuttle_moved))
	var/obj/shelf = locateUID(shelf_uid)
	if(shelf)
		RegisterSignal(shelf, COMSIG_MOVABLE_SHOVE_IMPACT, PROC_REF(on_movable_shove_impact))
		RegisterSignal(shelf, COMSIG_ATOM_HITBY, PROC_REF(on_atom_hitby))
		RegisterSignal(shelf, COMSIG_OBJ_DECONSTRUCT, PROC_REF(on_shelf_deconstruct))

/datum/component/shelved/proc/on_shelf_deconstruct()
	SIGNAL_HANDLER // COMSIG_OBJ_DECONSTRUCT
	qdel(src)

/datum/component/shelved/proc/on_item_pickup(obj/item/I, mob/user)
	SIGNAL_HANDLER // COMSIG_ITEM_PICKUP
	qdel(src)

/datum/component/shelved/proc/on_movable_shuttle_moved()
	SIGNAL_HANDLER // COMSIG_MOVABLE_ON_SHUTTLE_MOVE,
	shuttle_moving = TRUE

/// Generic handler for if anything moves us off our original shelf position, such as atmos pressure.
/datum/component/shelved/proc/on_movable_moved()
	SIGNAL_HANDLER // COMSIG_MOVABLE_MOVED
	if(shuttle_moving)
		// Ignore this movement, since we should be moving with the shelf.
		shuttle_moving = FALSE
	else
		qdel(src)

/datum/component/shelved/UnregisterFromParent()
	. = ..()
	var/obj/O = parent
	O.transform = original_transform
	O.layer = original_layer
	O.appearance_flags = original_appearance_flags
	O.pixel_x = 0
	O.pixel_y = 0

	var/obj/shelf = locateUID(shelf_uid)
	if(istype(shelf))
		UnregisterSignal(shelf, COMSIG_MOVABLE_SHOVE_IMPACT)
		UnregisterSignal(shelf, COMSIG_ATOM_HITBY)

	SEND_SIGNAL(shelf, COMSIG_SHELF_ITEM_REMOVED, parent.UID())

/datum/component/shelved/proc/scatter()
	var/list/clear_turfs = list()
	var/obj/O = parent
	for(var/turf/T in orange(1, get_turf(O)))
		if(isfloorturf(T) && T != get_turf(O))
			clear_turfs |= T

	if(length(clear_turfs))
		var/obj/shelf = locateUID(shelf_uid)
		if(!isobj(shelf))
			// not sure what else we can do here to clean up after ourselves
			CRASH("received non-obj shelf with UID [shelf_uid]")

		var/shelf_name = shelf ? "flies off [shelf]" : "falls down"
		O.visible_message("<span class='notice'>[O] [shelf_name]!</span>")
		O.throw_at(pick(clear_turfs), 2, 3)
		qdel(src)

/datum/component/shelved/proc/on_movable_shove_impact(datum/source, atom/movable/target)
	SIGNAL_HANDLER // COMSIG_MOVABLE_SHOVE_IMPACT
	if(prob(50))
		scatter()

/datum/component/shelved/proc/on_atom_hitby(datum/source, mob/living/carbon/human/hitby)
	SIGNAL_HANDLER // COMSIG_ATOM_HITBY
	if(!istype(hitby))
		return
	if(prob(50))
		scatter()

#undef MAX_SHELF_ITEMS
