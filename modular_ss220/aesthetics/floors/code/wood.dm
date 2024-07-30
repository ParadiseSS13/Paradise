/obj/item/stack/tile
	icon = 'modular_ss220/aesthetics/floors/icons/tiles.dmi'

/// Automatically generates all subtypes for a wooden floor with tiles.
#define WOODEN_FLOOR_HELPER(path, tile)\
##path/oak {\
	color = "#644526";\
	floor_tile = ##tile/oak;\
}\
##tile/oak {\
	name = "oak wood floor tiles";\
	singular_name = "oak wood floor tile";\
	color = "#644526";\
	turf_type = ##path/oak;\
	merge_type = ##tile/oak;\
}\
##path/birch {\
	color = "#FFECB3";\
	floor_tile = ##tile/birch;\
}\
##tile/birch {\
	name = "birch wood floor tiles";\
	singular_name = "birch wood floor tile";\
	color = "#FFECB3";\
	turf_type = ##path/birch;\
	merge_type = ##tile/birch;\
}\
##path/cherry {\
	color = "#643412";\
	floor_tile = ##tile/cherry;\
}\
##tile/cherry {\
	name = "cherry wood floor tiles";\
	singular_name = "cherry wood floor tile";\
	color = "#643412";\
	turf_type = ##path/cherry;\
	merge_type = ##tile/cherry;\
}\

// Wood
/obj/item/stack/tile/wood
	color = "#864A2D"

/turf/simulated/floor/wood
	icon = 'modular_ss220/aesthetics/floors/icons/wooden.dmi'
	icon_state = "wood"
	color = "#864A2D"

/turf/simulated/floor/wood/get_broken_states()
	return list("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")

WOODEN_FLOOR_HELPER(/turf/simulated/floor/wood, /obj/item/stack/tile/wood)

// Fancy Wood
/obj/item/stack/tile/wood/fancy
	name = "fancy light oak wood floor tiles"
	singular_name = "fancy wood floor tile"
	icon_state = "tile-wood-fancy"
	color = "#864A2D"
	turf_type = /turf/simulated/floor/wood/fancy
	merge_type = /obj/item/stack/tile/wood/fancy

/turf/simulated/floor/wood/fancy
	icon_state = "wood_fancy"
	color = "#864A2D"
	floor_tile = /obj/item/stack/tile/wood/fancy

/turf/simulated/floor/wood/fancy/get_broken_states()
	return list("wood_fancy-broken", "wood_fancy-broken2", "wood_fancy-broken3")

WOODEN_FLOOR_HELPER(/turf/simulated/floor/wood/fancy, /obj/item/stack/tile/wood/fancy)

// Parquet
/obj/item/stack/tile/wood/parquet
	name = "parquet wood floor tiles"
	singular_name = "wood parquet floor tile"
	icon_state = "tile-wood-parquet"
	color = "#864A2D"
	turf_type = /turf/simulated/floor/wood/parquet
	merge_type = /obj/item/stack/tile/wood/parquet

/turf/simulated/floor/wood/parquet
	icon_state = "wood_parquet"
	color = "#864A2D"
	floor_tile = /obj/item/stack/tile/wood/parquet

/turf/simulated/floor/wood/parquet/get_broken_states()
	return list("wood_parquet-broken", "wood_parquet-broken2", "wood_parquet-broken3", "wood_parquet-broken4", "wood_parquet-broken5", "wood_parquet-broken6", "wood_parquet-broken7")

WOODEN_FLOOR_HELPER(/turf/simulated/floor/wood/parquet, /obj/item/stack/tile/wood/parquet)

// Tiled Parquet
/obj/item/stack/tile/wood/parquet/tile
	name = "tiled parquet wood floor tiles"
	singular_name = "wood tiled parquet floor tile"
	icon_state = "tile-wood-tile"
	color = "#864A2D"
	turf_type = /turf/simulated/floor/wood/parquet/tile
	merge_type = /obj/item/stack/tile/wood/parquet/tile

/turf/simulated/floor/wood/parquet/tile
	icon_state = "wood_tile"
	color = "#864A2D"
	floor_tile = /obj/item/stack/tile/wood/parquet/tile

/turf/simulated/floor/wood/parquet/tile/get_broken_states()
	return list("wood_tile-broken", "wood_tile-broken2", "wood_tile-broken3")

WOODEN_FLOOR_HELPER(/turf/simulated/floor/wood/parquet/tile, /obj/item/stack/tile/wood/parquet/tile)

#undef WOODEN_FLOOR_HELPER
