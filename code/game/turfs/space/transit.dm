/turf/space/transit
	var/pushdirection // push things that get caught in the transit tile this direction
	plane = PLANE_SPACE

//Overwrite because we dont want people building rods in space.
/turf/space/transit/attackby(obj/O as obj, mob/user as mob, params)
	return

/// moving to the north
/turf/space/transit/north

	pushdirection = SOUTH  // south because the space tile is scrolling south

	//IF ANYONE KNOWS A MORE EFFICIENT WAY OF MANAGING THESE SPRITES, BE MY GUEST.
/turf/space/transit/north/shuttlespace_ns1
	icon_state = "speedspace_ns_1"

/turf/space/transit/north/shuttlespace_ns2
	icon_state = "speedspace_ns_2"

/turf/space/transit/north/shuttlespace_ns3
	icon_state = "speedspace_ns_3"

/turf/space/transit/north/shuttlespace_ns4
	icon_state = "speedspace_ns_4"

/turf/space/transit/north/shuttlespace_ns5
	icon_state = "speedspace_ns_5"

/turf/space/transit/north/shuttlespace_ns6
	icon_state = "speedspace_ns_6"

/turf/space/transit/north/shuttlespace_ns7
	icon_state = "speedspace_ns_7"

/turf/space/transit/north/shuttlespace_ns8
	icon_state = "speedspace_ns_8"

/turf/space/transit/north/shuttlespace_ns9
	icon_state = "speedspace_ns_9"

/turf/space/transit/north/shuttlespace_ns10
	icon_state = "speedspace_ns_10"

/turf/space/transit/north/shuttlespace_ns11
	icon_state = "speedspace_ns_11"

/turf/space/transit/north/shuttlespace_ns12
	icon_state = "speedspace_ns_12"

/turf/space/transit/north/shuttlespace_ns13
	icon_state = "speedspace_ns_13"

/turf/space/transit/north/shuttlespace_ns14
	icon_state = "speedspace_ns_14"

/turf/space/transit/north/shuttlespace_ns15
	icon_state = "speedspace_ns_15"

/// moving to the east
/turf/space/transit/east
	pushdirection = WEST

/turf/space/transit/east/shuttlespace_ew1
	icon_state = "speedspace_ew_1"

/turf/space/transit/east/shuttlespace_ew2
	icon_state = "speedspace_ew_2"

/turf/space/transit/east/shuttlespace_ew3
	icon_state = "speedspace_ew_3"

/turf/space/transit/east/shuttlespace_ew4
	icon_state = "speedspace_ew_4"

/turf/space/transit/east/shuttlespace_ew5
	icon_state = "speedspace_ew_5"

/turf/space/transit/east/shuttlespace_ew6
	icon_state = "speedspace_ew_6"

/turf/space/transit/east/shuttlespace_ew7
	icon_state = "speedspace_ew_7"

/turf/space/transit/east/shuttlespace_ew8
	icon_state = "speedspace_ew_8"

/turf/space/transit/east/shuttlespace_ew9
	icon_state = "speedspace_ew_9"

/turf/space/transit/east/shuttlespace_ew10
	icon_state = "speedspace_ew_10"

/turf/space/transit/east/shuttlespace_ew11
	icon_state = "speedspace_ew_11"

/turf/space/transit/east/shuttlespace_ew12
	icon_state = "speedspace_ew_12"

/turf/space/transit/east/shuttlespace_ew13
	icon_state = "speedspace_ew_13"

/turf/space/transit/east/shuttlespace_ew14
	icon_state = "speedspace_ew_14"

/turf/space/transit/east/shuttlespace_ew15
	icon_state = "speedspace_ew_15"
//-tg- stuff

/turf/space/transit
	icon_state = "black"
	dir = SOUTH

/turf/space/transit/horizontal
	dir = WEST

/turf/space/transit/Entered(atom/movable/AM, atom/OldLoc, ignoreRest = 0)
	if(!AM)
		return
	if(!AM.simulated || istype(AM, /obj/docking_port))
		return //this was fucking hilarious, the docking ports were getting thrown to random Z-levels
	var/max = world.maxx-TRANSITIONEDGE
	var/min = 1+TRANSITIONEDGE

	//now select coordinates for a border turf
	var/_x
	var/_y
	switch(dir)
		if(SOUTH)
			_x = rand(min,max)
			_y = max
		if(WEST)
			_x = max
			_y = rand(min,max)
		if(EAST)
			_x = min
			_y = rand(min,max)
		else
			_x = rand(min,max)
			_y = min

	var/list/levels_available = get_all_linked_levels_zpos()
	var/turf/T = locate(_x, _y, pick(levels_available))
	AM.forceMove(T)
	AM.newtonian_move(dir)


/turf/space/transit/rpd_act()
	return

//Overwrite because we dont want people building rods in space.
/turf/space/transit/attackby()
	return

/turf/space/transit/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/turf/space/transit/update_icon_state()
	var/p = 9
	var/angle = 0
	var/state = 1
	switch(dir)
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

	icon_state = "speedspace_ns_[state]"
	transform = turn(matrix(), angle)

/turf/space/transit/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/space.dmi'
	underlay_appearance.icon_state = SPACE_ICON_STATE
	underlay_appearance.plane = PLANE_SPACE
	return TRUE
