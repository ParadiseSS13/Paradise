/// A mapping helper that defines the zone of a dynamically arranged airlock
/// chamber. This can be used as an alternative to
/// [/obj/effect/spawner/airlock]s.
///
/// The disadvantage compared to airlock spawners is that all related buttons,
/// airlock controllers, doors, vent pumps and piping must be manually mapped
/// in. The advantages are that chambers of any arbitrary size and shape can be
/// created, and that maps using these helpers instead of the airlock spawners
/// can have the RandomOrientation mapmanip applied to them with confidence that
/// the airlock chambers will be properly constructed, no matter what the
/// orientation of the map is.
/obj/effect/map_effect/dynamic_airlock
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "airlock_zone"
	name = "dynamic airlock zone"
	layer = POINT_LAYER
	var/list/sibling_items
	var/list/neighbor_helpers
	var/list/valid_siblings = list(
		/obj/machinery/airlock_controller/air_cycler,
		/obj/machinery/atmospherics/unary/vent_pump/high_volume,
	)

/obj/effect/map_effect/dynamic_airlock/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/map_effect/dynamic_airlock/LateInitialize()
	. = ..()

	// One helper out of all the connected ones will actually set everything up
	// and qdel all the connected ones so the linker doesn't attempt to do its
	// thing more than once per zone
	if(QDELETED(src))
		return

	var/datum/dynamic_airlock_linker/linker = new()
	linker.build(src)

	qdel(src)

/obj/effect/map_effect/dynamic_airlock/proc/collect_sibling_item(atom/A)
	if(is_type_in_list(A, valid_siblings))
		LAZYADD(sibling_items, A)

/// Look around us in a 1 tile range and aggregate all the adjacent helpers.
/obj/effect/map_effect/dynamic_airlock/proc/collect_neighbor_helpers()
	var/turf/center = get_turf(src)
	for(var/turf/T as anything in RANGE_EDGE_TURFS(1, center))
		for(var/obj/effect/map_effect/dynamic_airlock/A as anything in T)
			LAZYOR(neighbor_helpers, A)

/// A helper used to indicate what doors are connected to an airlock zone. Comes
/// in interior and exterior variants as subtypes.
/obj/effect/map_effect/dynamic_airlock/door
	var/list/buttons = list()
	var/obj/machinery/door/airlock/external/airlock

/obj/effect/map_effect/dynamic_airlock/door/proc/assign_access(datum/dynamic_airlock_linker/linker)
	for(var/obj/machinery/access_button/button in buttons)
		button.req_access = linker.req_access
		button.req_one_access = linker.req_one_access

	airlock.req_access = linker.req_access
	airlock.req_one_access = linker.req_one_access

/obj/effect/map_effect/dynamic_airlock/door/proc/assign_ids(btn_id, door_id)
	for(var/obj/machinery/access_button/button as anything in buttons)
		button.autolink_id = btn_id

	airlock.id_tag = door_id
	airlock.lock()

/obj/effect/map_effect/dynamic_airlock/door/collect_sibling_item(atom/A)
	. = ..()
	if(istype(A, /obj/machinery/door/airlock/external))
		airlock = A
	if(istype(A, /obj/machinery/access_button))
		buttons |= A

/obj/effect/map_effect/dynamic_airlock/door/interior
	name = "dynamic airlock interior door"
	icon_state = "airlock_interior"

/obj/effect/map_effect/dynamic_airlock/door/exterior
	name = "dynamic airlock exterior door"
	icon_state = "airlock_exterior"
