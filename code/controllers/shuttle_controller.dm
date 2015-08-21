
var/global/datum/shuttle_controller/shuttle_controller


/datum/shuttle_controller
	var/list/shuttles	//maps shuttle tags to shuttle datums, so that they can be looked up.
	var/list/process_shuttles	//simple list of shuttles, for processing

/datum/shuttle_controller/proc/process()
	//process ferry shuttles
	for (var/datum/shuttle/ferry/shuttle in process_shuttles)
		if (shuttle.process_state)
			shuttle.process()


/datum/shuttle_controller/New()
	shuttles = list()
	process_shuttles = list()

	var/datum/shuttle/ferry/shuttle

	// Escape shuttle and pods
	shuttle = new/datum/shuttle/ferry/emergency()
	shuttle.location = 1
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/shuttle/escape/centcom)
	shuttle.area_station = locate(/area/shuttle/escape/station)
	shuttle.area_transition = locate(/area/shuttle/escape/transit)
	shuttle.docking_controller_tag = "escape_shuttle"
	shuttle.dock_target_station = "escape_dock"
	shuttle.dock_target_offsite = "centcom_dock"
	shuttle.transit_direction = NORTH
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN
	//shuttle.docking_controller_tag = "supply_shuttle"
	//shuttle.dock_target_station = "cargo_bay"
	shuttles["Escape"] = shuttle
	process_shuttles += shuttle

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.area_station = locate(/area/shuttle/escape_pod1/station)
	shuttle.area_offsite = locate(/area/shuttle/escape_pod1/centcom)
	shuttle.area_transition = locate(/area/shuttle/escape_pod1/transit)
	shuttle.docking_controller_tag = "escape_pod_1"
	shuttle.dock_target_station = "escape_pod_1_berth"
	shuttle.dock_target_offsite = "escape_pod_1_recovery"
	shuttle.transit_direction = NORTH
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN
	process_shuttles += shuttle
	shuttles["Escape Pod 1"] = shuttle

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.area_station = locate(/area/shuttle/escape_pod2/station)
	shuttle.area_offsite = locate(/area/shuttle/escape_pod2/centcom)
	shuttle.area_transition = locate(/area/shuttle/escape_pod2/transit)
	shuttle.docking_controller_tag = "escape_pod_2"
	shuttle.dock_target_station = "escape_pod_2_berth"
	shuttle.dock_target_offsite = "escape_pod_2_recovery"
	shuttle.transit_direction = NORTH
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN
	process_shuttles += shuttle
	shuttles["Escape Pod 2"] = shuttle

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.area_station = locate(/area/shuttle/escape_pod3/station)
	shuttle.area_offsite = locate(/area/shuttle/escape_pod3/centcom)
	shuttle.area_transition = locate(/area/shuttle/escape_pod3/transit)
	shuttle.docking_controller_tag = "escape_pod_3"
	shuttle.dock_target_station = "escape_pod_3_berth"
	shuttle.dock_target_offsite = "escape_pod_3_recovery"
	shuttle.transit_direction = EAST
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN
	process_shuttles += shuttle
	shuttles["Escape Pod 3"] = shuttle

	//There is no pod 4, apparently.

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.area_station = locate(/area/shuttle/escape_pod5/station)
	shuttle.area_offsite = locate(/area/shuttle/escape_pod5/centcom)
	shuttle.area_transition = locate(/area/shuttle/escape_pod5/transit)
	shuttle.docking_controller_tag = "escape_pod_5"
	shuttle.dock_target_station = "escape_pod_5_berth"
	shuttle.dock_target_offsite = "escape_pod_5_recovery"
	shuttle.transit_direction = EAST //should this be WEST? I have no idea.
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN
	process_shuttles += shuttle
	shuttles["Escape Pod 5"] = shuttle

	//give the emergency shuttle controller it's shuttles
	emergency_shuttle.shuttle = shuttles["Escape"]
	emergency_shuttle.escape_pods = list(
		shuttles["Escape Pod 1"],
		shuttles["Escape Pod 2"],
		shuttles["Escape Pod 3"],
		shuttles["Escape Pod 5"],
	)

	// Supply shuttle
	shuttle = new/datum/shuttle/ferry/supply()
	shuttle.location = 1
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/supply/dock)
	shuttle.area_station = locate(/area/supply/station)
	shuttle.docking_controller_tag = "supply_shuttle"
	shuttle.dock_target_station = "cargo_bay"
	shuttles["Supply"] = shuttle
	process_shuttles += shuttle

	supply_controller.shuttle = shuttle

	// Admin shuttles.
	shuttle = new()
	shuttle.location = 1
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/shuttle/transport1/centcom)
	shuttle.area_station = locate(/area/shuttle/transport1/station)
	shuttle.docking_controller_tag = "centcom_shuttle"
	shuttle.dock_target_station = "centcom_shuttle_dock_airlock"
	shuttle.dock_target_offsite = "centcom_shuttle_bay"
	shuttles["Centcom"] = shuttle
	process_shuttles += shuttle

	var/datum/shuttle/ferry/multidock/admin_shuttle = new()
	admin_shuttle.location = 1
	admin_shuttle.warmup_time = 10	//want some warmup time so people can cancel.
	admin_shuttle.area_offsite = locate(/area/shuttle/administration/centcom)
	admin_shuttle.area_station = locate(/area/shuttle/administration/station)
	admin_shuttle.docking_controller_tag = "admin_shuttle_port"
	admin_shuttle.docking_controller_tag_station = "admin_shuttle_port"
	admin_shuttle.docking_controller_tag_offsite = "admin_shuttle_port"
	admin_shuttle.dock_target_station = "admin_shuttle_dock_airlock"
	admin_shuttle.dock_target_offsite = "admin_shuttle_bay"
	shuttles["Administration"] = admin_shuttle
	process_shuttles += admin_shuttle

	shuttle = new()
	shuttle.area_offsite = locate(/area/shuttle/alien/base)
	shuttle.area_station = locate(/area/shuttle/alien/mine)
	shuttles["Alien"] = shuttle
	//process_shuttles += shuttle	//don't need to process this. It can only be moved using admin magic anyways.

	// Public shuttles
	shuttle = new()
	shuttle.location = 1
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/shuttle/constructionsite/site)
	shuttle.area_station = locate(/area/shuttle/constructionsite/station)
	shuttle.docking_controller_tag = "engineering_shuttle"
	shuttle.dock_target_station = "engineering_dock_airlock"
	shuttle.dock_target_offsite = "engineering_station_airlock"
	shuttles["Engineering"] = shuttle
	process_shuttles += shuttle

	shuttle = new()
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/shuttle/mining/outpost)
	shuttle.area_station = locate(/area/shuttle/mining/station)
	shuttle.docking_controller_tag = "mining_shuttle"
	shuttle.dock_target_station = "mining_dock_airlock"
	shuttle.dock_target_offsite = "mining_outpost_airlock"
	shuttles["Mining"] = shuttle
	process_shuttles += shuttle

	shuttle = new()
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/shuttle/research/outpost)
	shuttle.area_station = locate(/area/shuttle/research/station)
	shuttle.docking_controller_tag = "research_shuttle"
	shuttle.dock_target_station = "research_dock_airlock"
	shuttle.dock_target_offsite = "research_outpost_dock"
	shuttles["Research"] = shuttle
	process_shuttles += shuttle

	shuttle = new()
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/shuttle/siberia/outpost)
	shuttle.area_station = locate(/area/shuttle/siberia/station)
	shuttle.docking_controller_tag = "labor_shuttle"
	shuttle.dock_target_station = "labor_shuttle_dock"
	shuttle.dock_target_offsite = "labor_camp_dock"
	shuttles["Labor"] = shuttle
	process_shuttles += shuttle

	// ERT Shuttle
	var/datum/shuttle/ferry/multidock/specops/ERT = new()
	ERT.location = 1
	ERT.warmup_time = 10
	ERT.area_offsite = locate(/area/shuttle/specops/centcom)
	ERT.area_station = locate(/area/shuttle/specops/station)
	ERT.docking_controller_tag = "specops_shuttle_fore"
	ERT.docking_controller_tag_station = "specops_shuttle_port"
	ERT.docking_controller_tag_offsite = "specops_shuttle_fore"
	ERT.dock_target_station = "specops_dock_airlock"
	ERT.dock_target_offsite = "specops_centcom_dock"
	shuttles["Special Operations"] = ERT
	process_shuttles += ERT


	//Vox Shuttle.
	var/datum/shuttle/multi_shuttle/VS = new/datum/shuttle/multi_shuttle()
	VS.origin = locate(/area/shuttle/vox/station)

	VS.destinations = list(
		"Fore Starboard Solars" = locate(/area/vox_station/northeast_solars),
		"Fore Port Solars" = locate(/area/vox_station/northwest_solars),
		"Aft Starboard Solars" = locate(/area/vox_station/southeast_solars),
		"Aft Port Solars" = locate(/area/vox_station/southwest_solars),
		"Mining Asteroid" = locate(/area/vox_station/mining)
		)

	VS.announcer = "NSV Icarus"
	VS.arrival_message = "Attention, [station_name()], we just tracked a small target bypassing our defensive perimeter. Can't fire on it without hitting the station - you've got incoming visitors, like it or not."
	VS.departure_message = "Your guests are pulling away, [station_name()] - moving too fast for us to draw a bead on them. Looks like they're heading out of the system at a rapid clip."
	VS.interim = locate(/area/vox_station/transit)

	VS.warmup_time = 0
	shuttles["Vox Skipjack"] = VS

	//Nuke Ops shuttle.
	var/datum/shuttle/multi_shuttle/MS = new/datum/shuttle/multi_shuttle()
	MS.origin = locate(/area/syndicate_station/start)

	MS.destinations = list(
		"Northwest of the station" = locate(/area/syndicate_station/northwest),
		"North of the station" = locate(/area/syndicate_station/north),
		"Northeast of the station" = locate(/area/syndicate_station/northeast),
		"Southwest of the station" = locate(/area/syndicate_station/southwest),
		"South of the station" = locate(/area/syndicate_station/south),
		"Southeast of the station" = locate(/area/syndicate_station/southeast),
		"Telecomms Satellite" = locate(/area/syndicate_station/commssat),
		"Mining Asteroid" = locate(/area/syndicate_station/mining)
		)

	MS.announcer = "NSV Icarus"
	MS.arrival_message = "Attention, [station_name()], you have a large signature approaching the station - looks unarmed to surface scans. We're too far out to intercept - brace for visitors."
	MS.departure_message = "Your visitors are on their way out of the system, [station_name()], burning delta-v like it's nothing. Good riddance."
	MS.interim = locate(/area/syndicate_station/transit)

	MS.warmup_time = 0
	shuttles["Syndicate"] = MS
	
	//Xenos shuttle.
	var/datum/shuttle/multi_shuttle/XS = new/datum/shuttle/multi_shuttle()
	XS.origin = locate(/area/xenos_station/start)

	XS.destinations = list(
		"Northwest of the station" = locate(/area/xenos_station/northwest),
		"Northeast of the station" = locate(/area/xenos_station/northeast),
		"East of the station" = locate(/area/xenos_station/east),
		"Southwest of the station" = locate(/area/xenos_station/southwest),
		"Southeast of the station" = locate(/area/xenos_station/southeast),
		"West of the station" = locate(/area/xenos_station/west),
		"Research Outpost" = locate(/area/xenos_station/researchoutpost)
		)

	XS.announcer = "NSV Icarus"
	XS.arrival_message = "Attention, [station_name()], you have an unknown signature approaching the station - scanners detect an alien presence on board. It's somehow scrambling our weapons targetting system: brace for hostile visitors."
	XS.departure_message = "The unknown ship appears to be pulling away from the station, [station_name()]. We're still unable to target them. Let's hope they stay away."
	XS.interim = locate(/area/xenos_station/transit)

	XS.warmup_time = 0
	shuttles["Xenomorph"] = XS

	//Derelict Shuttle.
	var/datum/shuttle/multi_shuttle/WS = new/datum/shuttle/multi_shuttle()
	WS.origin = locate(/area/shuttle/derelict/ship/start)

	WS.destinations = list(
		"NSS Cyberiad" = locate(/area/shuttle/derelict/ship/station),
		"Engineering Outpost" = locate(/area/shuttle/derelict/ship/engipost),
		)

	WS.announcer = "NSV Icarus"
	WS.arrival_message = "Attention, [station_name()], we just tracked a large medical vessel approaching the station from the telecommunications satellite. Might have wounded on board, can't destroy it - prepare for visitors."
	WS.departure_message = "Your guests are pulling away, [station_name()] - moving too fast for us to draw a bead on them. Looks like they're heading back to the telecommunications satellite."
	WS.interim = locate(/area/shuttle/derelict/ship/transit)

	WS.cloaked = 0
	WS.move_time = 180
	WS.warmup_time = 0
	shuttles["White Ship"] = WS


//This is called by gameticker after all the machines and radio frequencies have been properly initialized
/datum/shuttle_controller/proc/setup_shuttle_docks()
	var/datum/shuttle/shuttle
	var/datum/shuttle/ferry/multidock/multidock
	var/list/dock_controller_map = list()	//so we only have to iterate once through each list

	//multidock shuttles
	var/list/dock_controller_map_station = list()
	var/list/dock_controller_map_offsite = list()

	for (var/shuttle_tag in shuttles)
		shuttle = shuttles[shuttle_tag]
		if (shuttle.docking_controller_tag)
			dock_controller_map[shuttle.docking_controller_tag] = shuttle
		if (istype(shuttle, /datum/shuttle/ferry/multidock))
			multidock = shuttle
			dock_controller_map_station[multidock.docking_controller_tag_station] = multidock
			dock_controller_map_offsite[multidock.docking_controller_tag_offsite] = multidock

	//escape pod arming controllers
	var/datum/shuttle/ferry/escape_pod/pod
	var/list/pod_controller_map = list()
	for (var/datum/shuttle/ferry/escape_pod/P in emergency_shuttle.escape_pods)
		if (P.dock_target_station)
			pod_controller_map[P.dock_target_station] = P

	//search for the controllers, if we have one.
	if (dock_controller_map.len)
		for (var/obj/machinery/embedded_controller/radio/C in machines)	//only radio controllers are supported at the moment
			if (istype(C.program, /datum/computer/file/embedded_program/docking))
				if (C.id_tag in dock_controller_map)
					shuttle = dock_controller_map[C.id_tag]
					shuttle.docking_controller = C.program
					dock_controller_map -= C.id_tag

					//escape pods
					if(istype(C, /obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod) && istype(shuttle, /datum/shuttle/ferry/escape_pod))
						var/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod/EPC = C
						EPC.pod = shuttle

				if (C.id_tag in dock_controller_map_station)
					multidock = dock_controller_map_station[C.id_tag]
					if (istype(multidock))
						multidock.docking_controller_station = C.program
						dock_controller_map_station -= C.id_tag
				if (C.id_tag in dock_controller_map_offsite)
					multidock = dock_controller_map_offsite[C.id_tag]
					if (istype(multidock))
						multidock.docking_controller_offsite = C.program
						dock_controller_map_offsite -= C.id_tag

				//escape pods
				if (C.id_tag in pod_controller_map)
					pod = pod_controller_map[C.id_tag]
					if (istype(C.program, /datum/computer/file/embedded_program/docking/simple/escape_pod/))
						pod.arming_controller = C.program

	//sanity check
	if (dock_controller_map.len || dock_controller_map_station.len || dock_controller_map_offsite.len)
		var/dat = ""
		for (var/dock_tag in dock_controller_map + dock_controller_map_station + dock_controller_map_offsite)
			dat += "\"[dock_tag]\", "
		world << "\red \b warning: shuttles with docking tags [dat] could not find their controllers!"

	//makes all shuttles docked to something at round start go into the docked state
	for (var/shuttle_tag in shuttles)
		shuttle = shuttles[shuttle_tag]
		shuttle.dock()
