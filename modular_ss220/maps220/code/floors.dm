/* Beach */
/turf/simulated/floor/beach/away/coastline/beachcorner
	name = "beachcorner"
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "beachcorner"
	base_icon_state = "beachcorner"
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER
	baseturf = /turf/simulated/floor/beach/away/coastline/beachcorner

/turf/simulated/floor/beach/away/water/deep/dense_canpass
	name = "Deep Water"
	smoothing_groups = list()
	water_overlay_image = null
	icon_state = "seadeep"
	baseturf = /turf/simulated/floor/beach/away/water/deep

/turf/simulated/floor/beach/away/water/deep/dense_canpass/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(isliving(mover) || mover.density)
		return FALSE

/turf/simulated/floor/beach/away/sand_alternative
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "sand"
	base_icon_state = "sand"
	mouse_opacity = MOUSE_OPACITY_ICON
	water_overlay_image = null
	baseturf = /turf/simulated/floor/beach/away/sand_alternative

/turf/simulated/floor/beach/away/sand_alternative/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "sand[rand(1,4)]"

/turf/simulated/floor/beach/away/sand_alternative/remove_plating(mob/user)
	return

/turf/simulated/floor/beach/away/sand_alternative/crowbar_act(mob/user, obj/item/I)
	return

/turf/simulated/floor/beach/away/sand_alternative/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/simulated/floor/beach/away/coastline/alternative
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "beach"
	base_icon_state = "beach"
	water_overlay_image = null
	baseturf = /turf/simulated/floor/beach/away/coastline/alternative

/turf/simulated/floor/beach/away/coastline/beachcorner/alternative
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "beach-corner"
	base_icon_state = "beach-corner"
	water_overlay_image = null
	baseturf = /turf/simulated/floor/beach/away/coastline/beachcorner/alternative

/turf/simulated/floor/beach/away/water/drop_no_overlay
	name = "Water"
	icon = 'icons/turf/floors/seadrop.dmi'
	icon_state = "seadrop-0"
	base_icon_state = "seadrop"
	water_overlay_image = null
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = list(SMOOTH_GROUP_BEACH_WATER)
	baseturf = /turf/simulated/floor/beach/away/water/drop_no_overlay

/turf/simulated/floor/beach/away/water/drop_no_overlay/dense
	density = TRUE
	baseturf = /turf/simulated/floor/beach/away/water/drop_no_overlay/dense

/* Lavaland */
/turf/simulated/floor/plasteel/lavaland_air
	name = "floor"
	temperature = 300
	oxygen = 14
	nitrogen = 23

/* Indestructible */
/turf/simulated/floor/indestructible/grass
	name = "grass patch"
	icon = 'icons/turf/floors/grass.dmi'
	icon_state = "grass"
	base_icon_state = "grass"
	baseturf = /turf/simulated/floor/indestructible/grass
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_GRASS)
	canSmoothWith = list(SMOOTH_GROUP_GRASS, SMOOTH_GROUP_JUNGLE_GRASS)
	layer = ABOVE_OPEN_TURF_LAYER
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	transform = matrix(1, 0, -9, 0, 1, -9)

/turf/simulated/floor/indestructible/grass/jungle
	name = "jungle grass"
	icon = 'icons/turf/floors/junglegrass.dmi'
	icon_state = "junglegrass"
	base_icon_state = "junglegrass"
	baseturf = /turf/simulated/floor/indestructible/grass/jungle
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_GRASS, SMOOTH_GROUP_JUNGLE_GRASS)

/turf/simulated/floor/indestructible/grass/no_creep
	baseturf = /turf/simulated/floor/indestructible/grass/no_creep
	smoothing_flags = null
	smoothing_groups = null
	canSmoothWith = null
	layer = GRASS_UNDER_LAYER
	transform = null

/turf/simulated/floor/indestructible/grass/remove_plating(mob/user)
	return

/turf/simulated/floor/indestructible/grass/crowbar_act(mob/user, obj/item/I)
	return

/turf/simulated/floor/indestructible/grass/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

// Shuttle
/turf/simulated/floor/indestructible/transparent_floor
	icon = 'modular_ss220/maps220/icons/shuttle.dmi'
	icon_state = "transparent"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/indestructible/transparent_floor/Initialize()
	..()
	var/obj/O
	O = new()
	O.underlays.Add(src)
	underlays = O.underlays
	qdel(O)

/turf/simulated/floor/indestructible/transparent_floor/copyTurf(turf/T)
	. = ..()
	T.transform = transform
