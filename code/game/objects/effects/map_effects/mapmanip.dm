/obj/effect/map_effect/marker/mapmanip
	name = "mapmanip marker"
	layer = POINT_LAYER

/obj/effect/map_effect/marker/mapmanip/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/effect/map_effect/marker/mapmanip/submap/extract
	name = "mapmanip marker, extract submap"
	icon = 'icons/effects/map_effects_96x96.dmi'
	icon_state = "mapmanip_extract"
	pixel_x = -32
	pixel_y = -32

/obj/effect/map_effect/marker/mapmanip/submap/insert
	name = "mapmanip marker, insert submap"
	icon = 'icons/effects/map_effects_96x96.dmi'
	icon_state = "mapmanip_insert"
	pixel_x = -32
	pixel_y = -32

/obj/effect/map_effect/marker_helper
	name = "marker helper"
	layer = POINT_LAYER

/obj/effect/map_effect/marker_helper/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/effect/map_effect/marker_helper/mapmanip/submap/edge
	name = "mapmanip marker helper, submap edge"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "mapmanip_submap_edge"

// Farragus mapmanips
/obj/effect/map_effect/marker/mapmanip/submap/extract/station/cerestation/engineering_science
	name = "Cerestation, Engineering-Science Maintenance"

/obj/effect/map_effect/marker/mapmanip/submap/insert/station/cerestation/engineering_science
	name = "Cerestation, Engineering-Science Maintenance"

// DVORAK mapmanips
/obj/effect/map_effect/marker/mapmanip/submap/insert/space_ruin/dvorak/vendor_room
	name = "DVORAK vending machine room"

/obj/effect/map_effect/marker/mapmanip/submap/extract/space_ruin/dvorak/vendor_room
	name = "DVORAK vending machine room"

/obj/effect/map_effect/marker/mapmanip/submap/insert/space_ruin/dvorak/turret_room
	name = "DVORAK turret room"

/obj/effect/map_effect/marker/mapmanip/submap/extract/space_ruin/dvorak/turret_room
	name = "DVORAK turret room"

/obj/effect/map_effect/marker/mapmanip/submap/insert/space_ruin/rocky_motel/drunk_accident
	name = "Drunken Wreck"

/obj/effect/map_effect/marker/mapmanip/submap/extract/space_ruin/rocky_motel/drunk_accident
	name = "Drunken Wreck"
