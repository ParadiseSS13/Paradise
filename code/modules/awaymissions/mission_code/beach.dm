/obj/effect/waterfall
	name = "waterfall effect"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	opacity = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	density = FALSE
	anchored = TRUE
	invisibility = 101

	var/water_frequency = 15
	var/water_timer = 0

/obj/effect/waterfall/New()
	. = ..()
	water_timer = addtimer(CALLBACK(src, PROC_REF(drip)), water_frequency, TIMER_STOPPABLE | TIMER_LOOP)

/obj/effect/waterfall/Destroy()
	if(water_timer)
		deltimer(water_timer)
	water_timer = null
	return ..()

/obj/effect/waterfall/proc/drip()
	var/obj/effect/particle_effect/water/W = new(loc)
	W.dir = dir
	spawn(1)
		W.loc = get_step(W, dir)

/turf/simulated/floor/beach/away
	name = "Beach"
	icon = 'icons/misc/beach.dmi'
	var/water_overlay_image = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	planetary_atmos = TRUE

/turf/simulated/floor/beach/away/Initialize(mapload)
	. = ..()
	if(water_overlay_image)
		var/image/overlay_image = image('icons/misc/beach.dmi', icon_state = water_overlay_image, layer = ABOVE_MOB_LAYER)
		overlay_image.plane = GAME_PLANE
		overlays += overlay_image

/turf/simulated/floor/beach/away/sand
	name = "Sand"
	icon_state = "desert"
	mouse_opacity = MOUSE_OPACITY_ICON
	baseturf = /turf/simulated/floor/beach/away/sand
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/beach/away/sand/Initialize(mapload)
	. = ..()			//adds some aesthetic randomness to the beach sand
	icon_state = pick("desert", "desert0", "desert1", "desert2", "desert3", "desert4")

/turf/simulated/floor/beach/away/sand/dense //for boundary "walls"
	density = TRUE
	baseturf = /turf/simulated/floor/beach/away/sand/dense

/turf/simulated/floor/beach/away/coastline
	name = "Coastline"
	//icon = 'icons/misc/beach2.dmi'
	//icon_state = "sandwater"
	icon_state = "beach"
	water_overlay_image = "water_coast"
	baseturf = /turf/simulated/floor/beach/away/coastline
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/simulated/floor/beach/away/coastline/dense		//for boundary "walls"
	density = TRUE
	baseturf = /turf/simulated/floor/beach/away/coastline/dense

/turf/simulated/floor/beach/away/water
	name = "Shallow Water"
	icon_state = "seashallow"
	water_overlay_image = "water_shallow"
	var/obj/machinery/poolcontroller/linkedcontroller = null
	baseturf = /turf/simulated/floor/beach/away/water
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER
	smoothing_groups = list(SMOOTH_GROUP_BEACH_WATER)

/turf/simulated/floor/beach/away/water/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_INITIALIZED_ON, PROC_REF(InitializedOn))

/turf/simulated/floor/beach/away/water/Entered(atom/movable/AM, atom/OldLoc)
	. = ..()
	if(!linkedcontroller)
		return
	if(ismob(AM))
		linkedcontroller.mobinpool += AM

/turf/simulated/floor/beach/away/water/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(!linkedcontroller)
		return
	if(ismob(AM))
		linkedcontroller.mobinpool -= AM

/turf/simulated/floor/beach/away/water/proc/InitializedOn(atom/A)
	if(!linkedcontroller)
		return
	if(istype(A, /obj/effect/decal/cleanable)) // Better a typecheck than looping through thousands of turfs everyday
		linkedcontroller.decalinpool += A

/turf/simulated/floor/beach/away/water/lavaland_air
	nitrogen = 23
	oxygen = 14
	temperature = 300
	planetary_atmos = TRUE

/turf/simulated/floor/beach/away/water/dense			//for boundary "walls"
	density = TRUE
	baseturf = /turf/simulated/floor/beach/away/water/dense

/turf/simulated/floor/beach/away/water/edge_drop
	name = "Water"
	icon_state = "seadrop"
	water_overlay_image = "water_drop"
	baseturf = /turf/simulated/floor/beach/away/water/edge_drop

/turf/simulated/floor/beach/away/water/drop
	name = "Water"
	icon = 'icons/turf/floors/seadrop.dmi'
	icon_state = "seadrop-0"
	base_icon_state = "seadrop"
	water_overlay_image = null
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = list(SMOOTH_GROUP_BEACH_WATER)
	var/obj/effect/beach_drop_overlay/water_overlay
	baseturf = /turf/simulated/floor/beach/away/water/drop

/turf/simulated/floor/beach/away/water/drop/Initialize(mapload)
	. = ..()
	water_overlay = new(src)

/turf/simulated/floor/beach/away/water/drop/Destroy()
	QDEL_NULL(water_overlay)
	return ..()

/obj/effect/beach_drop_overlay
	name = "Water"
	icon = 'icons/turf/floors/seadrop-o.dmi'
	base_icon_state = "seadrop-o"
	layer = MOB_LAYER + 0.1
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = list(SMOOTH_GROUP_BEACH_WATER)
	anchored = TRUE

/turf/simulated/floor/beach/away/water/drop/dense
	density = TRUE
	baseturf = /turf/simulated/floor/beach/away/water/drop/dense

/turf/simulated/floor/beach/away/water/deep
	name = "Deep Water"
	smoothing_groups = list()
	icon_state = "seadeep"
	water_overlay_image = "water_deep"
	baseturf = /turf/simulated/floor/beach/away/water/deep

/turf/simulated/floor/beach/away/water/deep/dense
	density = TRUE
	baseturf = /turf/simulated/floor/beach/away/water/deep/dense

/turf/simulated/floor/beach/away/water/deep/wood_floor
	name = "Sunken Floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "wood"
	baseturf = /turf/simulated/floor/beach/away/water/deep/wood_floor

/turf/simulated/floor/beach/away/water/deep/sand_floor
	name = "Sea Floor"
	icon_state = "sand"
	baseturf = /turf/simulated/floor/beach/away/water/deep/sand_floor

/turf/simulated/floor/beach/away/water/deep/rock_wall
	name = "Reef Stone"
	icon_state = "desert7"
	density = TRUE
	opacity = TRUE
	explosion_block = 2
	mouse_opacity = MOUSE_OPACITY_ICON
	baseturf = /turf/simulated/floor/beach/away/water/deep/rock_wall

/obj/effect/baseturf_helper/beach/away/sand
	name = "beach away sand baseturf editor"
	baseturf = /turf/simulated/floor/beach/away/sand

/obj/effect/baseturf_helper/beach/away/water
	name = "beach away water baseturf editor"
	baseturf = /turf/simulated/floor/beach/away/water/deep/sand_floor
