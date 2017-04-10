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
