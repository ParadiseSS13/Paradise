/turf/simulated/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	layer = 2

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	blocks_air = 1


//sub-type to be used for interior shuttle walls
//won't get an underlay of the destination turf on shuttle move
/turf/simulated/shuttle/wall/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	T.transform = transform
	return T

/turf/simulated/shuttle/wall/copyTurf(turf/T)
	. = ..()
	T.transform = transform

//why don't shuttle walls habe smoothwall? now i gotta do rotation the dirty way
/turf/simulated/shuttle/shuttleRotate(rotation)
	..()
	var/matrix/M = transform
	M.Turn(rotation)
	transform = M

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/simulated/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

/turf/simulated/shuttle/plating/vox	//Vox skipjack plating
	oxygen = 0
	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD

/turf/simulated/shuttle/floor4 // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/simulated/shuttle/floor4/vox	//Vox skipjack floors
	name = "skipjack floor"
	oxygen = 0
	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD

// Actual buildable walls. Yey! Complete with ultra-snowflakey code.

/turf/simulated/wall/shuttle
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	walltype = "shuttle"
	icon_state = "shuttle0"
	smooth = SMOOTH_OLD_MORE
	canSmoothWith = list(
	/turf/simulated/wall/shuttle,
	/obj/structure/window/full/shuttle,
	/obj/machinery/door/airlock,
	/obj/machinery/door/unpowered,
	/obj/machinery/door/poddoor,
	/obj/structure/shuttle)
	var/fullcorner = 0

/turf/simulated/wall/shuttle/after_smooth()
	var/junction = text2num(icon_state)
	icon_state = "[walltype][junction]"
	
	underlays.Cut()
	
	if(junction == 5 || junction == 6 || junction == 9 || junction == 10)
		if(fullcorner)
			icon_state = "[walltype]c[junction]"
			return
		var/list/checkdirs = list()
		switch(junction)
			if(5)
				checkdirs += WEST
				checkdirs += SOUTH
			if(6)
				checkdirs += WEST
				checkdirs += NORTH
			if(9)
				checkdirs += EAST
				checkdirs += SOUTH
			if(10)
				checkdirs += EAST
				checkdirs += NORTH
		var/turf/underlay
		var/currpriority = 0
		for(var/cdir in checkdirs)
			var/turf/T = get_step(src, cdir)
			if(istype(T, /turf/space))
				// Spess is the highest priority.
				underlay = T
				break
			if(locate(/obj/structure/window) in T) // Windows don't count
				continue
			else if(istype(T, /turf/simulated/floor/shuttle) || istype(T, /turf/simulated/shuttle/floor))
				underlay = T
				currpriority = 1
			else if(currpriority < 1 && (istype(T, /turf/simulated/floor) || istype(T, /turf/unsimulated/floor)))
				underlay = T
		if(istype(underlay, /turf/space/transit))
			var/p = 9
			var/angle = 0
			var/state = 1
			switch(underlay.dir)
				if(NORTH)
					angle = 180
					state = ((-p*x+y) % 15) + 1
					if(state < 1)
						state += 15
				if(EAST)
					angle = 90
					state = ((x+p*y) % 15) + 1
				if(WEST)
					angle = -90
					state = ((x-p*y) % 15) + 1
					if(state < 1)
						state += 15
				else
					state =	((p*x+y) % 15) + 1
			var/image/I = image(icon = 'icons/turf/space.dmi', icon_state = "speedspace_ns_[state]", dir = underlay.dir)
			I.transform = turn(matrix(), angle)
			underlays += I
		else if(istype(underlay, /turf/space) || underlay == null)
			underlays += image(icon = 'icons/turf/space.dmi', icon_state = "[((x + y) ^ ~(x * y) + z) % 25]")
		else if(underlay)
			underlays += image(icon = underlay.icon, icon_state = underlay.icon_state, dir = underlay.dir)

/turf/simulated/wall/shuttle/update_icon()
	smooth_icon(src)
	smooth_icon_neighbors(src)

/turf/simulated/wall/shuttle/New()
	. = ..()
	spawn(1)
		update_icon()

/turf/simulated/shuttle/wall/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		//if(underlays.len)
		//	T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	T.transform = transform
	return T

/turf/simulated/wall/shuttle/fullcorner
	fullcorner = 1

/turf/simulated/floor/shuttle
	name = "shuttle floor"
	icon_state = "shuttle1"
	floor_tile = /obj/item/stack/tile/shuttle