SUBSYSTEM_DEF(science_satellite)
	name = "Science Satellite"
	init_order = INIT_ORDER_SCIENCE_SATELLTIE
	priority = FIRE_PRIORITY_SCIENCE_SATELLITE
	wait = 1 SECONDS
	flags = SS_KEEP_TIMING
	offline_implications = "The game will no longer update satellite positions, or generate new points to gather science from. Data science will be impossible."
	cpu_display = SS_CPUDISPLAY_LOW
	var/list/satellites = list()

/datum/controller/subsystem/science_satellite/Initialize()
	// TODO: generate weather effects
	return

/datum/controller/subsystem/science_satellite/fire()
	// TODO: Handle list of satellites
	log_debug("subsystem/science_satellite fired for [satellites.len] satellites ")
	for(var/obj/machinery/science_satellite/satellite in satellites)
		satellite.orbit_data.heartbeat()
	return
