#define CALL_SHUTTLE_REASON_LENGTH 12

#define MAX_TRANSIT_REQUEST_RETRIES 10
/// How many turfs to allow before we start blocking transit requests
#define MAX_TRANSIT_TILE_COUNT (150 ** 2)
/// How many turfs to allow before we start freeing up existing "soft reserved" transit docks
/// If we're under load we want to allow for cycling, but if not we want to preserve already generated docks for use
#define SOFT_TRANSIT_RESERVATION_THRESHOLD (100 ** 2)

SUBSYSTEM_DEF(shuttle)
	name = "Shuttle"
	wait = 10
	init_order = INIT_ORDER_SHUTTLE
	flags = SS_KEEP_TIMING|SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME
	offline_implications = "Shuttles will no longer function. Immediate server restart recommended."
	cpu_display = SS_CPUDISPLAY_LOW
	/// A list of all the mobile docking ports.
	var/list/mobile_docking_ports = list()
	/// A list of all the stationary docking ports.
	var/list/stationary_docking_ports = list()
	/// A list of all the transit docking ports.
	var/list/transit_docking_ports = list()

	//emergency shuttle stuff
	var/obj/docking_port/mobile/emergency/emergency
	var/obj/docking_port/mobile/emergency/backup/backup_shuttle
	var/emergencyCallTime = SHUTTLE_CALLTIME	//time taken for emergency shuttle to reach the station when called (in deciseconds)
	var/emergencyDockTime = SHUTTLE_DOCKTIME	//time taken for emergency shuttle to leave again once it has docked (in deciseconds)
	var/emergencyEscapeTime = SHUTTLE_ESCAPETIME	//time taken for emergency shuttle to reach a safe distance after leaving station (in deciseconds)
	var/emergency_sec_level_time = 0 // time sec level was last raised to red or higher
	var/area/emergencyLastCallLoc
	/// Things blocking escape shuttle from leaving.
	var/list/hostile_environments = list()

	//supply shuttle stuff
	var/obj/docking_port/mobile/supply/supply
	/// Supply shuttle turfs to make mail be put down faster
	var/static/list/supply_shuttle_turfs = list()
	/// The current shuttle loan event, if any.
	var/shuttle_loan_UID

	var/list/hidden_shuttle_turfs = list() //all turfs hidden from navigation computers associated with a list containing the image hiding them and the type of the turf they are pretending to be
	var/list/hidden_shuttle_turf_images = list() //only the images from the above list
	/// Default refuel delay
	var/refuel_delay = 20 MINUTES
	/// Whether or not a custom shuttle has been ordered.
	var/custom_shuttle_ordered = FALSE
	// These vars are necessary to prevent multiple loads on the same turfs at the same times causing massive server issues
	/// Whether or not a custom shuttle is currently loading at centcomm.
	var/custom_escape_shuttle_loading = FALSE
	/// Whether or not a shuttle is currently being loaded at the template landmark, if it exists.
	var/loading_shuttle_at_preview_template = FALSE
	/// Have we locked in the emergency shuttle, to prevent people from breaking things / wasting player money?
	var/emergency_locked_in = FALSE

	/// A list of all the mobile docking ports currently requesting a spot in hyperspace.
	var/list/transit_requesters = list()
	/// An associative list of the mobile docking ports that have failed a transit request, with the amount of times they've actually failed that transit request, up to MAX_TRANSIT_REQUEST_RETRIES
	var/list/transit_request_failures = list()
	/// How many turfs our shuttles are currently utilizing in reservation space
	var/transit_utilized = 0

/datum/controller/subsystem/shuttle/Initialize()
	if(!emergency)
		WARNING("No /obj/docking_port/mobile/emergency placed on the map!")
	if(!backup_shuttle)
		WARNING("No /obj/docking_port/mobile/emergency/backup placed on the map!")
	if(!supply)
		WARNING("No /obj/docking_port/mobile/supply placed on the map!")

	initial_load()
	initial_move()

/datum/controller/subsystem/shuttle/get_stat_details()
	return "M:[length(mobile_docking_ports)] S:[length(stationary_docking_ports)] T:[length(transit_docking_ports)]"

/datum/controller/subsystem/shuttle/proc/initial_load()
	for(var/obj/docking_port/D in world)
		D.register()
		CHECK_TICK

/datum/controller/subsystem/shuttle/fire(resumed = FALSE)
	for(var/thing in mobile_docking_ports)
		if(!thing)
			mobile_docking_ports.Remove(thing)
			continue
		var/obj/docking_port/mobile/port = thing
		port.check()
	for(var/obj/docking_port/stationary/transit/T as anything in transit_docking_ports)
		if(!T.owner)
			qdel(T, force=TRUE)
		// This next one removes transit docks/zones that aren't
		// immediately being used. This will mean that the zone creation
		// code will be running a lot.

		// If we're below the soft reservation threshold, don't clear the old space
		// We're better off holding onto it for now
		if(transit_utilized < SOFT_TRANSIT_RESERVATION_THRESHOLD)
			continue
		var/obj/docking_port/mobile/owner = T.owner
		if(owner)
			var/idle = owner.mode == SHUTTLE_IDLE
			// var/not_centcom_evac = owner.launch_status == NOLAUNCH
			var/not_in_use = (!T.get_docked())
			if(idle && not_in_use)
				qdel(T, force=TRUE)

	if(!SSmapping.clearing_reserved_turfs)
		while(transit_requesters.len)
			var/requester = popleft(transit_requesters)
			var/success = FALSE
			// Do not try and generate any transit if we're using more then our max already
			if(transit_utilized < MAX_TRANSIT_TILE_COUNT)
				success = generate_transit_dock(requester)
			else
				log_debug("Transit request for '[requester]' failed, too many turfs in use.")
			if(!success) // BACK OF THE QUEUE
				transit_request_failures[requester]++
				if(transit_request_failures[requester] < MAX_TRANSIT_REQUEST_RETRIES)
					transit_requesters += requester
				else
					var/obj/docking_port/mobile/M = requester
					M.transit_failure()
			if(MC_TICK_CHECK)
				break

/datum/controller/subsystem/shuttle/proc/getShuttle(id)
	for(var/obj/docking_port/mobile/M in mobile_docking_ports)
		if(M.id == id)
			return M
	WARNING("couldn't find shuttle with id: [id]")

/datum/controller/subsystem/shuttle/proc/getDock(id)
	for(var/obj/docking_port/stationary/S in stationary_docking_ports)
		if(S.id == id)
			return S
	WARNING("couldn't find dock with id: [id]")

/datum/controller/subsystem/shuttle/proc/secondsToRefuel()
	var/elapsed = world.time - SSticker.round_start_time
	var/remaining = round((refuel_delay - elapsed) / 10)
	return remaining > 0 ? remaining : 0

/datum/controller/subsystem/shuttle/proc/requestEvac(mob/user, call_reason)
	if(!emergency)
		WARNING("requestEvac(): There is no emergency shuttle, but the shuttle was called. Using the backup shuttle instead.")
		if(!backup_shuttle)
			WARNING("requestEvac(): There is no emergency shuttle, or backup shuttle!\
			The game will be unresolvable.This is possibly a mapping error, \
			more likely a bug with the shuttle \
			manipulation system, or badminry. It is possible to manually \
			resolve this problem by loading an emergency shuttle template \
			manually, and then calling register() on the mobile docking port. \
			Good luck.")
			return
		emergency = backup_shuttle

	if(secondsToRefuel())
		to_chat(user, "The emergency shuttle is refueling. Please wait another [abs(round(((world.time - SSticker.round_start_time) - refuel_delay)/600))] minutes before trying again.")
		return

	switch(emergency.mode)
		if(SHUTTLE_RECALL)
			to_chat(user, "The emergency shuttle may not be called while returning to Centcom.")
			return
		if(SHUTTLE_CALL)
			to_chat(user, "The emergency shuttle is already on its way.")
			return
		if(SHUTTLE_DOCKED)
			to_chat(user, "The emergency shuttle is already here.")
			return
		if(SHUTTLE_ESCAPE)
			to_chat(user, "The emergency shuttle is moving away to a safe distance.")
			return
		if(SHUTTLE_STRANDED)
			to_chat(user, "The emergency shuttle has been disabled by Centcom.")
			return

	if(length(call_reason) < CALL_SHUTTLE_REASON_LENGTH)
		to_chat(user, "Reason is too short. [CALL_SHUTTLE_REASON_LENGTH] character minimum.")
		return

	var/area/signal_origin = get_area(user)
	var/emergency_reason = "\nNature of emergency:\n\n[call_reason]"
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED) // There is a serious threat we gotta move no time to give them five minutes.
		var/extra_minutes = 0
		var/priority_time = emergencyCallTime * 0.5
		if(world.time - emergency_sec_level_time < priority_time)
			extra_minutes = 5
		emergency.request(null, 0.5 + extra_minutes / (emergencyCallTime / 600), signal_origin, html_decode(emergency_reason), 1)
	else
		emergency.request(null, 1, signal_origin, html_decode(emergency_reason), 0)

	log_game("[key_name(user)] has called the shuttle.")
	message_admins("[key_name_admin(user)] has called the shuttle.")

	return


// Called when an emergency shuttle mobile docking port is
// destroyed, which will only happen with admin intervention
/datum/controller/subsystem/shuttle/proc/emergencyDeregister()
	// When a new emergency shuttle is created, it will override the
	// backup shuttle.
	emergency = backup_shuttle

/datum/controller/subsystem/shuttle/proc/cancelEvac(mob/user)
	if(canRecall())
		emergency.cancel(get_area(user))
		log_game("[key_name(user)] has recalled the shuttle.")
		message_admins("[key_name_admin(user)] has recalled the shuttle.")
		return 1

/datum/controller/subsystem/shuttle/proc/canRecall()
	if(emergency.mode != SHUTTLE_CALL)
		return
	if(!emergency.canRecall)
		return
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		if(emergency.timeLeft(1) < emergencyCallTime * 0.25)
			return
	else
		if(emergency.timeLeft(1) < emergencyCallTime * 0.5)
			return
	return 1

/datum/controller/subsystem/shuttle/proc/autoEvac()
	var/callShuttle = 1

	for(var/thing in GLOB.shuttle_caller_list)
		if(is_ai(thing))
			var/mob/living/silicon/ai/AI = thing
			if(AI.stat || !AI.client)
				continue
		else if(istype(thing, /obj/machinery/computer/communications))
			var/obj/machinery/computer/communications/C = thing
			if(C.stat & BROKEN)
				continue
		else if(istype(thing, /obj/item/circuitboard/communications))
			continue

		var/turf/T = get_turf(thing)
		if(T && is_station_level(T.z))
			callShuttle = 0
			break

	if(callShuttle)
		if(emergency.mode < SHUTTLE_CALL)
			emergency.request(null, 2.5)
			log_game("There is no means of calling the shuttle anymore. Shuttle automatically called.")
			message_admins("All the communications consoles were destroyed and all AIs are inactive. Shuttle called.")

/datum/controller/subsystem/shuttle/proc/registerHostileEnvironment(datum/bad)
	hostile_environments |= bad

/datum/controller/subsystem/shuttle/proc/clearHostileEnvironment(datum/bad)
	hostile_environments -= bad

//try to move/request to dockHome if possible, otherwise dockAway. Mainly used for admin buttons
/datum/controller/subsystem/shuttle/proc/toggleShuttle(shuttleId, dockHome, dockAway, timed)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	if(!M)
		return 1
	var/obj/docking_port/stationary/dockedAt = M.get_docked()
	var/destination = dockHome
	if(dockedAt && dockedAt.id == dockHome)
		destination = dockAway
	if(timed)
		if(M.request(getDock(destination)))
			return 2
	else
		if(M.dock(getDock(destination)))
			return 2
	return 0	//dock successful


/datum/controller/subsystem/shuttle/proc/moveShuttle(shuttleId, dockId, timed, mob/user)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	var/obj/docking_port/stationary/D = getDock(dockId)
	//check if the shuttle is on lockdown
	if(M.uses_lockdown)
		if(M.mode == SHUTTLE_IGNITING)
			return 5
		if(M.mode != SHUTTLE_IDLE)
			return 4
		if(M.lockeddown)
			return 3
		M.lockeddown = TRUE
		addtimer(VARSET_CALLBACK(M, lockeddown, FALSE), 15 SECONDS)
	if(!M)
		return 1
	M.last_caller = user // Save the caller of the shuttle for later logging
	if(timed)
		if(M.request(D))
			return 2
	else
		if(M.dock(D))
			return 2
	return 0	//dock successful

/datum/controller/subsystem/shuttle/proc/initial_move()
	for(var/obj/docking_port/mobile/M in mobile_docking_ports)
		if(!M.roundstart_move)
			continue
		M.dockRoundstart()

/datum/controller/subsystem/shuttle/proc/get_dock_overlap(x0, y0, x1, y1, z)
	. = list()
	var/list/stationary_cache = stationary_docking_ports
	for(var/i in 1 to length(stationary_cache))
		var/obj/docking_port/port = stationary_cache[i]
		if(!port || port.z != z)
			continue
		var/list/bounds = port.return_coords()
		var/list/overlap = get_overlap(x0, y0, x1, y1, bounds[1], bounds[2], bounds[3], bounds[4])
		var/list/xs = overlap[1]
		var/list/ys = overlap[2]
		if(length(xs) && length(ys))
			.[port] = overlap

/datum/controller/subsystem/shuttle/proc/update_hidden_docking_ports(list/remove_turfs, list/add_turfs)
	var/list/remove_images = list()
	var/list/add_images = list()

	if(remove_turfs)
		for(var/T in remove_turfs)
			var/list/L = hidden_shuttle_turfs[T]
			if(L)
				remove_images += L[1]
		hidden_shuttle_turfs -= remove_turfs

	if(add_turfs)
		for(var/V in add_turfs)
			var/turf/T = V
			var/image/I
			if(length(remove_images))
				//we can just reuse any images we are about to delete instead of making new ones
				I = remove_images[1]
				remove_images.Cut(1, 2)
				I.loc = T
			else
				I = image(loc = T)
				add_images += I
			I.appearance = T.appearance
			I.override = TRUE
			hidden_shuttle_turfs[T] = list(I, T.type)

	hidden_shuttle_turf_images -= remove_images
	hidden_shuttle_turf_images += add_images

	for(var/V in GLOB.navigation_computers)
		var/obj/machinery/computer/camera_advanced/shuttle_docker/C = V
		C.update_hidden_docking_ports(remove_images, add_images)

	QDEL_LIST_CONTENTS(remove_images)

/datum/controller/subsystem/shuttle/proc/mail_delivery()
	for(var/obj/machinery/requests_console/console in GLOB.allRequestConsoles)
		if(console.department != "Cargo Bay")
			continue
		console.createMessage("Nanotrasen Mail and Interstellar Logistics", "New Mail Crates ready to be ordered!", "A new mail crate is able to be shipped alongside your next orders!", RQ_NORMALPRIORITY)

	if(!length(supply_shuttle_turfs))
		for(var/turf/simulated/T in supply.areaInstance)
			if(T.is_blocked_turf())
				continue
			supply_shuttle_turfs += T
	if(!length(supply_shuttle_turfs)) // In case some nutjob walled the supply shuttle 10 minutes into the round
		stack_trace("There were no available turfs on the Supply Shuttle to spawn a mail crate in!")
		return
	var/turf/spawn_location = pick(supply_shuttle_turfs)
	new /obj/structure/closet/crate/mail(spawn_location)

// load an alternative shuttle in at the appropriate landmark.
/datum/controller/subsystem/shuttle/proc/load_template(datum/map_template/shuttle/S)
	// load shuttle template, centred at shuttle import landmark,
	if(loading_shuttle_at_preview_template)
		CRASH("A shuttle was already loading at the preview template when another was loaded")

	S.preload()

	loading_shuttle_at_preview_template = TRUE
	var/turf/landmark_turf = get_turf(locate("landmark*Shuttle Import"))
	S.load(landmark_turf, centered = TRUE)

	var/affected = S.get_affected_turfs(landmark_turf, centered = TRUE)

	var/mobile_docking_ports = 0
	var/obj/docking_port/mobile/port
	// Search the turfs for docking ports
	// - We need to find the mobile docking port because that is the heart of
	//   the shuttle.
	// - We need to check that no additional ports have slipped in from the
	//   template, because that causes unintended behaviour.
	for(var/T in affected)
		for(var/obj/docking_port/P in T)
			if(istype(P, /obj/docking_port/mobile))
				port = P
				mobile_docking_ports++
				if(mobile_docking_ports > 1)
					qdel(P, force = TRUE)
					log_world("Map warning: Shuttle Template [S.mappath] has multiple mobile docking ports.")
				else if(!port.timid)
					// The shuttle template we loaded isn't "timid" which means
					// it's already registered with the shuttles subsystem.
					// This is a bad thing.
					WARNING("Template [S] is non-timid! Unloading.")
					port.jumpToNullSpace()
					loading_shuttle_at_preview_template = FALSE
					return

			if(istype(P, /obj/docking_port/stationary))
				log_world("Map warning: Shuttle Template [S.mappath] has a stationary docking port.")

	if(port)
		loading_shuttle_at_preview_template = FALSE
		return port

	for(var/T in affected)
		var/turf/T0 = T
		T0.contents = null

	var/msg = "load_template(): Shuttle Template [S.mappath] has no mobile docking port. Aborting import."
	message_admins(msg)
	WARNING(msg)
	loading_shuttle_at_preview_template = FALSE

/// Create a new shuttle and replace the emergency shuttle with it.
/// if loaded shuttle is passed in, a new one will not be loaded.
/datum/controller/subsystem/shuttle/proc/replace_shuttle(obj/docking_port/mobile/loaded_shuttle)
	if(custom_escape_shuttle_loading)
		CRASH("A custom escape shuttle was already being loaded at centcomm when another shuttle attempted to load.")
	custom_escape_shuttle_loading = TRUE
	// get the existing shuttle information, if any
	var/timer = 0
	var/mode = SHUTTLE_IDLE
	var/obj/docking_port/stationary/dock

	if(emergency)
		timer = emergency.timer
		mode = emergency.mode
		dock = emergency.get_docked()
		if(!dock) //lance moment
			dock = getDock("emergency_away")
	else
		dock = loaded_shuttle.findRoundstartDock()

	if(!dock)
		var/m = "No dock found for preview shuttle, aborting."
		WARNING(m)
		custom_escape_shuttle_loading = FALSE
		throw EXCEPTION(m)

	var/result = loaded_shuttle.canDock(dock)
	// truthy value means that it cannot dock for some reason
	// but we can ignore the someone else docked error because we'll
	// be moving into their place shortly
	if((result != SHUTTLE_CAN_DOCK) && (result != SHUTTLE_SOMEONE_ELSE_DOCKED))

		var/m = "Unsuccessful dock of [loaded_shuttle] ([result])."
		message_admins(m)
		WARNING(m)
		custom_escape_shuttle_loading = FALSE
		return

	emergency.jumpToNullSpace()

	loaded_shuttle.dock(dock)

	// Shuttle state involves a mode and a timer based on world.time, so
	// plugging the existing shuttles old values in works fine.
	loaded_shuttle.timer = timer
	loaded_shuttle.mode = mode

	loaded_shuttle.register()

	// TODO indicate to the user that success happened, rather than just
	// blanking the modification tab

	custom_escape_shuttle_loading = FALSE
	return loaded_shuttle

/datum/controller/subsystem/shuttle/proc/set_trader_shuttle(datum/map_template/shuttle/trader/template)
	var/obj/docking_port/mobile/trader/trade_shuttle = getShuttle("trader")
	if(trade_shuttle)
		var/obj/docking_port/stationary/docked_id = trade_shuttle.get_docked()
		if(docked_id?.id != "trader_base")
			CRASH("Attempted to load a new trade shuttle while the existing one was not at its home base.")
		// Dispose of the old shuttle.
		trade_shuttle.jumpToNullSpace()

	var/obj/docking_port/mobile/trader/dock = getDock("trader_base")
	if(!dock)
		CRASH("Unable to load trading shuttle, no trading dock found.")

	// Load in the new shuttle.
	trade_shuttle = load_template(template)
	var/result = trade_shuttle.canDock(dock)
	if(result == SHUTTLE_SOMEONE_ELSE_DOCKED)
		trade_shuttle.jumpToNullSpace()
		CRASH("A non-trader shuttle is blocking the trading dock.")
	if(result != SHUTTLE_CAN_DOCK)
		trade_shuttle.jumpToNullSpace()
		CRASH("New trading shuttle unable to dock at the trading dock: [result]")

	trade_shuttle.dock(dock)

	trade_shuttle.register()

	// TODO indicate to the user that success happened, rather than just
	// blanking the modification tab

	return trade_shuttle

/datum/controller/subsystem/shuttle/proc/request_transit_dock(obj/docking_port/mobile/M)
	if(!istype(M))
		CRASH("[M] is not a mobile docking port")

	if(M.assigned_transit)
		return
	transit_requesters |= M

/datum/controller/subsystem/shuttle/proc/generate_transit_dock(obj/docking_port/mobile/M)
	// First, determine the size of the needed zone
	// Because of shuttle rotation, the "width" of the shuttle is not
	// always x.
	var/travel_dir = M.preferred_direction
	// Remember, the direction is the direction we appear to be
	// coming from
	var/dock_angle = dir2angle(M.preferred_direction) + dir2angle(M.port_direction) + 180
	var/dock_dir = angle2dir(dock_angle)

	var/transit_width = SHUTTLE_TRANSIT_BORDER * 2
	var/transit_height = SHUTTLE_TRANSIT_BORDER * 2

	// Shuttles travelling on their side have their dimensions swapped
	// from our perspective
	switch(dock_dir)
		if(NORTH, SOUTH)
			transit_width += M.width
			transit_height += M.height
		if(EAST, WEST)
			transit_width += M.height
			transit_height += M.width

	var/transit_path = /turf/space/transit
	switch(travel_dir)
		if(NORTH)
			transit_path = /turf/space/transit/north
		if(SOUTH)
			transit_path = /turf/space/transit/south
		if(EAST)
			transit_path = /turf/space/transit/east
		if(WEST)
			transit_path = /turf/space/transit/west

	var/datum/turf_reservation/proposal = SSmapping.request_turf_block_reservation(
		transit_width,
		transit_height,
		reservation_type = /datum/turf_reservation/transit,
		turf_type_override = transit_path,
	)

	if(!istype(proposal))
		return FALSE

	var/turf/bottomleft = proposal.bottom_left_turf
	var/list/coords = M.return_coords(0, 0, dock_dir)

	// Then we want the point closest to -infinity,-infinity
	var/min_x = min(coords[1], coords[3]) // x0, x1
	var/min_y = min(coords[2], coords[4]) // y0, y1

	// Then find where to place the dock
	var/transit_x = bottomleft.x + SHUTTLE_TRANSIT_BORDER + abs(min_x)
	var/transit_y = bottomleft.y + SHUTTLE_TRANSIT_BORDER + abs(min_y)

	var/turf/midpoint = locate(transit_x, transit_y, bottomleft.z)
	if(!midpoint)
		qdel(proposal)
		return FALSE

	// our shuttle system currently doesnt support changing areas of shuttles
	// var/area/shuttle/transit/new_area = new()
	// new_area.parallax_move_direction = travel_dir
	// new_area.contents = proposal.reserved_turfs

	var/obj/docking_port/stationary/transit/new_transit_dock = new(midpoint)
	new_transit_dock.reserved_area = proposal
	new_transit_dock.owner = M
	// new_transit_dock.assigned_area = new_area
	new_transit_dock.id = "[M.id]_transit"
	new_transit_dock.turf_type = transit_path

	// Add 180, because ports point inwards, rather than outwards
	new_transit_dock.setDir(angle2dir(dock_angle))

	// Proposals use 2 extra hidden tiles of space, from the cordons that surround them
	transit_utilized += (proposal.width + 2) * (proposal.height + 2)
	M.assigned_transit = new_transit_dock
	RegisterSignal(proposal, COMSIG_PARENT_QDELETING, PROC_REF(transit_space_clearing))
	return new_transit_dock

/// Gotta manage our space brother
/datum/controller/subsystem/shuttle/proc/transit_space_clearing(datum/turf_reservation/source)
	SIGNAL_HANDLER
	transit_utilized -= (source.width + 2) * (source.height + 2)

#undef CALL_SHUTTLE_REASON_LENGTH
#undef MAX_TRANSIT_REQUEST_RETRIES
#undef MAX_TRANSIT_TILE_COUNT
#undef SOFT_TRANSIT_RESERVATION_THRESHOLD

