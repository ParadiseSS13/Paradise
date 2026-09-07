/*
All shuttleRotate procs go here
If ever any of these procs are useful for non-shuttles, rename it to proc/rotate and move it to be a generic atom proc
*/

/************************************Base proc************************************/

/atom/proc/shuttleRotate(rotation, params=ROTATE_DIR|ROTATE_SMOOTH|ROTATE_OFFSET)
	if(params & ROTATE_DIR)
		//rotate our direction
		setDir(angle2dir(rotation+dir2angle(dir)))

	//resmooth if need be.
	if(params & ROTATE_SMOOTH && smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)

	//rotate the pixel offsets too.
	if((pixel_x || pixel_y) && (params & ROTATE_OFFSET))
		if(rotation < 0)
			rotation += 360
		for(var/turntimes=rotation/90;turntimes>0;turntimes--)
			var/oldPX = pixel_x
			var/oldPY = pixel_y
			pixel_x = oldPY
			pixel_y = (oldPX*(-1))


/atom/movable/shuttleRotate(rotation, params)
	. = ..()
	//rotate the physical bounds and offsets for multitile atoms too. Override base "rotate the pixel offsets" for multitile atoms.
	//Override non zero bound_x, bound_y, pixel_x, pixel_y to zero.
	//Dont take in account starting bound_x, bound_y, pixel_x, pixel_y.
	//So it can unintentionally shift physical bounds of things that starts with non zero bound_x, bound_y.
	if((bound_height != world.icon_size || bound_width != world.icon_size) && (bound_x == 0) && (bound_y == 0)) //Dont shift things that have non zero bound_x and bound_y, or it move somewhere.
		pixel_x = dir & (NORTH|EAST) ? (world.icon_size - bound_width) : 0
		pixel_y = dir & (NORTH|WEST) ? (world.icon_size - bound_width) : 0
		bound_x = pixel_x
		bound_y = pixel_y

/************************************Turf rotate procs************************************/

/************************************Mob rotate procs************************************/

//override to avoid rotating pixel_xy on mobs
/mob/shuttleRotate(rotation, params)
	params = NONE
	. = ..()
	if(!buckled)
		setDir(angle2dir(rotation+dir2angle(dir)))

/mob/dead/observer/shuttleRotate(rotation, params)
	. = ..()
	update_icons()

/************************************Structure rotate procs************************************/

/obj/structure/cable/shuttleRotate(rotation, params)
	params &= ~ROTATE_DIR
	. = ..()
	if(d1)
		d1 = angle2dir(rotation+dir2angle(d1))
	if(d2)
		d2 = angle2dir(rotation+dir2angle(d2))

	//d1 should be less than d2 for cable icons to work
	if(d1 > d2)
		var/temp = d1
		d1 = d2
		d2 = temp
	update_icon(UPDATE_ICON_STATE)

//Fixes dpdir on shuttle rotation
/obj/structure/disposalpipe/shuttleRotate(rotation, params)
	. = ..()
	var/new_dpdir = 0
	for(var/D in list(NORTH, SOUTH, EAST, WEST))
		if(dpdir & D)
			new_dpdir = new_dpdir | angle2dir(rotation+dir2angle(D))
	dpdir = new_dpdir

/obj/structure/alien/weeds/shuttleRotate(rotation, params)
	params &= ~ROTATE_OFFSET
	return ..()

//prevents shuttles attempting to rotate this since it messes up sprites
/obj/structure/table/shuttleRotate(rotation, params)
	params = NONE
	return ..()

/obj/structure/table_frame/shuttleRotate(rotation, params)
	params = NONE
	return ..()

/************************************Machine rotate procs************************************/

//prevents shuttles attempting to rotate this since it messes up sprites
/obj/machinery/gravity_generator/shuttleRotate(rotation, params)
	params = NONE
	return ..()

// Updates airlocks' icon
/obj/machinery/door/shuttleRotate(rotation, params)
	..()
	update_bounds()

/obj/structure/door_assembly/multi_tile/shuttleRotate(rotation, params)
	..()
	update_bounds()
