//use this define to highlight docking port bounding boxes (ONLY FOR DEBUG USE)
//#define DOCKING_PORT_HIGHLIGHT

//NORTH default dir
/obj/docking_port
	invisibility = 101
	icon = 'icons/obj/device.dmi'
	//icon = 'icons/dirsquare.dmi'
	icon_state = "pinonfar"

	unacidable = 1
	anchored = 1

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

	//these objects are indestructable
/obj/docking_port/Destroy(force)
	if(force)
		..()
		. = QDEL_HINT_HARDDEL_NOW
	else

		return QDEL_HINT_LETMELIVE

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

/obj/docking_port/stationary/register()
	if(!shuttle_master)
		throw EXCEPTION("docking port [src] could not initialize.")
		return 0

	shuttle_master.stationary += src
	if(!id)
		id = "[shuttle_master.stationary.len]"
	if(name == "dock")
		name = "dock[shuttle_master.stationary.len]"

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

	lock_shuttle_doors = 1

/obj/docking_port/stationary/transit/register()
	if(!..())
		return 0

	name = "In transit" //This looks weird, but- it means that the on-map instances can be named something actually usable to search for, but still appear correctly in terminals.

	shuttle_master.transit += src
	return 1

/obj/docking_port/mobile
	icon_state = "mobile"
	name = "shuttle"
	icon_state = "pinonclose"

	var/area/shuttle/areaInstance

	var/timer						//used as a timer (if you want time left to complete move, use timeLeft proc)
	var/mode = SHUTTLE_IDLE			//current shuttle mode (see global defines)
	var/callTime = 50				//time spent in transit (deciseconds)
	var/roundstart_move				//id of port to send shuttle to at roundstart
	var/travelDir = 0				//direction the shuttle would travel in
	var/rebuildable = 0				//can build new shuttle consoles for this one

	var/obj/docking_port/stationary/destination
	var/obj/docking_port/stationary/previous

/obj/docking_port/mobile/New()
	..()

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




/obj/docking_port/mobile/initialize()
	if(!timid)
		register()
	..()

/obj/docking_port/mobile/register()
	if(!shuttle_master)
		throw EXCEPTION("docking port [src] could not initialize.")
		return 0

	shuttle_master.mobile += src

	if(!id)
		id = "[shuttle_master.mobile.len]"
	if(name == "shuttle")
		name = "shuttle[shuttle_master.mobile.len]"

	return 1

/obj/docking_port/mobile/Destroy(force)
	if(force)
		shuttle_master.mobile -= src
		areaInstance = null
		destination = null
		previous = null
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
		throw EXCEPTION(msg)
		return FALSE


//call the shuttle to destination S
/obj/docking_port/mobile/proc/request(obj/docking_port/stationary/S)

	if(!check_dock(S))
		return

	switch(mode)
		if(SHUTTLE_CALL)
			if(S == destination)
				if(world.time <= timer)
					timer = world.time
			else
				destination = S
				timer = world.time
		if(SHUTTLE_RECALL)
			if(S == destination)
				timer = world.time - timeLeft(1)
			else
				destination = S
				timer = world.time
			mode = SHUTTLE_CALL
		else
			destination = S
			mode = SHUTTLE_CALL
			timer = world.time
			enterTransit()		//hyperspace

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
		if(dock(S1))
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
		ripples += new /obj/effect/overlay/temp/ripple(i)

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
/obj/docking_port/mobile/proc/dock(obj/docking_port/stationary/S1, force=FALSE)
	// Crashing this ship with NO SURVIVORS
	if(S1.get_docked() == src)
		remove_ripples()
		return

	if(!force)
		if(!check_dock(S1))
			return -1

		if(canMove())
			return -1


//		//rotate transit docking ports, so we don't need zillions of variants
//		if(istype(S1, /obj/docking_port/stationary/transit))
//			S1.dir = turn(NORTH, -travelDir)

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
	rotation = SimplifyDegrees(rotation)



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

		T0.copyTurf(T1)
		areaInstance.contents += T1

		//copy over air
		if(istype(T1, /turf/simulated))
			var/turf/simulated/Ts1 = T1
			Ts1.copy_air_with_tile(T0)

		//move mobile to new location
		for(var/atom/movable/AM in T0)
			AM.onShuttleMove(T1, rotation)

		if(rotation)
			T1.shuttleRotate(rotation)

		//lighting stuff
		air_master.remove_from_active(T1)
		T1.CalculateAdjacentTurfs()
		air_master.add_to_active(T1,1)

		T0.ChangeTurf(turf_type)

		air_master.remove_from_active(T0)
		T0.CalculateAdjacentTurfs()
		air_master.add_to_active(T0,1)

	for(var/A1 in L1)
		var/turf/T1 = A1
		T1.postDock(S1)
		for(var/atom/movable/M in T1)
			M.postDock(S1)

	loc = S1.loc
	dir = S1.dir

	unlockPortDoors(S1)


/obj/docking_port/mobile/proc/findTransitDock()
	var/obj/docking_port/stationary/transit/T = shuttle_master.getDock("[id]_transit")
	if(T && check_dock(T))
		return T


/obj/docking_port/mobile/proc/findRoundstartDock()
	var/obj/docking_port/stationary/D
	D = shuttle_master.getDock(roundstart_move)

	if(D)
		return D

/obj/docking_port/mobile/proc/dockRoundstart()
	// Instead of spending a lot of time trying to work out where to place
	// our shuttle, just create it somewhere empty and send it to where
	// it should go
	. = dock_id(roundstart_move)

/obj/docking_port/mobile/proc/dock_id(id)
	var/port = shuttle_master.getDock(id)
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

	for(var/obj/machinery/door/airlock/A in airlocks)
		if(A.id_tag == S0.id)
			spawn(-1)
				A.close()
				A.lock()

/obj/docking_port/mobile/proc/unlockPortDoors(obj/docking_port/stationary/S1)
	if(!istype(S1))
		return 0

	for(var/obj/machinery/door/airlock/A in airlocks)
		if(A.id_tag == S1.id)
			spawn(-1)
				if(A.locked)
					A.unlock()

/obj/docking_port/mobile/proc/roadkill(list/L0, list/L1, dir)
	var/list/hurt_mobs = list()
	for(var/i in 1 to L0.len)
		var/turf/T0 = L0[i]
		var/turf/T1 = L1[i]
		if(!T0 || !T1)
			continue

		for(var/atom/movable/AM in T1)
			if(AM.pulledby)
				AM.pulledby.stop_pulling()
			if(ismob(AM))
				var/mob/M = AM
				if(M.buckled)
					M.buckled.unbuckle_mob(M, 1)
				if(isliving(AM))
					var/mob/living/L = AM
					L.stop_pulling()
					if(L.anchored)
						L.gib()
					else
						if(!(L in hurt_mobs))
							hurt_mobs |= L
							L.visible_message("<span class='warning'>[L] is hit by \
									a hyperspace ripple[L.anchored ? "":" and is thrown clear"]!</span>",
									"<span class='userdanger'>You feel an immense \
									crushing pressure as the space around you ripples.</span>")
							L.Paralyse(10)
							L.ex_act(2)

			// Move unanchored atoms
			if(!AM.anchored)
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

/obj/machinery/computer/shuttle
	name = "Shuttle Console"
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	req_access = list( )
	circuit = /obj/item/weapon/circuitboard/shuttle
	var/shuttleId
	var/possible_destinations = ""
	var/admin_controlled
	var/max_connect_range = 7
	var/docking_request = 0

/obj/machinery/computer/shuttle/New(location, obj/item/weapon/circuitboard/shuttle/C)
	..()
	if(istype(C))
		possible_destinations = C.possible_destinations
		shuttleId = C.shuttleId

	connect()

/obj/machinery/computer/shuttle/proc/connect()
	var/obj/docking_port/mobile/M
	if(!shuttleId)
		// find close shuttle that is ok to mess with
		if(!shuttle_master) //intentionally mapping shuttle consoles without actual shuttles IS POSSIBLE OH MY GOD WHO KNEW *glare*
			return
		for(var/obj/docking_port/mobile/D in shuttle_master.mobile)
			if(get_dist(src, D) <= max_connect_range && D.rebuildable)
				M = D
				shuttleId = M.id
				break
	else if(!possible_destinations && shuttle_master) //possible destinations should **not** always exist; so, if it's specifically set to null, don't make it exist
		M = shuttle_master.getShuttle(shuttleId)

	if(M && !possible_destinations)
		// find perfect fits
		possible_destinations = ""
		for(var/obj/docking_port/stationary/S in shuttle_master.stationary)
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

/obj/machinery/computer/shuttle/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/obj/docking_port/mobile/M = shuttle_master.getShuttle(shuttleId)
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "shuttle_console.tmpl", M ? M.name : "shuttle", 300, 200)
		ui.open()

/obj/machinery/computer/shuttle/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	var/obj/docking_port/mobile/M = shuttle_master.getShuttle(shuttleId)
	data["status"] = M ? M.getStatusText() : null
	if(M)
		data["shuttle"] = 1
		var/list/docking_ports = list()
		data["docking_ports"] = docking_ports
		var/list/options = params2list(possible_destinations)
		for(var/obj/docking_port/stationary/S in shuttle_master.stationary)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S))
				continue
			docking_ports[++docking_ports.len] = list("name" = S.name, "id" = S.id)
		data["docking_ports_len"] = docking_ports.len
		data["admin_controlled"] = admin_controlled
		data["docking_request"] = docking_request

	return data

/obj/machinery/computer/shuttle/Topic(href, href_list)
	if(..())
		return 1

	if(!allowed(usr))
		to_chat(usr, "<span class='danger'>Access denied.</span>")
		return

	var/list/options = params2list(possible_destinations)
	if(href_list["move"])
		if(!options.Find(href_list["move"])) //I see you're trying Href exploits, I see you're failing, I SEE ADMIN WARNING.
			// Seriously, though, NEVER trust a Topic with something like this. Ever.
			message_admins("move HREF ([src] attempted to move to: [href_list["move"]]) exploit attempted by [key_name_admin(usr)] on [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
			return
		switch(shuttle_master.moveShuttle(shuttleId, href_list["move"], 1))
			if(0)
				to_chat(usr, "<span class='notice'>Shuttle received message and will be sent shortly.</span>")
			if(1)
				to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
			else
				to_chat(usr, "<span class='notice'>Unable to comply.</span>")
		return 1

/obj/machinery/computer/shuttle/emag_act(mob/user)
	if(!emagged)
		src.req_access = list()
		emagged = 1
		to_chat(user, "<span class='notice'>You fried the consoles ID checking system.</span>")

/obj/machinery/computer/shuttle/ferry
	name = "transport ferry console"
	circuit = /obj/item/weapon/circuitboard/ferry
	shuttleId = "ferry"
	possible_destinations = "ferry_home;ferry_away"


/obj/machinery/computer/shuttle/ferry/request
	name = "ferry console"
	circuit = /obj/item/weapon/circuitboard/ferry/request
	var/cooldown //prevents spamming admins
	possible_destinations = "ferry_home"
	admin_controlled = 1

/obj/machinery/computer/shuttle/ferry/request/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["request"])
		if(cooldown)
			return
		cooldown = 1
		to_chat(usr, "<span class='notice'>Your request has been recieved by Centcom.</span>")
		log_admin("[key_name(usr)] requested to move the transport ferry to Centcom.")
		message_admins("<b>FERRY: <font color='blue'>[key_name_admin(usr)] (<A HREF='?_src_=holder;secretsfun=moveferry'>Move Ferry</a>)</b> is requesting to move the transport ferry to Centcom.</font>")
		. = 1
		nanomanager.update_uis(src)
		spawn(600) //One minute cooldown
			cooldown = 0

/obj/machinery/computer/shuttle/ert
	name = "specops shuttle console"
	//circuit = /obj/item/weapon/circuitboard/ert
	req_access = list(access_cent_general)
	shuttleId = "specops"
	possible_destinations = "specops_home;specops_away"


/obj/machinery/computer/shuttle/white_ship
	name = "White Ship Console"
	desc = "Used to control the White Ship."
	circuit = /obj/item/weapon/circuitboard/white_ship
	shuttleId = "whiteship"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4"

/obj/machinery/computer/shuttle/vox
	name = "skipjack control console"
	req_access = list(access_vox)
	shuttleId = "skipjack"
	possible_destinations = "skipjack_away;skipjack_ne;skipjack_nw;skipjack_se;skipjack_sw;skipjack_z5"

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
	name = "Administration Shuttle Console"
	desc = "Used to call and send the administration shuttle."
	shuttleId = "admin"
	possible_destinations = "admin_home;admin_away"

/obj/machinery/computer/shuttle/sst
	name = "Syndicate Strike Time Shuttle Console"
	desc = "Used to call and send the SST shuttle."
	req_access = list(access_syndicate)
	shuttleId = "sst"
	possible_destinations = "sst_home;sst_away"

/obj/machinery/computer/shuttle/sit
	name = "Syndicate Infiltration Team Shuttle Console"
	desc = "Used to call and send the SIT shuttle."
	req_access = list(access_syndicate)
	shuttleId = "sit"
	possible_destinations = "sit_arrivals;sit_scimaint;sit_engshuttle;sit_away"


var/global/trade_dock_timelimit = 0
var/global/trade_dockrequest_timelimit = 0

/obj/machinery/computer/shuttle/trade
	name = "Freighter Console"
	docking_request = 1
	var/possible_destinations_dock
	var/possible_destinations_nodock
	var/docking_request_message = "A trading ship has requested docking aboard the NSS Cyberiad for trading. This request can be accepted or denied using a communications console."

/obj/machinery/computer/shuttle/trade/attack_hand(mob/user)
	if(world.time < trade_dock_timelimit)
		possible_destinations = possible_destinations_dock
	else
		possible_destinations = possible_destinations_nodock

	docking_request = (world.time > trade_dockrequest_timelimit && world.time > trade_dock_timelimit)
	..(user)

/obj/machinery/computer/shuttle/trade/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["request"])
		if(world.time < trade_dockrequest_timelimit || world.time < trade_dock_timelimit)
			return
		to_chat(usr, "<span class='notice'>Request sent.</span>")
		event_announcement.Announce(docking_request_message, "Docking Request")
		trade_dockrequest_timelimit = world.time + 1200 // They have 2 minutes to approve the request.
		return 1

/obj/machinery/computer/shuttle/trade/sol
	req_access = list(access_trade_sol)
	possible_destinations_dock = "trade_sol_base;trade_sol_offstation;trade_dock"
	possible_destinations_nodock = "trade_sol_base;trade_sol_offstation"
	shuttleId = "trade_sol"
	docking_request_message = "A trading ship of Sol origin has requested docking aboard the NSS Cyberiad for trading. This request can be accepted or denied using a communications console."

#undef DOCKING_PORT_HIGHLIGHT


/turf/proc/copyTurf(turf/T)
	if(T.type != type)
		var/obj/O
		if(underlays.len)	//we have underlays, which implies some sort of transparency, so we want to a snapshot of the previous turf as an underlay
			O = new()
			O.underlays.Add(T)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = O.underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	return T
