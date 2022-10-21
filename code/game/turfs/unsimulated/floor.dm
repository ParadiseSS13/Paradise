/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/unsimulated/floor/grass
	name = "grass patch"
	icon_state = "grass1"
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/unsimulated/floor/grass/Initialize(mapload)
	. = ..()
	icon_state = "grass[rand(1,4)]"

/turf/unsimulated/floor/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/unsimulated/floor/abductor
	name = "alien floor"
	icon_state = "alienpod1"

/turf/unsimulated/floor/abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1,9)]"

/turf/unsimulated/floor/vox
	icon_state = "dark"
	nitrogen = 100
	oxygen = 0

/turf/unsimulated/floor/carpet
	name = "Carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET)
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/unsimulated/floor/wood
	icon_state = "wood"
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/unsimulated/floor/lava
	name = "lava"
	desc = "That looks... a bit dangerous"
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "lava-255"
	base_icon_state = "lava"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_FLOOR_LAVA)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_LAVA)
	var/lava_damage = 250
	var/lava_fire = 20
	light_range = 2
	light_color = "#FFC040"
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA

/turf/unsimulated/floor/lava/Entered(mob/living/M, atom/OL, ignoreRest = 0)
	if(istype(M))
		M.apply_damage(lava_damage, BURN)
		M.adjust_fire_stacks(lava_fire)
		M.IgniteMob()

/turf/unsimulated/floor/lava/dense
	density = 1
