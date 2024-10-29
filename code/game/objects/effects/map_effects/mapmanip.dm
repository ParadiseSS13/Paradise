/obj/effect/map_effect/marker/mapmanip
	name = "mapmanip marker"
	layer = POINT_LAYER

/obj/effect/map_effect/marker/mapmanip/Initialize(mapload)
	. = ..()
	qdel(src)

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

/obj/effect/map_effect/marker_helper/mapmanip/submap/edge
	name = "mapmanip helper marker, edge of submap"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "mapmanip_submap_edge"
