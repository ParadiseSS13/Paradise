/obj/effect/turf_decal/tiles
	icon_state = "blank"
	// these plane and layer settings are primarily for visual readability
	// in map editors; they are not the ones used when decals are applied
	plane = FLOOR_PLANE
	layer = LATTICE_LAYER
	painter_category = DECAL_PAINTER_CATEGORY_TILES

/obj/effect/turf_decal/tiles/Initialize(mapload, _dir)
	layer = TURF_LAYER
	plane = GAME_PLANE
	. = ..()

#define TILES_DECAL_HELPER(name, icon_path)		\
	/obj/effect/turf_decal/tiles/##name {			\
		icon = icon_path;							\
		icon_state = "tile_full"					\
	}												\
	/obj/effect/turf_decal/tiles/##name/side {		\
		icon_state = "tile_directional"				\
	}												\
	/obj/effect/turf_decal/tiles/##name/corner {	\
		icon_state = "tile_corner"					\
	}												\
	/obj/effect/turf_decal/tiles/##name/checker {	\
		icon_state = "tile_opposing_corners"		\
	}												\
	/obj/effect/turf_decal/tiles/##name/mono {		\
		icon_state = "tile_mono"					\
	}												\
	/obj/effect/turf_decal/tiles/##name/half {		\
		icon_state = "tile_half"					\
	}

TILES_DECAL_HELPER(department/command, 'icons/turf/decals/floormarkings/departmental/command_decals.dmi')
TILES_DECAL_HELPER(department/security, 'icons/turf/decals/floormarkings/departmental/security_decals.dmi')
TILES_DECAL_HELPER(department/medical, 'icons/turf/decals/floormarkings/departmental/medical_decals.dmi')
TILES_DECAL_HELPER(department/virology, 'icons/turf/decals/floormarkings/departmental/virology_decals.dmi')
TILES_DECAL_HELPER(department/chemistry, 'icons/turf/decals/floormarkings/departmental/chemistry_decals.dmi')
TILES_DECAL_HELPER(department/engineering, 'icons/turf/decals/floormarkings/departmental/engineering_decals.dmi')
TILES_DECAL_HELPER(department/science, 'icons/turf/decals/floormarkings/departmental/science_decals.dmi')
TILES_DECAL_HELPER(department/cargo, 'icons/turf/decals/floormarkings/departmental/cargo_decals.dmi')
TILES_DECAL_HELPER(jobs/bar, 'icons/turf/decals/floormarkings/jobs/bar_decals.dmi')
TILES_DECAL_HELPER(dark, 'icons/turf/decals/floormarkings/departmental/dark_decals.dmi')
TILES_DECAL_HELPER(neutral, 'icons/turf/decals/floormarkings/departmental/neutral_decals.dmi')
TILES_DECAL_HELPER(white, 'icons/turf/decals/floormarkings/departmental/white_decals.dmi')

#undef TILES_DECAL_HELPER
