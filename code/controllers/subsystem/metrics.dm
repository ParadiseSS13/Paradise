SUBSYSTEM_DEF(metrics)
	name = "Metrics"
	flags = SS_NO_INIT
	wait = 1 MINUTES
	offline_implications = "Server metrics will no longer be ingested into monitoring systems. No immediate action is needed."
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME // ALL THE LEVELS
	/// The real time of day the server started. Used to calculate time drift
	var/world_init_time = 0 // Not set in here. Set in world/New()

/datum/controller/subsystem/metrics/fire(resumed)
	// AA TODO
	return

/datum/controller/subsystem/metrics/proc/get_metrics_json()
	var/list/out = list()
	out["cpu"] = world.cpu
	// out["maptick"] = world.map_cpu // TODO: 514
	out["elapsed_processed"] = world.time
	out["elapsed_real"] = (REALTIMEOFDAY - world_init_time)
	out["client_count"] = length(GLOB.clients)
	out["round_id"] = text2num(GLOB.round_id) // This is so we can filter the metrics by a single round ID

	// Funnel in all SS metrics
	var/list/ss_data = list()
	for(var/datum/controller/subsystem/SS in Master.subsystems)
		ss_data[SS.ss_id] = SS.get_metrics()

	out["subsystems"] = ss_data
	// And send it all
	return json_encode(out)
