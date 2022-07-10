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

/turf/simulated/floor/beach/away/water/InitializedOn(atom/A)
	if(!linkedcontroller)
		return
	if(istype(A, /obj/effect/decal/cleanable)) // Better a typecheck than looping through thousands of turfs everyday
		linkedcontroller.decalinpool += A

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
