#define CALL_SHUTTLE_REASON_LENGTH 12

SUBSYSTEM_DEF(shuttle)
	name = "Shuttle"
	wait = 10
	init_order = INIT_ORDER_SHUTTLE
	flags = SS_KEEP_TIMING|SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME
	var/list/mobile = list()
	var/list/stationary = list()
	var/list/transit = list()

		//emergency shuttle stuff
	var/obj/docking_port/mobile/emergency/emergency
	var/obj/docking_port/mobile/emergency/backup/backup_shuttle
	var/emergencyCallTime = 6000	//time taken for emergency shuttle to reach the station when called (in deciseconds)
	var/emergencyDockTime = 1800	//time taken for emergency shuttle to leave again once it has docked (in deciseconds)
	var/emergencyEscapeTime = 1200	//time taken for emergency shuttle to reach a safe distance after leaving station (in deciseconds)
	var/emergency_sec_level_time = 0 // time sec level was last raised to red or higher
	var/area/emergencyLastCallLoc
	var/emergencyNoEscape

		//supply shuttle stuff
	var/obj/docking_port/mobile/supply/supply
	var/ordernum = 1					//order number given to next order
	var/points = 50						//number of trade-points we have
	var/points_per_decisecond = 0.005	//points gained every decisecond
	var/points_per_slip = 2				//points gained per slip returned
	var/points_per_crate = 5			//points gained per crate returned
	var/points_per_intel = 250			//points gained per intel returned
	var/points_per_plasma = 5			//points gained per plasma returned
	var/points_per_design = 25			//points gained per research design returned
	var/centcom_message = ""			//Remarks from Centcom on how well you checked the last order.
	var/list/discoveredPlants = list()	//Typepaths for unusual plants we've already sent CentComm, associated with their potencies
	var/list/techLevels = list()
	var/list/researchDesigns = list()
	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/supply_packs = list()
	var/datum/round_event/shuttle_loan/shuttle_loan
	var/sold_atoms = ""

/datum/controller/subsystem/shuttle/Initialize(start_timeofday)
	ordernum = rand(1,9000)

	if(!emergency)
		WARNING("No /obj/docking_port/mobile/emergency placed on the map!")
	if(!backup_shuttle)
		WARNING("No /obj/docking_port/mobile/emergency/backup placed on the map!")
	if(!supply)
		WARNING("No /obj/docking_port/mobile/supply placed on the map!")
	
	initial_load()

	for(var/typepath in subtypesof(/datum/supply_packs))
		var/datum/supply_packs/P = new typepath()
		if(P.name == "HEADER") continue		// To filter out group headers
		supply_packs["[P.type]"] = P
	initial_move()

	return ..()

/datum/controller/subsystem/shuttle/stat_entry(msg)
	..("M:[mobile.len] S:[stationary.len] T:[transit.len]")

/datum/controller/subsystem/shuttle/proc/initial_load()
	for(var/obj/docking_port/D in world)
		D.register()
		CHECK_TICK

/datum/controller/subsystem/shuttle/fire(resumed = FALSE)
	points += points_per_decisecond * wait
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

	if(world.time - round_start_time < config.shuttle_refuel_delay)
		to_chat(user, "The emergency shuttle is refueling. Please wait another [abs(round(((world.time - round_start_time) - config.shuttle_refuel_delay)/600))] minutes before trying again.")
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

	call_reason = trim(html_encode(call_reason))

	if(length(call_reason) < CALL_SHUTTLE_REASON_LENGTH)
		to_chat(user, "You must provide a reason.")
		return

	var/area/signal_origin = get_area(user)
	var/emergency_reason = "\nNature of emergency:\n\n[call_reason]"
	if(seclevel2num(get_security_level()) >= SEC_LEVEL_RED) // There is a serious threat we gotta move no time to give them five minutes.
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
	if(ticker.mode.name == "meteor")
		return
	if(seclevel2num(get_security_level()) >= SEC_LEVEL_RED)
		if(emergency.timeLeft(1) < emergencyCallTime * 0.25)
			return
	else
		if(emergency.timeLeft(1) < emergencyCallTime * 0.5)
			return
	return 1

/datum/controller/subsystem/shuttle/proc/autoEvac()
	var/callShuttle = 1

	for(var/thing in GLOB.shuttle_caller_list)
		if(istype(thing, /mob/living/silicon/ai))
			var/mob/living/silicon/ai/AI = thing
			if(AI.stat || !AI.client)
				continue
		else if(istype(thing, /obj/machinery/computer/communications))
			var/obj/machinery/computer/communications/C = thing
			if(C.stat & BROKEN)
				continue
		else if(istype(thing, /datum/computer_file/program/comm) || istype(thing, /obj/item/circuitboard/communications))
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


/datum/controller/subsystem/shuttle/proc/moveShuttle(shuttleId, dockId, timed)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	var/obj/docking_port/stationary/D = getDock(dockId)
	if(!M)
		return 1
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

/datum/controller/subsystem/shuttle/proc/generateSupplyOrder(packId, _orderedby, _orderedbyRank, _comment, _crates)
	if(!packId)
		return
	var/datum/supply_packs/P = supply_packs["[packId]"]
	if(!P)
		return

	var/datum/supply_order/O = new()
	O.ordernum = ordernum++
	O.object = P
	O.orderedby = _orderedby
	O.orderedbyRank = _orderedbyRank
	O.comment = _comment
	O.crates = _crates

	requestlist += O

	return O

#undef CALL_SHUTTLE_REASON_LENGTH