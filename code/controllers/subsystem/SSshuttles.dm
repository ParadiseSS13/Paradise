#define CALL_SHUTTLE_REASON_LENGTH 12
SUBSYSTEM_DEF(shuttle)
	name = "Shuttle"
	wait = 10
	init_order = INIT_ORDER_SHUTTLE
	flags = SS_KEEP_TIMING|SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME
	offline_implications = "Shuttles will no longer function. Immediate server restart recommended."
	cpu_display = SS_CPUDISPLAY_LOW
	var/list/mobile = list()
	var/list/stationary = list()
	var/list/transit = list()

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
	return "M:[length(mobile)] S:[length(stationary)] T:[length(transit)]"

/datum/controller/subsystem/shuttle/proc/initial_load()
	for(var/obj/docking_port/D in world)
		D.register()
		CHECK_TICK

/datum/controller/subsystem/shuttle/fire(resumed = FALSE)
	for(var/thing in mobile)
		if(thing)
			var/obj/docking_port/mobile/P = thing
			P.check()
			continue
		CHECK_TICK
		mobile.Remove(thing)

/datum/controller/subsystem/shuttle/proc/getShuttle(id)
	for(var/obj/docking_port/mobile/M in mobile)
		if(M.id == id)
			return M
	WARNING("couldn't find shuttle with id: [id]")

/datum/controller/subsystem/shuttle/proc/getDock(id)
	for(var/obj/docking_port/stationary/S in stationary)
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
		if(isAI(thing))
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
	for(var/obj/docking_port/mobile/M in mobile)
		if(!M.roundstart_move)
			continue
		M.dockRoundstart()

/datum/controller/subsystem/shuttle/proc/get_dock_overlap(x0, y0, x1, y1, z)
	. = list()
	var/list/stationary_cache = stationary
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
		console.createMessage("Messaging and Intergalactic Letters", "New Mail Crates ready to be ordered!", "A new mail crate is able to be shipped alongside your next orders!", RQ_NORMALPRIORITY)

	if(!length(supply_shuttle_turfs))
		for(var/turf/simulated/T in supply.areaInstance)
			if(is_blocked_turf(T))
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

#undef CALL_SHUTTLE_REASON_LENGTH
