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

	//these objects are indestructable
/obj/docking_port/Destroy()
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
	name = "In Transit"
	turf_type = /turf/space/transit

	lock_shuttle_doors = 1

/obj/docking_port/stationary/transit/register()
	if(!..())
		return 0

	name = "In Transit" //This looks weird, but- it means that the on-map instances can be named something actually usable to search for, but still appear correctly in terminals.

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


//this is a hook for custom behaviour. Maybe at some point we could add checks to see if engines are intact
/obj/docking_port/mobile/proc/canMove()
	return 0	//0 means we can move

//this is to check if this shuttle can physically dock at dock S
/obj/docking_port/mobile/proc/canDock(obj/docking_port/stationary/S)
	if(!istype(S))
		return 1
	if(istype(S, /obj/docking_port/stationary/transit))
		return 0
	//check dock is big enough to contain us
	if(dwidth > S.dwidth)
		return 2
	if(width-dwidth > S.width-S.dwidth)
		return 3
	if(dheight > S.dheight)
		return 4
	if(height-dheight > S.height-S.dheight)
		return 5
	//check the dock isn't occupied
	if(S.get_docked())
		return 6
	return 0	//0 means we can dock

//call the shuttle to destination S
/obj/docking_port/mobile/proc/request(obj/docking_port/stationary/S)
	if(canDock(S))
		. = 1
		throw EXCEPTION("request(): shuttle cannot dock")
		return 1	//we can't dock at S

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

//default shuttleRotate
/atom/proc/shuttleRotate(rotation)
	//rotate our direction
	dir = angle2dir(rotation+dir2angle(dir))

	//rotate the pixel offsets too.
	if(pixel_x || pixel_y)
		if(rotation < 0)
			rotation += 360
		for(var/turntimes=rotation/90;turntimes>0;turntimes--)
			var/oldPX = pixel_x
			var/oldPY = pixel_y
			pixel_x = oldPY
			pixel_y = (oldPX*(-1))

/atom/proc/postDock()
	if(smooth)
		smooth_icon(src)


//this is the main proc. It instantly moves our mobile port to stationary port S1
//it handles all the generic behaviour, such as sanity checks, closing doors on the shuttle, stunning mobs, etc
/obj/docking_port/mobile/proc/dock(obj/docking_port/stationary/S1)
	. = canDock(S1)
	if(.)
		throw EXCEPTION("dock(): shuttle cannot dock")
		return .

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

	//move or squish anything in the way ship at destination
	roadkill(L1, S1.dir)

	var/list/door_unlock_list = list()

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
			if(rotation)
				AM.shuttleRotate(rotation)

			if(istype(AM,/obj))
				var/obj/O = AM
				if(istype(O, /obj/docking_port/stationary))
					continue
				O.forceMove(T1)

				//close open doors
				if(istype(O, /obj/machinery/door))
					var/obj/machinery/door/Door = O
					spawn(-1)
						if(Door)
							if(istype(Door, /obj/machinery/door/airlock))
								var/obj/machinery/door/airlock/A = Door
								A.close(0,1)
								if(A.id_tag == "s_docking_airlock")
									A.lock()
									door_unlock_list += A
							else
								Door.close()
			else if(istype(AM,/mob))
				var/mob/M = AM
				if(!M.move_on_shuttle)
					continue
				M.forceMove(T1)

				//docking turbulence
				if(M.client)
					spawn(0)
						if(M.buckled)
							shake_camera(M, 2, 1) // turn it down a bit come on
						else
							shake_camera(M, 7, 1)
				if(istype(M, /mob/living/carbon))
					if(!M.buckled)
						M.Weaken(3)


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
		T1.postDock()
		for(var/atom/movable/M in T1)
			M.postDock()

	loc = S1.loc
	dir = S1.dir

	unlockPortDoors(S1)
	if(S1 && !S1.lock_shuttle_doors)
		for(var/obj/machinery/door/airlock/A in door_unlock_list)
			spawn(-1)
				A.unlock()

/*
	if(istype(S1, /obj/docking_port/stationary/transit))
		var/d = turn(dir, 180 + travelDir)
		for(var/turf/space/transit/T in S1.return_ordered_turfs())
			T.pushdirection = d
			T.update_icon()
*/



/obj/docking_port/mobile/proc/findTransitDock()
	var/obj/docking_port/stationary/transit/T = shuttle_master.getDock("[id]_transit")
	if(T && !canDock(T))
		return T
/*	commented out due to issues with rotation
	for(var/obj/docking_port/stationary/transit/S in shuttle_master.transit)
		if(S.id)
			continue
		if(!canDock(S))
			return S
*/


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

/obj/docking_port/mobile/proc/roadkill(list/L, dir, x, y)
	for(var/turf/T in L)
		for(var/atom/movable/AM in T)
			if(ismob(AM))
				if(istype(AM, /mob/living))
					var/mob/living/M = AM
					M.Paralyse(10)
					M.take_organ_damage(80)
					M.anchored = 0
				else
					continue

			if(!AM.anchored)
				step(AM, dir)
			else
				if(AM.simulated) //lighting overlays are static
					qdel(AM)
/*
//used to check if atom/A is within the shuttle's bounding box
/obj/docking_port/mobile/proc/onShuttleCheck(atom/A)
	var/turf/T = get_turf(A)
	if(!T)
		return 0

	var/list/L = return_coords()
	if(L[1] > L[3])
		L.Swap(1,3)
	if(L[2] > L[4])
		L.Swap(2,4)

	if(L[1] <= T.x && T.x <= L[3])
		if(L[2] <= T.y && T.y <= L[4])
			return 1
	return 0
*/
//used by shuttle subsystem to check timers
/obj/docking_port/mobile/proc/check()
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
	src.add_fingerprint(usr)

	connect()

	var/list/options = params2list(possible_destinations)
	var/obj/docking_port/mobile/M = shuttle_master.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		var/destination_found
		for(var/obj/docking_port/stationary/S in shuttle_master.stationary)
			if(!options.Find(S.id))
				continue
			if(M.canDock(S))
				continue
			destination_found = 1
			dat += "<A href='?src=[UID()];move=[S.id]'>Send to [S.name]</A><br>"
		if(!destination_found)
			dat += "<B>Shuttle Locked</B><br>"
			if(admin_controlled)
				dat += "Authorized personnel only<br>"
				dat += "<A href='?src=[UID()];request=1]'>Request Authorization</A><br>"
		if(docking_request)
			dat += "<A href='?src=[UID()];request=1]'>Request docking at NSS Cyberiad</A><br>"
	dat += "<a href='?src=[user.UID()];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "computer", M ? M.name : "shuttle", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/shuttle/Topic(href, href_list)
	if(..())
		return 1
	usr.set_machine(src)
	src.add_fingerprint(usr)
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
		updateUsrDialog()

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
		spawn(600) //One minute cooldown
			cooldown = 0


/obj/machinery/computer/shuttle/ert
	name = "specops shuttle console"
	//circuit = /obj/item/weapon/circuitboard/ert
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
	shuttleId = "sst"
	possible_destinations = "sst_home;sst_away"

/obj/machinery/computer/shuttle/sit
	req_access = list(access_syndicate)
	name = "Syndicate Infiltration Team Shuttle Console"
	desc = "Used to call and send the SIT shuttle."
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
		command_announcement.Announce(docking_request_message, "Docking Request")
		trade_dockrequest_timelimit = world.time + 1200 // They have 2 minutes to approve the request.

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
