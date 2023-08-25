#define GET_CURRENT_SCAN_VALUE(generator, critical_multiplier, is_critical) (generator.Rand() * (is_critical ? critical_multiplier : 1))

/datum/component/bluespace_rift_scanner
	var/max_range

	/// Goal points farmed per second, mean value.
	var/goal_points_increment = 2.3
	/// How much the value can deviate, 0 <= deviation <= 1, 0 means no deviation.
	var/goal_points_deviation = 0.5
	/// How the value should change when the scanner is too close to a rift, 1 means no change.
	var/goal_points_critical_multiplier = 1.2

	/// Event expectancy added per second during scan. See the units in the `/datum/brs_event_container` definition.
	var/event_increment = 4.15
	/// How much the value can deviate, 0 <= deviation <= 1, 0 means no deviation.
	var/event_increment_deviation = 0.5
	/// How the value should change when the scanner is too close to a rift, 1 means no change.
	var/event_increment_critical_multiplier = 4.8

	var/generator/goal_points_generator
	var/generator/event_increment_generator

/datum/component/bluespace_rift_scanner/Initialize(max_range)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.max_range = max_range

	// validate deviations
	goal_points_deviation = clamp(goal_points_deviation, 0, 1)
	event_increment_deviation = clamp(event_increment_deviation, 0, 1)

	// init random number generators
	goal_points_generator = generator(
		"num",
		goal_points_increment - (goal_points_increment * goal_points_deviation),
		goal_points_increment + (goal_points_increment * goal_points_deviation)
	)
	event_increment_generator = generator(
		"num",
		event_increment - (event_increment * event_increment_deviation),
		event_increment + (event_increment * event_increment_deviation)
	)

/datum/component/bluespace_rift_scanner/RegisterWithParent()
	RegisterSignal(parent, COMSIG_SCANNING_RIFTS, PROC_REF(scan))

/datum/component/bluespace_rift_scanner/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_SCANNING_RIFTS)

/datum/component/bluespace_rift_scanner/proc/scan(datum/source, seconds, emagged)
	var/scanner_status_after_scan = COMPONENT_SCANNED_NOTHING
	var/is_there_any_servers = FALSE

	for(var/datum/bluespace_rift/rift as anything in GLOB.bluespace_rifts_list)

		var/rift_scanned = FALSE
		var/is_critical = FALSE

		for(var/obj/effect/abstract/bluespace_rift/rift_obj as anything in rift.rift_objects)
			var/dist_to_rift = get_dist(parent, rift_obj)
			if(dist_to_rift <= rift_obj.scanner_overload_range)
				rift_scanned = TRUE
				is_critical = TRUE
			else if(dist_to_rift <= max_range)
				rift_scanned = TRUE

		if(emagged && rift_scanned)
			is_critical = TRUE

		// Update scanner status
		var/scan_status = COMPONENT_SCANNED_NOTHING
		if(is_critical)
			scan_status = COMPONENT_SCANNED_CRITICAL
		else if(rift_scanned)
			scan_status = COMPONENT_SCANNED_NORMAL
		
		scanner_status_after_scan = max(scanner_status_after_scan, scan_status)

		if(!rift_scanned)
			continue

		// Trigger events
		var/events_mined = seconds * GET_CURRENT_SCAN_VALUE(event_increment_generator, event_increment_critical_multiplier, is_critical)
		rift.events_mined += events_mined
		rift.times_rift_scanned += 1

		// Send mined goal points
		if(!length(GLOB.bluespace_rifts_server_list))
			continue
		
		var/goal_points_mined = seconds * GET_CURRENT_SCAN_VALUE(goal_points_generator, goal_points_critical_multiplier, is_critical)
		var/probe_points_mined = goal_points_mined / length(GLOB.bluespace_rifts_server_list)

		for(var/obj/machinery/brs_server/server as anything in GLOB.bluespace_rifts_server_list)
			if(server.stat & (NOPOWER|BROKEN))
				continue
			is_there_any_servers = TRUE
			server.add_points(rift.goal_uid, goal_points_mined, probe_points_mined)

	if(!is_there_any_servers)
		scanner_status_after_scan |= COMPONENT_SCANNED_NO_SERVERS

	return scanner_status_after_scan
