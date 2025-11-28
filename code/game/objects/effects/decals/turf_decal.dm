/obj/effect/turf_decal
	icon = 'icons/turf/decals.dmi'
	icon_state = "warningline"
	layer = TURF_DECAL_LAYER

	var/decal_description
	var/painter_category = DECAL_PAINTER_CATEGORY_STANDARD

/obj/effect/turf_decal/Initialize(mapload, _dir)
	..()
	. = INITIALIZE_HINT_QDEL
	var/turf/T = loc
	if(!istype(T)) //you know this will happen somehow
		CRASH("Turf decal initialized in an object/nullspace")

	T.AddElement(/datum/element/decal, icon, icon_state, _dir || dir, layer, alpha, color, FALSE, decal_description)

/obj/effect/turf_decal/trimline
	icon = 'icons/turf/trimline.dmi'
	icon_state = "blank"
	painter_category = DECAL_PAINTER_CATEGORY_THIN

/obj/effect/turf_decal/border
	icon = 'icons/turf/trimline.dmi'
	icon_state = "blank"
	painter_category = DECAL_PAINTER_CATEGORY_SQUARE

#define TURF_DECAL_COLOR_HELPER(color_name, tile_color)					\
	/obj/effect/turf_decal/border/##color_name {						\
		icon_state = "bordercolor";										\
		color = ##tile_color;											\
	}																	\
	/obj/effect/turf_decal/border/##color_name/corner {					\
		icon_state = "bordercolorcorner"								\
	}																	\
	/obj/effect/turf_decal/border/##color_name/full {					\
		icon_state = "bordercolorfull"									\
	}																	\
	/obj/effect/turf_decal/border/##color_name/cee {					\
		icon_state = "bordercolorcee"									\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name {						\
		icon_state = "trimline_box";									\
		color = ##tile_color											\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/line {					\
		icon_state = "trimline"											\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/corner {				\
		icon_state = "trimline_corner"									\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/end {					\
		icon_state = "trimline_end"										\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/arrow_cw {				\
		icon_state = "trimline_arrow_cw"								\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/arrow_ccw {			\
		icon_state = "trimline_arrow_ccw"								\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/warning {				\
		icon_state = "trimline_warn"									\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/warning {				\
		icon_state = "trimline_warn"									\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/filled {				\
		icon_state = "trimline_box_fill";								\
		painter_category = DECAL_PAINTER_CATEGORY_THICK					\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/filled/line {			\
		icon_state = "trimline_fill"									\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/filled/corner {		\
		icon_state = "trimline_corner_fill"								\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/filled/end {			\
		icon_state = "trimline_end_fill"								\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/filled/arrow_cw {		\
		icon_state = "trimline_arrow_cw_fill"							\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/filled/arrow_ccw {		\
		icon_state = "trimline_arrow_ccw_fill"							\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/filled/warning {		\
		icon_state = "trimline_warn_fill"								\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/filled/shrink_cw {		\
		icon_state = "trimline_shrink_cw"								\
	}																	\
	/obj/effect/turf_decal/trimline/##color_name/filled/shrink_ccw {	\
		icon_state = "trimline_shrink_ccw"								\
	}

TURF_DECAL_COLOR_HELPER(neutral, null)
TURF_DECAL_COLOR_HELPER(black, "#444547")
TURF_DECAL_COLOR_HELPER(department/service, "#8dcd72")
TURF_DECAL_COLOR_HELPER(department/medbay, "#72a7cd")
TURF_DECAL_COLOR_HELPER(department/science, "#c794db")
TURF_DECAL_COLOR_HELPER(department/robotics, "#62416f")
TURF_DECAL_COLOR_HELPER(department/engineering, "#cdb272")
TURF_DECAL_COLOR_HELPER(department/supply, "#b99367")
TURF_DECAL_COLOR_HELPER(department/command, "#4f7ea0")
TURF_DECAL_COLOR_HELPER(department/security, "#a0514f")
TURF_DECAL_COLOR_HELPER(department/virology, "#67a04f")
TURF_DECAL_COLOR_HELPER(organization/syndicate, "#9d2300")
TURF_DECAL_COLOR_HELPER(organization/nanotrasen, "#24366f")
TURF_DECAL_COLOR_HELPER(misc/toxins, "#ff7300")

/obj/effect/turf_decal/alphanumeric
	icon = 'icons/turf/alphanum_decals.dmi'
	icon_state = "blank"
	painter_category = DECAL_PAINTER_CATEGORY_ALPHANUM

/obj/effect/turf_decal/alphanumeric/oxygen
	icon_state = "oxygen"

/obj/effect/turf_decal/alphanumeric/carbon_dioxide
	icon_state = "carbon_dioxide"

/obj/effect/turf_decal/alphanumeric/nitrogen
	icon_state = "nitrogen"

/obj/effect/turf_decal/alphanumeric/air
	icon_state = "air"

/obj/effect/turf_decal/alphanumeric/nitrous_oxide
	icon_state = "nitrous_oxide"

/obj/effect/turf_decal/alphanumeric/plasma
	icon_state = "plasma"

/obj/effect/turf_decal/alphanumeric/mix
	icon_state = "mix"

/obj/effect/turf_decal/alphanumeric/hydrogen
	icon_state = "hydrogen"

#define TURF_DECAL_NUMERIC_HELPER(digit)					\
	/obj/effect/turf_decal/alphanumeric/center_##digit {	\
		icon_state = #digit									\
	}														\
	/obj/effect/turf_decal/alphanumeric/left_##digit {		\
		icon_state = #digit	+ "-"							\
	}														\
	/obj/effect/turf_decal/alphanumeric/right_##digit {		\
		icon_state = "-" + #digit							\
	}														\

TURF_DECAL_NUMERIC_HELPER(0)
TURF_DECAL_NUMERIC_HELPER(1)
TURF_DECAL_NUMERIC_HELPER(2)
TURF_DECAL_NUMERIC_HELPER(3)
TURF_DECAL_NUMERIC_HELPER(4)
TURF_DECAL_NUMERIC_HELPER(5)
TURF_DECAL_NUMERIC_HELPER(6)
TURF_DECAL_NUMERIC_HELPER(7)
TURF_DECAL_NUMERIC_HELPER(8)
TURF_DECAL_NUMERIC_HELPER(9)

#undef TURF_DECAL_COLOR_HELPER
#undef TURF_DECAL_NUMERIC_HELPER
