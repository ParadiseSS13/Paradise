/turf/unsimulated/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'
	var/water_overlay_image = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	
/turf/unsimulated/beach/New()
	..()
	if(water_overlay_image)
		var/image/overlay_image = image('icons/misc/beach.dmi', icon_state = water_overlay_image, layer = ABOVE_MOB_LAYER)
		overlay_image.plane = GAME_PLANE
		overlays += overlay_image

/turf/unsimulated/beach/sand
	name = "Sand"
	icon_state = "desert"
	mouse_opacity = MOUSE_OPACITY_ICON
	
/turf/unsimulated/beach/sand/New()			//adds some aesthetic randomness to the beach sand
	icon_state = pick("desert", "desert0", "desert1", "desert2", "desert3", "desert4")
	..()

/turf/unsimulated/beach/sand/dense			//for boundary "walls"
	density = 1

/turf/unsimulated/beach/coastline
	name = "Coastline"
	//icon = 'icons/misc/beach2.dmi'
	//icon_state = "sandwater"
	icon_state = "beach"
	water_overlay_image = "water_coast"

/turf/unsimulated/beach/coastline/dense		//for boundary "walls"
	density = 1

/turf/unsimulated/beach/water
	name = "Shallow Water"
	icon_state = "seashallow"
	water_overlay_image = "water_shallow"
	var/obj/machinery/poolcontroller/linkedcontroller = null

/turf/unsimulated/beach/water/Entered(atom/movable/AM, atom/OldLoc)
	. = ..()
	if(!linkedcontroller)
		return 
	if(ismob(AM))
		linkedcontroller.mobinpool += AM

/turf/unsimulated/beach/water/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(!linkedcontroller)
		return
	if(ismob(AM))
		linkedcontroller.mobinpool -= AM

/turf/unsimulated/beach/water/InitializedOn(atom/A)
	if(!linkedcontroller)
		return
	if(istype(A, /obj/effect/decal/cleanable)) // Better a typecheck than looping through thousands of turfs everyday
		linkedcontroller.decalinpool += A

/turf/unsimulated/beach/water/dense			//for boundary "walls"
	density = 1

/turf/unsimulated/beach/water/edge_drop
	name = "Water"
	icon_state = "seadrop"
	water_overlay_image = "water_drop"

/turf/unsimulated/beach/water/drop
	name = "Water"
	icon = 'icons/turf/floors/seadrop.dmi'
	icon_state = "seadrop"
	water_overlay_image = null
	smooth = SMOOTH_TRUE
	canSmoothWith = list(
		/turf/unsimulated/beach/water/drop, /turf/unsimulated/beach/water/drop/dense,
		/turf/unsimulated/beach/water, /turf/unsimulated/beach/water/dense,
		/turf/unsimulated/beach/water/edge_drop)
	var/obj/effect/beach_drop_overlay/water_overlay

/turf/unsimulated/beach/water/drop/New()
	..()
	water_overlay = new(src)

/turf/unsimulated/beach/water/drop/Destroy()
	QDEL_NULL(water_overlay)
	return ..()

/obj/effect/beach_drop_overlay
	name = "Water"
	icon = 'icons/turf/floors/seadrop-o.dmi'
	layer = MOB_LAYER + 0.1
	smooth = SMOOTH_TRUE
	anchored = 1
	canSmoothWith = list(
		/turf/unsimulated/beach/water/drop, /turf/unsimulated/beach/water/drop/dense,
		/turf/unsimulated/beach/water, /turf/unsimulated/beach/water/dense,
		/turf/unsimulated/beach/water/edge_drop)

/turf/unsimulated/beach/water/drop/dense
	density = 1

/turf/unsimulated/beach/water/deep
	name = "Deep Water"
	icon_state = "seadeep"
	water_overlay_image = "water_deep"

/turf/unsimulated/beach/water/deep/dense
	density = 1

/turf/unsimulated/beach/water/deep/wood_floor
	name = "Sunken Floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "wood"

/turf/unsimulated/beach/water/deep/sand_floor
	name = "Sea Floor"
	icon_state = "sand"

/turf/unsimulated/beach/water/deep/rock_wall
	name = "Reef Stone"
	icon_state = "desert7"
	density = 1
	opacity = 1
	explosion_block = 2
	mouse_opacity = MOUSE_OPACITY_ICON
