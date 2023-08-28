/turf/simulated/wall
	icon = 'modular_ss220/aesthetics/walls/icons/wall.dmi'

/turf/simulated/wall/r_wall
	icon = 'modular_ss220/aesthetics/walls/icons/reinforced_wall.dmi'

/obj/structure/falsewall
	icon = 'modular_ss220/aesthetics/walls/icons/wall.dmi'

/obj/structure/falsewall/reinforced
	icon = 'modular_ss220/aesthetics/walls/icons/reinforced_wall.dmi'

//indestructible
/turf/simulated/wall/indestructible/rock/mineral
	name = "dense rock"
	desc = "An extremely densely-packed rock, Most mining tools or explosives would never get through this."
	icon = 'icons/turf/walls//smoothrocks.dmi'
	icon_state = "smoothrocks-0"
	base_icon_state = "smoothrocks"
	color = COLOR_ANCIENT_ROCK
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

