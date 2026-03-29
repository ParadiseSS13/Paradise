/turf/space/transit
	icon_state = "black"

/turf/space/transit/Initialize(mapload)
	. = ..()
	// We don't want people building rods in space.
	RegisterSignal(src, COMSIG_ATTACK_BY, TYPE_PROC_REF(/datum, signal_cancel_attack_by))
	update_icon(UPDATE_ICON_STATE)

/// moving to the north
/turf/space/transit/north

/// moving to the south
/turf/space/transit/south
	dir = NORTH

/// moving to the east
/turf/space/transit/east
	dir = WEST

/// moving to the west
/turf/space/transit/west
	dir = EAST

/**
 * @DEPRECATED TYPE
 */
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
