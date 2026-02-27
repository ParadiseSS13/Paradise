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
	color = "#ff00cc"
	pixel_x = -32
	pixel_y = -32

	var/singleton_id

/obj/effect/map_effect/marker/mapmanip/submap/insert
	name = "mapmanip marker, insert submap"
	icon = 'icons/effects/map_effects_96x96.dmi'
	icon_state = "mapmanip_insert"
	color = "#ff00cc"
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
	color = "#ff00cc"

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

// Rocky Motel mapanips

/obj/effect/map_effect/marker/mapmanip/submap/insert/space_ruin/rocky_motel
	name = "Rocky motel submap"

/obj/effect/map_effect/marker/mapmanip/submap/extract/space_ruin/rocky_motel
	name = "Rocky motel submap"

// White ship mapmanips
/obj/effect/map_effect/marker/mapmanip/submap/insert/space_ruin/white_ship/medbay
	name = "white_ship medbay"
	color = COLOR_LIME

/obj/effect/map_effect/marker/mapmanip/submap/extract/space_ruin/white_ship/medbay
	name = "white_ship medbay"
	color = COLOR_LIME

/obj/effect/map_effect/marker/mapmanip/submap/insert/space_ruin/white_ship/storage
	name = "white_ship storage"
	color = COLOR_SUN

/obj/effect/map_effect/marker/mapmanip/submap/extract/space_ruin/white_ship/storage
	name = "white_ship storage"
	color = COLOR_SUN

/obj/effect/map_effect/marker/mapmanip/submap/insert/space_ruin/white_ship/gun_room
	name = "white_ship gun room"

/obj/effect/map_effect/marker/mapmanip/submap/extract/space_ruin/white_ship/gun_room
	name = "white_ship gun room"

/obj/effect/map_effect/marker/mapmanip/submap/insert/deepmaints/small
	name = "deepmaints small"

/obj/effect/map_effect/marker/mapmanip/submap/extract/deepmaints/small
	name = "deepmaints small"

/obj/effect/map_effect/marker/mapmanip/submap/insert/deepmaints/medium
	name = "deepmaints medium"

/obj/effect/map_effect/marker/mapmanip/submap/extract/deepmaints/medium
	name = "deepmaints medium"

/obj/effect/map_effect/marker/mapmanip/submap/extract/deepmaints/hallway_horizontal
	name = "deepmaints horizontal hallway"
	color = COLOR_SUN

/obj/effect/map_effect/marker/mapmanip/submap/insert/deepmaints/hallway_horizontal
	name = "deepmaints horizontal hallway"
	color = COLOR_SUN

/obj/effect/map_effect/marker/mapmanip/submap/extract/deepmaints/hallway_vertical
	name = "deepmaints vertical hallway"
	color = COLOR_TEAL

/obj/effect/map_effect/marker/mapmanip/submap/insert/deepmaints/hallway_vertical
	name = "deepmaints vertical hallway"
	color = COLOR_TEAL

/obj/effect/map_effect/marker/mapmanip/submap/extract/deepmaints/hallway_floor
	name = "deepmaints floor tile 3x3"
	color = COLOR_RED

/obj/effect/map_effect/marker/mapmanip/submap/insert/deepmaints/hallway_floor
	name = "deepmaints floor tile 3x3"
	color = COLOR_RED

/obj/effect/map_effect/marker/mapmanip/submap/extract/deepmaints/hallroom_5x5
	name = "deepmaints hall room 5x5"
	color = COLOR_YELLOW

/obj/effect/map_effect/marker/mapmanip/submap/insert/deepmaints/hallroom_5x5
	name = "deepmaints hall room 5x5"
	color = COLOR_YELLOW

/obj/effect/map_effect/marker/mapmanip/submap/extract/deepmaints/long
	name = "deepmaints room long"
	color = COLOR_ASSEMBLY_LBLUE

/obj/effect/map_effect/marker/mapmanip/submap/insert/deepmaints/long
	name = "deepmaints room long"
	color = COLOR_ASSEMBLY_LBLUE
