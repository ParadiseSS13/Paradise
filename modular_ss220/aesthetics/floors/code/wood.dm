/obj/item/stack/tile
	icon = 'modular_ss220/aesthetics/floors/icons/tiles.dmi'

/// Automatically generates all subtypes for a wooden floor with tiles.
#define WOODEN_FLOOR_HELPER(path, tile)\
##path/oak {\
	color = "#644526";\
	floor_tile = ##tile/oak;\
}\
##tile/oak {\
	name = "oak floor tiles";\
	singular_name = "oak floor tile";\
	color = "#644526";\
	turf_type = ##path/oak;\
	merge_type = ##tile/oak;\
}\
##path/birch {\
	color = "#FFECB3";\
	floor_tile = ##tile/birch;\
}\
##tile/birch {\
	name = "birch floor tiles";\
	singular_name = "birch floor tile";\
	color = "#FFECB3";\
	turf_type = ##path/birch;\
	merge_type = ##tile/birch;\
}\
##path/cherry {\
	color = "#643412";\
	floor_tile = ##tile/cherry;\
}\
##tile/cherry {\
	name = "cherry floor tiles";\
	singular_name = "cherry floor tile";\
	color = "#643412";\
	turf_type = ##path/cherry;\
	merge_type = ##tile/cherry;\
}\
##path/amaranth {\
	color = "#6B2E3E";\
	floor_tile = ##tile/amaranth;\
}\
##tile/amaranth {\
	name = "amaranth floor tiles";\
	singular_name = "amaranth floor tile";\
	color = "#6B2E3E";\
	turf_type = ##path/amaranth;\
	merge_type = ##tile/amaranth;\
}\
##path/ebonite {\
	color = "#363649";\
	floor_tile = ##tile/ebonite;\
}\
##tile/ebonite {\
	name = "ebonite floor tiles";\
	singular_name = "ebonite floor tile";\
	color = "#363649";\
	turf_type = ##path/ebonite;\
	merge_type = ##tile/ebonite;\
}\
##path/pink_ivory {\
	color = "#D78575";\
	floor_tile = ##tile/pink_ivory;\
}\
##tile/pink_ivory {\
	name = "pink ivory floor tiles";\
	singular_name = "pink ivory floor tile";\
	color = "#D78575";\
	turf_type = ##path/pink_ivory;\
	merge_type = ##tile/pink_ivory;\
}\
##path/guaiacum {\
	color = "#5C6250";\
	floor_tile = ##tile/guaiacum;\
}\
##tile/guaiacum {\
	name = "guaiacum floor tiles";\
	singular_name = "guaiacum floor tile";\
	color = "#5C6250";\
	turf_type = ##path/guaiacum;\
	merge_type = ##tile/guaiacum;\
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
	name = "fancy wood floor tiles"
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
	name = "parquet floor tiles"
	singular_name = "parquet floor tile"
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
	name = "tiled parquet floor tiles"
	singular_name = "tiled parquet floor tile"
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
