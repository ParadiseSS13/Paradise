//use this define to highlight docking port bounding boxes (ONLY FOR DEBUG USE)
// also uncomment the #undef at the bottom of the file
//#define DOCKING_PORT_HIGHLIGHT

//NORTH default dir
/obj/docking_port
	invisibility = 101
	icon = 'icons/obj/device.dmi'
	//icon = 'icons/dirsquare.dmi'
	icon_state = "pinonfar"

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE

	var/id
	dir = NORTH		//this should point -away- from the dockingport door, ie towards the ship
	var/width = 0	//size of covered area, perpendicular to dir
	var/height = 0	//size of covered area, paralell to dir
	var/dwidth = 0	//position relative to covered area, perpendicular to dir
	var/dheight = 0	//position relative to covered area, parallel to dir

	// A timid shuttle will not register itself with the shuttle subsystem
	// All shuttle templates are timid
	var/timid = FALSE

	var/list/ripples = list()
	var/hidden = FALSE //are we invisible to shuttle navigation computers?

	//these objects are indestructable
/obj/docking_port/Destroy(force)
	if(force)
		..()
		. = QDEL_HINT_HARDDEL_NOW
	else

		return QDEL_HINT_LETMELIVE

/obj/docking_port/take_damage()
	return

/obj/docking_port/singularity_pull()
	return

/obj/docking_port/singularity_act()
	return 0

/obj/docking_port/shuttleRotate()
	return //we don't rotate with shuttles via this code.

//returns a list(x0,y0, x1,y1) where points 0 and 1 are bounding corners of the projected rectangle
/obj/docking_port/proc/return_coords(_x, _y, _dir)
	if(!_dir)
		_dir = dir
	if(!_x)
		_x = x
	if(!_y)
		_y = y

	//byond's sin and cos functions are inaccurate. This is faster and perfectly accurate
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	return list(
		_x + (-dwidth*cos) - (-dheight*sin),
		_y + (-dwidth*sin) + (-dheight*cos),
		_x + (-dwidth+width-1)*cos - (-dheight+height-1)*sin,
		_y + (-dwidth+width-1)*sin + (-dheight+height-1)*cos
		)

//returns turfs within our projected rectangle in no particular order
/obj/docking_port/proc/return_turfs()
	var/list/L = return_coords()
	var/turf/T0 = locate(L[1], L[2], z)
	var/turf/T1 = locate(L[3], L[4], z)
	return block(T0, T1)

//returns turfs within our projected rectangle in a specific order.
//this ensures that turfs are copied over in the same order, regardless of any rotation
/obj/docking_port/proc/return_ordered_turfs(_x, _y, _z, _dir, area/A)
	if(!_dir)
		_dir = dir
	if(!_x)
		_x = x
	if(!_y)
		_y = y
	if(!_z)
		_z = z
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	. = list()

	var/xi
	var/yi
	for(var/dx=0, dx<width, ++dx)
		for(var/dy=0, dy<height, ++dy)
			xi = _x + (dx-dwidth)*cos - (dy-dheight)*sin
			yi = _y + (dy-dheight)*cos + (dx-dwidth)*sin
			var/turf/T = locate(xi, yi, _z)
			if(A)
				if(get_area(T) == A)
					. += T
				else
					. += null
			else
				. += T

#ifdef DOCKING_PORT_HIGHLIGHT
//Debug proc used to highlight bounding area
/obj/docking_port/proc/highlight(_color)
	var/list/L = return_coords()
	var/turf/T0 = locate(L[1],L[2],z)
	var/turf/T1 = locate(L[3],L[4],z)
	for(var/turf/T in block(T0,T1))
		T.color = _color
		T.maptext = null
	if(_color)
		var/turf/T = locate(L[1], L[2], z)
		T.color = "#0f0"
		T = locate(L[3], L[4], z)
		T.color = "#00f"
#endif

//return first-found touching dockingport
/obj/docking_port/proc/get_docked()
	return locate(/obj/docking_port/stationary) in loc

/obj/docking_port/proc/getDockedId()
	var/obj/docking_port/P = get_docked()
	if(P) return P.id

/obj/docking_port/proc/register()
	return 0

/obj/docking_port/stationary
	name = "dock"

	var/turf_type = /turf/space
	var/area_type = /area/space

	var/lock_shuttle_doors = 0

// Preset for adding whiteship docks to ruins. Has widths preset which will auto-assign the shuttle
/obj/docking_port/stationary/whiteship
	dwidth = 10
	height = 35
	width = 21

/obj/docking_port/stationary/register()
	if(!SSshuttle)
		stack_trace("Docking port [src] could not initialize. SSshuttle doesnt exist!")
		return FALSE

	SSshuttle.stationary += src
	if(!id)
		id = "[SSshuttle.stationary.len]"
	if(name == "dock")
		name = "dock[SSshuttle.stationary.len]"

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#f00")
	#endif
	return 1

//returns first-found touching shuttleport
/obj/docking_port/stationary/get_docked()
	return locate(/obj/docking_port/mobile) in loc
	/*
	for(var/turf/T in return_ordered_turfs())
		. = locate(/obj/docking_port/mobile) in loc
		if(.)
			return .
	*/

/obj/docking_port/stationary/transit
	name = "In transit"
	turf_type = /turf/space/transit
	lock_shuttle_doors = TRUE

/obj/docking_port/stationary/transit/register()
	if(!..())
		return 0

	name = "In transit" //This looks weird, but- it means that the on-map instances can be named something actually usable to search for, but still appear correctly in terminals.

	SSshuttle.transit += src
	return 1

/obj/docking_port/mobile
	icon_state = "mobile"
	name = "shuttle"
	icon_state = "pinonclose"

	var/area/shuttle/areaInstance
	var/list/shuttle_areas

	var/timer						//used as a timer (if you want time left to complete move, use timeLeft proc)
	var/last_timer_length
	var/mode = SHUTTLE_IDLE			//current shuttle mode (see global defines)
	var/callTime = 50				//time spent in transit (deciseconds)
	var/ignitionTime = 30			// time spent "starting the engines". Also rate limits how often we try to reserve transit space if its ever full of transiting shuttles.
	var/roundstart_move				//id of port to send shuttle to at roundstart
	var/travelDir = 0				//direction the shuttle would travel in
	var/rebuildable = 0				//can build new shuttle consoles for this one

	var/mob/last_caller				// Who called the shuttle the last time

	var/obj/docking_port/stationary/destination
	var/obj/docking_port/stationary/previous
	/// Does this shuttle use the lockdown system?
	var/uses_lockdown = FALSE
	/// If this variable is true, shuttle is on lockdown, and other requests can not be processed
	var/lockeddown = FALSE

/obj/docking_port/mobile/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(istype(A, /area/shuttle))
		areaInstance = A

	if(!areaInstance)
		areaInstance = new()
		areaInstance.name = name
		areaInstance.contents += return_ordered_turfs()

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#0f0")
	#endif

	if(!timid)
		register()
	shuttle_areas = list()
	var/list/all_turfs = return_ordered_turfs(x, y, z, dir)
	for(var/i in 1 to all_turfs.len)
		var/turf/curT = all_turfs[i]
		var/area/cur_area = curT.loc
		if(istype(cur_area, areaInstance))
			shuttle_areas[cur_area] = TRUE

/obj/docking_port/mobile/register()
	if(!SSshuttle)
		CRASH("Docking port [src] could not initialize. SSshuttle doesnt exist!")

	SSshuttle.mobile += src

	if(!id)
		id = "[SSshuttle.mobile.len]"
	if(name == "shuttle")
		name = "shuttle[SSshuttle.mobile.len]"

	return 1

/obj/docking_port/mobile/Destroy(force)
	if(force)
		SSshuttle.mobile -= src
		areaInstance = null
		destination = null
		previous = null
		shuttle_areas = null
	return ..()

//this is a hook for custom behaviour. Maybe at some point we could add checks to see if engines are intact
/obj/docking_port/mobile/proc/canMove()
	return 0	//0 means we can move

//this is to check if this shuttle can physically dock at dock S
/obj/docking_port/mobile/proc/canDock(obj/docking_port/stationary/S)
	if(!istype(S))
		return SHUTTLE_NOT_A_DOCKING_PORT
	if(istype(S, /obj/docking_port/stationary/transit))
		return SHUTTLE_CAN_DOCK
	//check dock is big enough to contain us
	if(dwidth > S.dwidth)
		return SHUTTLE_DWIDTH_TOO_LARGE
	if(width-dwidth > S.width-S.dwidth)
		return SHUTTLE_WIDTH_TOO_LARGE
	if(dheight > S.dheight)
		return SHUTTLE_DHEIGHT_TOO_LARGE
	if(height-dheight > S.height-S.dheight)
		return SHUTTLE_HEIGHT_TOO_LARGE
	//check the dock isn't occupied
	var/currently_docked = S.get_docked()
	if(currently_docked)
		// by someone other than us
		if(currently_docked != src)
			return SHUTTLE_SOMEONE_ELSE_DOCKED
		else
		// This isn't an error, per se, but we can't let the shuttle code
		// attempt to move us where we currently are, it will get weird.
			return SHUTTLE_ALREADY_DOCKED
	return SHUTTLE_CAN_DOCK

/obj/docking_port/mobile/proc/check_dock(obj/docking_port/stationary/S)
	var/status = canDock(S)
	if(status == SHUTTLE_CAN_DOCK)
		return TRUE
	else if(status == SHUTTLE_ALREADY_DOCKED)
		// We're already docked there, don't need to do anything.
		// Triggering shuttle movement code in place is weird
		return FALSE
	else
		var/msg = "check_dock(): shuttle [src] cannot dock at [S], error: [status]"
		message_admins(msg)
		stack_trace(msg)
		return FALSE


//call the shuttle to destination S
/obj/docking_port/mobile/proc/request(obj/docking_port/stationary/S)

	if(!check_dock(S))
		return

	switch(mode)
		if(SHUTTLE_CALL)
			if(S == destination)
				if(timeLeft(1) < callTime)
					setTimer(callTime)
			else
				destination = S
				setTimer(callTime)
		if(SHUTTLE_RECALL)
			if(S == destination)
				setTimer(callTime - timeLeft(1))
			else
				destination = S
				setTimer(callTime)
			mode = SHUTTLE_CALL
		if(SHUTTLE_IDLE, SHUTTLE_IGNITING)
			destination = S
			mode = SHUTTLE_IGNITING
			setTimer(ignitionTime)

//recall the shuttle to where it was previously
/obj/docking_port/mobile/proc/cancel()
	if(mode != SHUTTLE_CALL)
		return

	timer = world.time - timeLeft(1)
	mode = SHUTTLE_RECALL

/obj/docking_port/mobile/proc/enterTransit()
	previous = null
//		if(!destination)
//			return
	var/obj/docking_port/stationary/S0 = get_docked()
	var/obj/docking_port/stationary/S1 = findTransitDock()
	if(S1)
		if(dock(S1, , TRUE))
			WARNING("shuttle \"[id]\" could not enter transit space. Docked at [S0 ? S0.id : "null"]. Transit dock [S1 ? S1.id : "null"].")
		else
			previous = S0
	else
		WARNING("shuttle \"[id]\" could not enter transit space. S0=[S0 ? S0.id : "null"] S1=[S1 ? S1.id : "null"]")



/obj/docking_port/mobile/proc/jumpToNullSpace()
	// Destroys the docking port and the shuttle contents.
	// Not in a fancy way, it just ceases.
	var/obj/docking_port/stationary/S0 = get_docked()
	var/turf_type = /turf/space
	var/area_type = /area/space
	if(S0)
		if(S0.turf_type)
			turf_type = S0.turf_type
		if(S0.area_type)
			area_type = S0.area_type

	var/list/L0 = return_ordered_turfs(x, y, z, dir, areaInstance)

	//remove area surrounding docking port
	if(areaInstance.contents.len)
		var/area/A0 = locate("[area_type]")
		if(!A0)
			A0 = new area_type(null)
		for(var/turf/T0 in L0)
			A0.contents += T0

	for(var/i in L0)
		var/turf/T0 = i
		if(!T0)
			continue
		T0.empty(turf_type)

	qdel(src, force=TRUE)

/obj/docking_port/mobile/proc/create_ripples(obj/docking_port/stationary/S1)
	var/list/turfs = ripple_area(S1)
	for(var/i in turfs)
		ripples += new /obj/effect/temp_visual/ripple(i)

/obj/docking_port/mobile/proc/remove_ripples()
	if(ripples.len)
		for(var/i in ripples)
			qdel(i)
		ripples.Cut()


/obj/docking_port/mobile/proc/ripple_area(obj/docking_port/stationary/S1)
	var/list/L0 = return_ordered_turfs(x, y, z, dir, areaInstance)
	var/list/L1 = return_ordered_turfs(S1.x, S1.y, S1.z, S1.dir)

	var/list/ripple_turfs = list()

	for(var/i in 1 to L0.len)
		var/turf/T0 = L0[i]
		if(!T0)
			continue
		var/turf/T1 = L1[i]
		if(!T1)
			continue
		if(T0.type != T0.baseturf)
			ripple_turfs += T1

	return ripple_turfs

//this is the main proc. It instantly moves our mobile port to stationary port S1
//it handles all the generic behaviour, such as sanity checks, closing doors on the shuttle, stunning mobs, etc
/obj/docking_port/mobile/proc/dock(obj/docking_port/stationary/S1, force=FALSE, transit=FALSE)
	// Crashing this ship with NO SURVIVORS
	if(S1.get_docked() == src)
		remove_ripples()
		return

	if(!force)
		if(!check_dock(S1))
			return -1

		if(canMove())
			return -1

	var/obj/docking_port/stationary/S0 = get_docked()
	var/turf_type = /turf/space
	var/area_type = /area/space
	if(S0)
		if(S0.turf_type)
			turf_type = S0.turf_type
		if(S0.area_type)
			area_type = S0.area_type

	//close and lock the dock's airlocks
	closePortDoors(S0)

	var/list/L0 = return_ordered_turfs(x, y, z, dir, areaInstance)
	var/list/L1 = return_ordered_turfs(S1.x, S1.y, S1.z, S1.dir)

	var/rotation = dir2angle(S1.dir)-dir2angle(dir)
	if((rotation % 90) != 0)
		rotation += (rotation % 90) //diagonal rotations not allowed, round up
	rotation = SIMPLIFY_DEGREES(rotation)

	//remove area surrounding docking port
	if(areaInstance.contents.len)
		var/area/A0 = locate("[area_type]")
		if(!A0)
			A0 = new area_type(null)
		for(var/turf/T0 in L0)
			A0.contents += T0

	// Removes ripples
	remove_ripples()

	//move or squish anything in the way ship at destination
	roadkill(L0, L1, S1.dir)

	for(var/i in 1 to L0.len)
		var/turf/T0 = L0[i]
		if(!T0)
			continue
		var/turf/T1 = L1[i]
		if(!T1)
			continue

		areaInstance.contents += T1

		var/should_transit = !is_turf_blacklisted_for_transit(T0)
		if(should_transit) // Only move over stuff if the transfer actually happened
			T0.copyTurf(T1)

			//copy over air
			if(issimulatedturf(T1))
				var/turf/simulated/Ts1 = T1
				Ts1.copy_air_with_tile(T0)

			//move mobile to new location
			for(var/atom/movable/AM in T0)
				AM.onShuttleMove(T0, T1, rotation, last_caller)

			if(rotation)
				T1.shuttleRotate(rotation)

		// Always do this stuff as it ensures that the destination turfs still behave properly with the rest of the shuttle transit
		//atmos and lighting stuff
		SSair.remove_from_active(T1)
		T1.CalculateAdjacentTurfs()
		SSair.add_to_active(T1,1)

		T1.lighting_build_overlay()

		if(!should_transit)
			continue // Don't want to actually change the skipped turf
		T0.ChangeTurf(turf_type, keep_icon = FALSE)

		SSair.remove_from_active(T0)
		T0.CalculateAdjacentTurfs()
		SSair.add_to_active(T0,1)

	areaInstance.moving = transit
	for(var/A1 in L1)
		var/turf/T1 = A1
		T1.postDock(S1)
		for(var/atom/movable/M in T1)
			M.postDock(S1)

	loc = S1.loc
	dir = S1.dir

	//update mining and labor shuttle ash storm audio
	if(id in list("mining", "laborcamp"))
		var/mining_zlevel = level_name_to_num(MINING)
		var/datum/weather/ash_storm/W = SSweather.get_weather(mining_zlevel, /area/lavaland/surface/outdoors)
		if(W)
			W.update_eligible_areas()
			W.update_audio()

	unlockPortDoors(S1)

/obj/docking_port/mobile/proc/is_turf_blacklisted_for_transit(turf/T)
	var/static/list/blacklisted_turf_types = typecacheof(list(/turf/space, /turf/simulated/floor/chasm, /turf/simulated/floor/plating/lava, /turf/simulated/floor/plating/asteroid))
	return is_type_in_typecache(T, blacklisted_turf_types)


/obj/docking_port/mobile/proc/findTransitDock()
	var/obj/docking_port/stationary/transit/T = SSshuttle.getDock("[id]_transit")
	if(T && check_dock(T))
		return T


/obj/docking_port/mobile/proc/findRoundstartDock()
	var/obj/docking_port/stationary/D
	D = SSshuttle.getDock(roundstart_move)

	if(D)
		return D

/obj/docking_port/mobile/proc/dockRoundstart()
	// Instead of spending a lot of time trying to work out where to place
	// our shuttle, just create it somewhere empty and send it to where
	// it should go
	. = dock_id(roundstart_move)

/obj/docking_port/mobile/proc/dock_id(id)
	var/port = SSshuttle.getDock(id)
	if(port)
		. = dock(port)
	else
		. = null

/obj/effect/landmark/shuttle_import
	name = "Shuttle Import"



//shuttle-door closing is handled in the dock() proc whilst looping through turfs
//this one closes the door where we are docked at, if there is one there.
/obj/docking_port/mobile/proc/closePortDoors(obj/docking_port/stationary/S0)
	if(!istype(S0))
		return 1

	for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
		if(A.id_tag == S0.id)
			spawn(-1)
				A.close()
				A.lock()

/obj/docking_port/mobile/proc/unlockPortDoors(obj/docking_port/stationary/S1)
	if(!istype(S1))
		return 0

	for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
		if(A.id_tag == S1.id)
			spawn(-1)
				if(A.locked)
					A.unlock()

/obj/docking_port/mobile/proc/roadkill(list/L0, list/L1, dir)
	for(var/i in 1 to L0.len)
		var/turf/T0 = L0[i]
		var/turf/T1 = L1[i]
		if(!T0 || !T1)
			continue

		for(var/atom/movable/AM in T1)
			if(AM.pulledby)
				AM.pulledby.stop_pulling()
			if(AM.flags_2 & IMMUNE_TO_SHUTTLECRUSH_2)
				continue
			if(ismob(AM))
				var/mob/M = AM
				if(M.buckled)
					M.buckled.unbuckle_mob(M, force = TRUE)
				if(isliving(AM))
					var/mob/living/L = AM
					L.stop_pulling()
					L.visible_message("<span class='warning'>[L] is hit by \
									a hyperspace ripple!</span>",
									"<span class='userdanger'>You feel an immense \
									crushing pressure as the space around you ripples.</span>")
					L.gib()

			// Move unanchored atoms
			if(!AM.anchored && !ismob(AM))
				step(AM, dir)
			else
				if(AM.simulated) // Don't qdel lighting overlays, they are static
					qdel(AM)

//used by shuttle subsystem to check timers
/obj/docking_port/mobile/proc/check()
	check_effects()

	var/timeLeft = timeLeft(1)

	if(timeLeft <= 0)
		switch(mode)
			if(SHUTTLE_CALL)
				if(dock(destination))
					setTimer(20)	//can't dock for some reason, try again in 2 seconds
					return
			if(SHUTTLE_RECALL)
				if(dock(previous))
					setTimer(20)	//can't dock for some reason, try again in 2 seconds
					return
			if(SHUTTLE_IGNITING)
				mode = SHUTTLE_CALL
				setTimer(callTime)
				enterTransit()
				return
		mode = SHUTTLE_IDLE
		timer = 0
		destination = null

/obj/docking_port/mobile/proc/check_effects()
	if(!ripples.len)
		if((mode == SHUTTLE_CALL) || (mode == SHUTTLE_RECALL))
			var/tl = timeLeft(1)
			if(tl <= SHUTTLE_RIPPLE_TIME)
				create_ripples(destination)

/obj/docking_port/mobile/proc/setTimer(wait)
	if(timer <= 0)
		timer = world.time
	timer += wait - timeLeft(1)

/obj/docking_port/mobile/proc/modTimer(multiple)
	var/time_remaining = timer - world.time
	if(time_remaining < 0 || !last_timer_length)
		return
	time_remaining *= multiple
	last_timer_length *= multiple
	setTimer(time_remaining)

/obj/docking_port/mobile/proc/invertTimer()
	if(!last_timer_length)
		return
	var/time_remaining = timer - world.time
	if(time_remaining > 0)
		var/time_passed = last_timer_length - time_remaining
		setTimer(time_passed)

//returns timeLeft
/obj/docking_port/mobile/proc/timeLeft(divisor)
	if(divisor <= 0)
		divisor = 10
	if(!timer)
		return round(callTime/divisor, 1)
	return max( round((timer+callTime-world.time)/divisor,1), 0 )

// returns 3-letter mode string, used by status screens and mob status panel
/obj/docking_port/mobile/proc/getModeStr()
	switch(mode)
		if(SHUTTLE_RECALL)
			return "RCL"
		if(SHUTTLE_CALL)
			return "ETA"
		if(SHUTTLE_DOCKED)
			return "ETD"
		if(SHUTTLE_ESCAPE)
			return "ESC"
		if(SHUTTLE_STRANDED)
			return "ERR"
	return ""

// returns 5-letter timer string, used by status screens and mob status panel
/obj/docking_port/mobile/proc/getTimerStr()
	if(mode == SHUTTLE_STRANDED)
		return "--:--"

	var/timeleft = timeLeft()
	if(timeleft > 0)
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	else
		return "00:00"

/obj/docking_port/mobile/proc/getStatusText()
	var/obj/docking_port/stationary/dockedAt = get_docked()
	. = (dockedAt && dockedAt.name) ? dockedAt.name : "unknown"
	if(istype(dockedAt, /obj/docking_port/stationary/transit))
		var/obj/docking_port/stationary/dst
		if(mode == SHUTTLE_RECALL)
			dst = previous
		else
			dst = destination
		. += " towards [dst ? dst.name : "unknown location"] ([timeLeft(600)]mins)"

/obj/docking_port/mobile/labour
	dir = 8
	dwidth = 2
	height = 5
	id = "laborcamp"
	name = "labor camp shuttle"
	rebuildable = TRUE
	width = 9
	uses_lockdown = TRUE

/obj/docking_port/mobile/mining
	dir = 8
	dwidth = 3
	height = 5
	id = "mining"
	name = "mining shuttle"
	rebuildable = TRUE
	width = 7
	uses_lockdown = TRUE

/obj/machinery/computer/shuttle
	name = "Shuttle Console"
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	req_access = list()
	circuit = /obj/item/circuitboard/shuttle
	var/shuttleId
	var/possible_destinations = ""
	var/admin_controlled
	var/max_connect_range = 7
	var/moved = FALSE	//workaround for nukie shuttle, hope I find a better way to do this...

/obj/machinery/computer/shuttle/New(location, obj/item/circuitboard/shuttle/C)
	..()
	if(istype(C))
		possible_destinations = C.possible_destinations
		shuttleId = C.shuttleId

/obj/machinery/computer/shuttle/Initialize(mapload)
	. = ..()
	connect()

/obj/machinery/computer/shuttle/proc/connect()
	var/obj/docking_port/mobile/M
	if(!shuttleId)
		// find close shuttle that is ok to mess with
		if(!SSshuttle) //intentionally mapping shuttle consoles without actual shuttles IS POSSIBLE OH MY GOD WHO KNEW *glare*
			return
		for(var/obj/docking_port/mobile/D in SSshuttle.mobile)
			if(get_dist(src, D) <= max_connect_range && D.rebuildable)
				M = D
				shuttleId = M.id
				break
	else if(!possible_destinations && SSshuttle) //possible destinations should **not** always exist; so, if it's specifically set to null, don't make it exist
		M = SSshuttle.getShuttle(shuttleId)

	if(M && !possible_destinations)
		// find perfect fits
		possible_destinations = ""
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!istype(S, /obj/docking_port/stationary/transit) && S.width == M.width && S.height == M.height && S.dwidth == M.dwidth && S.dheight == M.dheight && findtext(S.id, M.id))
				possible_destinations += "[possible_destinations ? ";" : ""][S.id]"

/obj/machinery/computer/shuttle/attack_hand(mob/user)
	if(..(user))
		return
	if(!shuttleId)
		return
	connect()
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/shuttle/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ShuttleConsole", name, 350, 150, master_ui, state)
		ui.open()

/obj/machinery/computer/shuttle/ui_data(mob/user)
	var/list/data = list()
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	data["status"] = M ? M.getStatusText() : null
	if(M)
		data["shuttle"] = TRUE	//this should just be boolean, right?
		var/list/docking_ports = list()
		data["docking_ports"] = docking_ports
		var/list/options = params2list(possible_destinations)
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S))
				continue
			docking_ports[++docking_ports.len] = list("name" = S.name, "id" = S.id)
		data["docking_ports_len"] = docking_ports.len
		data["admin_controlled"] = admin_controlled
	return data

/obj/machinery/computer/shuttle/ui_act(action, params)
	if(..())	//we can't actually interact, so no action
		return TRUE
	if(!allowed(usr))
		to_chat(usr, "<span class='danger'>Access denied.</span>")
		return	TRUE
	if(!can_call_shuttle(usr, action))
		return TRUE
	var/list/options = params2list(possible_destinations)
	if(action == "move")
		var/destination = params["move"]
		if(!options.Find(destination))//figure out if this translation works
			message_admins("<span class='boldannounce'>EXPLOIT:</span> [ADMIN_LOOKUPFLW(usr)] attempted to move [src] to an invalid location! [ADMIN_COORDJMP(src)]")
			return
		switch(SSshuttle.moveShuttle(shuttleId, destination, TRUE, usr))
			if(0)
				atom_say("Shuttle departing! Please stand away from the doors.")
				usr.create_log(MISC_LOG, "used [src] to call the [shuttleId] shuttle")
				if(!moved)
					moved = TRUE
				add_fingerprint(usr)
				return TRUE
			if(1)
				to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
			if(2)
				to_chat(usr, "<span class='notice'>Unable to comply.</span>")
			if(3)
				atom_say("Shuttle has already received a pending movement request. Please wait until the movement request is processed.")


/obj/machinery/computer/shuttle/emag_act(mob/user)
	if(!emagged)
		src.req_access = list()
		emagged = TRUE
		to_chat(user, "<span class='notice'>You fried the consoles ID checking system.</span>")

//for restricting when the computer can be used, needed for some console subtypes.
/obj/machinery/computer/shuttle/proc/can_call_shuttle(mob/user, action)
	return TRUE

/obj/machinery/computer/shuttle/ferry
	name = "transport ferry console"
	circuit = /obj/item/circuitboard/ferry
	shuttleId = "ferry"
	possible_destinations = "ferry_home;ferry_away"


/obj/machinery/computer/shuttle/ferry/request
	name = "ferry console"
	circuit = /obj/item/circuitboard/ferry/request
	var/next_request	//to prevent spamming admins
	possible_destinations = "ferry_home"
	admin_controlled = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/computer/shuttle/ferry/request/ui_act(action, params)
	if(..())	// Note that the parent handels normal shuttle movement on top of security checks
		return
	if(action == "request")
		if(world.time < next_request)
			return
		next_request = world.time + 60 SECONDS	//1 minute cooldown
		to_chat(usr, "<span class='notice'>Your request has been received by Centcom.</span>")
		log_admin("[key_name(usr)] requested to move the transport ferry to Centcom.")
		message_admins("<b>FERRY: <font color='#EB4E00'>[key_name_admin(usr)] (<A HREF='?_src_=holder;secretsfun=moveferry'>Move Ferry</a>)</b> is requesting to move the transport ferry to Centcom.</font>")
		return TRUE


/obj/machinery/computer/shuttle/white_ship
	name = "White Ship Console"
	desc = "Used to control the White Ship."
	circuit = /obj/item/circuitboard/white_ship
	shuttleId = "whiteship"
	possible_destinations = null // Set at runtime

/obj/machinery/computer/shuttle/white_ship/Initialize(mapload)
	if(mapload)
		return INITIALIZE_HINT_LATELOAD
	return ..()

// Yes. This is disgusting, but the console needs to be loaded AFTER the docking ports load.
/obj/machinery/computer/shuttle/white_ship/LateInitialize()
	Initialize()

/obj/machinery/computer/shuttle/engineering
	name = "Engineering Shuttle Console"
	desc = "Used to call and send the engineering shuttle."
	shuttleId = "engineering"
	possible_destinations = "engineering_home;engineering_away"

/obj/machinery/computer/shuttle/science
	name = "Science Shuttle Console"
	desc = "Used to call and send the science shuttle."
	shuttleId = "science"
	possible_destinations = "science_home;science_away"

/obj/machinery/computer/shuttle/admin
	name = "admin shuttle console"
	req_access = list(ACCESS_CENT_GENERAL)
	shuttleId = "admin"
	possible_destinations = "admin_home;admin_away;admin_custom"
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/camera_advanced/shuttle_docker/admin
	name = "Admin shuttle navigation computer"
	desc = "Used to designate a precise transit location for the admin shuttle."
	icon_screen = "navigation"
	icon_keyboard = "med_key"
	shuttleId = "admin"
	shuttlePortId = "admin_custom"
	view_range = 14
	x_offset = 0
	y_offset = 0
	resistance_flags = INDESTRUCTIBLE
	access_mining = TRUE

/obj/machinery/computer/shuttle/trade
	name = "Freighter Console"
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/shuttle/trade/sol
	req_access = list(ACCESS_TRADE_SOL)
	possible_destinations = "trade_sol_base;trade_dock"
	shuttleId = "trade_sol"

/obj/machinery/computer/shuttle/golem_ship
	name = "Golem Ship Console"
	desc = "Used to control the Golem Ship."
	circuit = /obj/item/circuitboard/shuttle/golem_ship
	shuttleId = "freegolem"
	possible_destinations = "freegolem_lavaland;freegolem_space;freegolem_ussp"

/obj/machinery/computer/shuttle/golem_ship/attack_hand(mob/user)
	if(!isgolem(user) && !isobserver(user))
		to_chat(user, "<span class='notice'>The console is unresponsive. Seems only golems can use it.</span>")
		return
	..()

/obj/machinery/computer/shuttle/golem_ship/recall
	name = "golem ship recall terminal"
	desc = "Used to recall the Golem Ship."
	possible_destinations = "freegolem_lavaland"
	resistance_flags = INDESTRUCTIBLE

//#undef DOCKING_PORT_HIGHLIGHT

/turf/proc/copyTurf(turf/T)
	if(T.type != type)
		var/obj/O
		if(underlays.len)	//we have underlays, which implies some sort of transparency, so we want to a snapshot of the previous turf as an underlay
			O = new()
			O.underlays.Add(T)
		T.ChangeTurf(type, keep_icon = FALSE)
		if(underlays.len)
			T.underlays = O.underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		if(length(atom_colours))
			T.atom_colours = atom_colours.Copy()
			T.update_atom_colour()
		else
			T.color = color // If you don't have atom_colours then you're working off an absolute color
	if(light)
		T.set_light(light_range, light_power, light_color)
	if(T.dir != dir)
		T.setDir(dir)
	TransferComponents(T)
	return T
