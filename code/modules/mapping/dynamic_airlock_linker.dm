RESTRICT_TYPE(/datum/dynamic_airlock_linker)

/// A manager that is used on mapload to generate airlock chambers based on the
/// usage of [/obj/effect/map_effect/dynamic_airlock] helpers. These helpers
/// make up the "zone" of an airlock chamber, as well as indicate which airlocks
/// are exterior or interior, what access should be applied to the doors and
/// controls, And what buttons, vents, and airlock controllers should be linked
/// together. This is performed on Initialize of one of the related helpers.
/// Once done, all the other helpers are deleted to prevent it happening again
/// for that zone.
/datum/dynamic_airlock_linker
	/// A list of [/obj/effect/map_effect/dynamic_airlock/door/interior]s to integrate into the airlock.
	var/list/interior_helpers = list()
	/// A list of [/obj/effect/map_effect/dynamic_airlock/door/exterior]s to integrate into the airlock.
	var/list/exterior_helpers = list()
	/// A collection of "all" access defines collated from any
	/// [/obj/effect/map_effect/dynamic_airlock/access] helpers present in the airlock.
	var/list/req_access = list()
	/// A collection of "any" access defines collated from any
	/// [/obj/effect/map_effect/dynamic_airlock/access] helpers present in the airlock.
	var/list/req_one_access = list()
	/// A list of all [/obj/machinery/airlock_controller]s found in the airlock zone.
	var/list/airlock_controllers = list()
	/// A list of all [/obj/machinery/atmospherics/unary/vent_pump/high_volume] vent pumps found in the airlock zone.
	var/list/vent_pumps = list()

/// Starting from an arbitrary initial helper, search out from all adjacent
/// tiles and find all other helpers that are part of this zone.
///
/// Right now this is a (relatively) busy proc that can't leave any setup to
/// the Initialize of any helpers in its zone, because airlock controllers need
/// all of their airlocks etc known when linkage occurs, which is in
/// LateInitialize. I'm not sure if that's something that can be "fixed".
/datum/dynamic_airlock_linker/proc/extend_zone(obj/effect/map_effect/dynamic_airlock/helper, list/visited_helpers)
	if(helper in visited_helpers)
		return

	visited_helpers |= helper
	for(var/atom/A in get_turf(helper))
		helper.collect_sibling_item(A)

	helper.collect_neighbor_helpers()

	if(length(helper.sibling_items))
		for(var/atom/sibling_item as anything in helper.sibling_items)
			if(istype(sibling_item, /obj/machinery/airlock_controller))
				airlock_controllers |= sibling_item
			if(istype(sibling_item, /obj/machinery/atmospherics/unary/vent_pump))
				vent_pumps |= sibling_item

	if(istype(helper, /obj/effect/map_effect/dynamic_airlock/door/interior))
		interior_helpers |= helper
	if(istype(helper, /obj/effect/map_effect/dynamic_airlock/door/exterior))
		exterior_helpers |= helper

	consume_access_helpers(helper)

	for(var/obj/effect/map_effect/dynamic_airlock/neighbor in helper.neighbor_helpers)
		extend_zone(neighbor, visited_helpers)

/// Use all the information discovered about the airlock zone to link up the
/// included airlock controllers, buttons, airlocks, and vent pumps. Make sure
/// that all helpers found in this process are qdel'd so that no other helper
/// attempts to do the same thing with this zone.
/datum/dynamic_airlock_linker/proc/build(obj/effect/map_effect/dynamic_airlock/origin_helper)
	var/list/visited_helpers = list()
	var/list/interior_airlocks = list()
	var/list/exterior_airlocks = list()

	extend_zone(origin_helper, visited_helpers)
	var/id_to_link = UID()

	for(var/obj/machinery/atmospherics/unary/vent_pump/high_volume/vent_pump as anything in vent_pumps)
		vent_pump.autolink_id = VENT_ID(id_to_link)

	for(var/obj/effect/map_effect/dynamic_airlock/door/door_helper as anything in interior_helpers)
		if(!door_helper.airlock)
			stack_trace("dynamic airlock interior door helper without a door at [COORD(door_helper)]")

		door_helper.assign_ids(INT_BTN_ID(id_to_link), INT_DOOR_ID(id_to_link))
		door_helper.assign_access(src)
		interior_airlocks |= door_helper.airlock.UID()
	for(var/obj/effect/map_effect/dynamic_airlock/door/door_helper as anything in exterior_helpers)
		if(!door_helper.airlock)
			stack_trace("dynamic airlock exterior door helper without a door at [COORD(door_helper)]")

		door_helper.assign_ids(EXT_BTN_ID(id_to_link), EXT_DOOR_ID(id_to_link))
		door_helper.assign_access(src)
		exterior_airlocks |= door_helper.airlock.UID()

	for(var/obj/machinery/airlock_controller/controller as anything in airlock_controllers)
		controller.vent_link_id = VENT_ID(id_to_link)

		controller.int_door_link_id = INT_DOOR_ID(id_to_link)
		controller.int_button_link_id = INT_BTN_ID(id_to_link)

		controller.ext_door_link_id = EXT_DOOR_ID(id_to_link)
		controller.ext_button_link_id = EXT_BTN_ID(id_to_link)

		controller.req_access = req_access
		controller.req_one_access = req_one_access

		controller.interior_doors = interior_airlocks.Copy()
		controller.exterior_doors = exterior_airlocks.Copy()

		controller.link_all_items()

	QDEL_LIST_CONTENTS(interior_helpers)
	QDEL_LIST_CONTENTS(exterior_helpers)
	QDEL_LIST_CONTENTS(visited_helpers)

	airlock_controllers.Cut()
	interior_airlocks.Cut()
	exterior_airlocks.Cut()
	vent_pumps.Cut()


/// Find all the [/obj/effect/mapping_helpers/airlock/access] helpers on the
/// passed in helper's tile, and add them to the list of accesses we'll assign
/// to the linked objects later. Make sure that all mapping helpers found in
/// this process are qdel'd so they don't attempt to assign access to anything
/// else later.
/datum/dynamic_airlock_linker/proc/consume_access_helpers(obj/effect/map_effect/dynamic_airlock/helper)
	for(var/obj/effect/mapping_helpers/airlock/access/any/any_helper in get_turf(helper))
		req_one_access |= any_helper.access
		qdel(any_helper)
	for(var/obj/effect/mapping_helpers/airlock/access/all/all_helper in get_turf(helper))
		req_access |= all_helper.access
		qdel(all_helper)
