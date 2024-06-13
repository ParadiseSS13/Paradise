/* Indestructible */
/turf/simulated/wall/indestructible/rock/mineral
	name = "dense rock"
	desc = "An extremely densely-packed rock, Most mining tools or explosives would never get through this."
	icon = 'icons/turf/walls//smoothrocks.dmi'
	icon_state = "smoothrocks-0"
	base_icon_state = "smoothrocks"
	color = COLOR_ROCK
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_SIMULATED_TURFS, SMOOTH_GROUP_MINERAL_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_MINERAL_WALLS)

/turf/simulated/wall/indestructible/cult
	name = "runed metal wall"
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult_wall-0"
	base_icon_state = "cult_wall"
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_CULT_WALLS)

/* White Shuttle */
/turf/simulated/wall/indestructible/whiteshuttle
	name = "wall"
	desc = "A light-weight titanium wall used in shuttles."
	icon = 'icons/turf/walls/plastinum_wall.dmi'
	icon_state = "plastinum_wall-0"
	base_icon_state = "plastinum_wall"
	explosion_block = 3
	flags_2 = RICOCHET_SHINY | RICOCHET_HARD
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_TITANIUM_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE)
	canSmoothWith = list(SMOOTH_GROUP_TITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_SHUTTLE_PARTS, SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE)

/turf/simulated/wall/indestructible/whiteshuttle/nodiagonal
	icon_state = "map-shuttle_nd"
	smoothing_flags = SMOOTH_BITMASK

/turf/simulated/wall/indestructible/whiteshuttle/nosmooth
	smoothing_flags = NONE

/turf/simulated/wall/indestructible/whiteshuttle/overspace
	icon_state = "map-overspace"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	fixed_underlay = list("space" = TRUE)

// sub-type to be used for interior shuttle walls
// won't get an underlay of the destination turf on shuttle move
/turf/simulated/wall/indestructible/whiteshuttle/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	T.transform = transform
	return T

/turf/simulated/wall/indestructible/whiteshuttle/copyTurf(turf/T)
	. = ..()
	T.transform = transform

/* Syndie Shuttle */
/turf/simulated/wall/indestructible/syndishuttle
	name = "wall"
	desc = "An evil wall of plasma and titanium."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	explosion_block = 4
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_PLASTITANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_PLASTITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_SHUTTLE_PARTS)

/turf/simulated/wall/indestructible/syndishuttle/nodiagonal
	icon_state = "map-shuttle_nd"
	base_icon_state = "plastitanium_wall"
	smoothing_flags = SMOOTH_BITMASK

/turf/simulated/wall/indestructible/syndishuttle/nosmooth
	smoothing_flags = NONE

/turf/simulated/wall/indestructible/syndishuttle/overspace
	icon_state = "map-overspace"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	fixed_underlay = list("space" = TRUE)

/turf/simulated/wall/indestructible/syndishuttle/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	T.transform = transform
	return T

/turf/simulated/wall/indestructible/syndishuttle/copyTurf(turf/T)
	. = ..()
	T.transform = transform

/* False Wall */
/obj/structure/falsewall/bookcase
	name = "bookcase"
	desc = "Bookcase made of tropical wood. All the books are covered with a thick layer of dust, except for one..."
	icon = 'modular_ss220/maps220/icons/bookcase_wall.dmi'
	icon_state = "fbookcase_wall-0"
	base_icon_state = "fbookcase_wall"
	mineral = /obj/item/stack/sheet/wood
	walltype = /turf/simulated/wall/mineral/wood
	smoothing_flags = null
	smoothing_groups = null
	canSmoothWith = null

/*Black Mesa*/
/turf/simulated/wall/indestructible/rock/mineral/xen
	color = "#4e1a02"
