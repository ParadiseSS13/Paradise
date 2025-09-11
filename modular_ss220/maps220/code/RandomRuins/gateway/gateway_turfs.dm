// MARK: Indestructible

// Grass
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

/turf/simulated/floor/indestructible/transparent_floor/Initialize(mapload)
	. = ..()
	var/obj/O
	O = new()
	O.underlays.Add(src)
	underlays = O.underlays
	qdel(O)

/turf/simulated/floor/indestructible/transparent_floor/copyTurf(turf/T)
	. = ..()
	T.transform = transform

// MARK: Ghostbar

// Ash
/turf/simulated/floor/ash
	name = "ash"
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "ash"
	baseturf = /turf/simulated/floor/ash
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/ash/pry_tile(obj/item/C, mob/user, silent = FALSE)
	return

/turf/simulated/floor/ash/rocky
	name = "rocky ground"
	icon_state = "rockyash"
	baseturf = /turf/simulated/floor/ash/rocky
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

// Cobble (decorative)
/turf/simulated/floor/indestructible/cobble
	name = "cobblestone path"
	desc = "A simple but beautiful path made of various sized stones."
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "cobblerock"
	baseturf = /turf/simulated/floor/indestructible/cobble

/turf/simulated/floor/indestructible/cobble/side
	icon_state = "cobblerock_side"

/turf/simulated/floor/indestructible/cobble/corner
	icon_state = "cobblerock_corner"

// Cobblestone
/turf/simulated/floor/cobblestone
	name = "cobblestone"
	desc = "Cobbled stone that makes a permanent pathway. A bit old-fashioned."
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "cobble"

/turf/simulated/floor/cobblestone/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0
	baseturf = /turf/simulated/floor/cobblestone/airless

/turf/simulated/floor/cobblestone/dungeon
	icon_state = "cobble_dungeon"

/turf/simulated/floor/cobblestone/dungeon/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0
	baseturf = /turf/simulated/floor/cobblestone/dungeon/airless

/turf/simulated/floor/cobblestone/sparse
	icon_state = "cobble_sparse"

/turf/simulated/floor/cobblestone/sparse/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0
	baseturf = /turf/simulated/floor/cobblestone/sparse/airless

// MARK: Beach

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

// MARK: Black Mesa

/turf/simulated/floor/beach/away/blackmesa
	mouse_opacity = MOUSE_OPACITY_ICON

/turf/simulated/floor/beach/away/blackmesa/xen_acid
	name = "acid water"
	icon = 'icons/misc/beach.dmi'
	icon_state = "seashallow"
	color = "#00b300"
	light_range = 2
	light_color = "#00b300"
	/// How much damage we deal if a mob enters us.
	var/acid_damage = 30

/turf/simulated/floor/beach/away/blackmesa/xen_acid/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived) && !istype(arrived, /mob/living/simple_animal/hostile/blackmesa/xen/bullsquid))
		var/mob/living/unlucky_mob = arrived
		unlucky_mob.adjustFireLoss(acid_damage)
		playsound(unlucky_mob, 'sound/weapons/sear.ogg', 100, TRUE)

/turf/simulated/floor/beach/away/blackmesa/electric
	name = "electric water"
	icon = 'icons/misc/beach.dmi'
	icon_state = "seashallow"
	water_overlay_image = null
	color = COLOR_TEAL
	light_range = 2
	light_color = COLOR_TEAL

/turf/simulated/floor/beach/away/blackmesa/electric/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived))
		var/mob/living/unlucky_mob = arrived
		unlucky_mob.Stun(1.5 SECONDS)
		unlucky_mob.KnockDown(10 SECONDS)
		unlucky_mob.adjustFireLoss(15)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(5, 1, unlucky_mob.loc)
		s.start()
		unlucky_mob.visible_message(
			span_danger("[unlucky_mob.name] is shocked by [src]!"),
			span_userdanger("You feel a powerful shock course through your body!"))
		playsound(unlucky_mob, 'sound/effects/sparks4.ogg', 100, TRUE)

/turf/simulated/floor/beach/away/blackmesa/remove_plating(mob/user)
	return

/turf/simulated/floor/beach/away/blackmesa/crowbar_act(mob/user, obj/item/I)
	return

/turf/simulated/floor/beach/away/blackmesa/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/simulated/floor/beach/away/coastline/xen
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "sandwater_t"
	base_icon_state = "sandwater_t"
	water_overlay_image = null

/turf/simulated/floor/beach/away/coastline/xen/edge_drop
	icon_state = "sandwater_b"
	base_icon_state = "sandwater_b"

/turf/simulated/floor/beach/away/coastline/beachcorner/xen
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "sandwater_inner"
	base_icon_state = "sandwater_inner"
	water_overlay_image = null

/turf/simulated/floor/beach/away/water/deep/xen
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "water"
	base_icon_state = "water"
	water_overlay_image = null

/turf/simulated/floor/plating/xen
	name = "strange weeds"
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "xen_turf"
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/plating/dirt
	name = "dirt"
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "dirt"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/plating/dirt/xen_dirt
	name = "strange path"
	color = "#ee5f1c"

// Away Chasm
/turf/simulated/floor/chasm/straight_down/lava_land_surface/normal_air/normal_temp
	light_color = null
	light_power = 0
	light_range = 0 // removing faint glow
