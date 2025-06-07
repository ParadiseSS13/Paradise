SUBSYSTEM_DEF(metrics)
	name = "Metrics"
	wait = 30 SECONDS
	offline_implications = "Server metrics will no longer be ingested into monitoring systems. No immediate action is needed."
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME // ALL THE LEVELS
	flags = SS_KEEP_TIMING // This needs to ingest every 30 IRL seconds, not ingame seconds.
	cpu_display = SS_CPUDISPLAY_LOW
	/// The real time of day the server started. Used to calculate time drift
	var/world_init_time = 0 // Not set in here. Set in world/New()

/datum/controller/subsystem/metrics/Initialize()
	if(!GLOB.configuration.metrics.enable_metrics)
		flags |= SS_NO_FIRE // Disable firing to save CPU


/datum/controller/subsystem/metrics/fire(resumed)
	SShttp.create_async_request(RUSTLIBS_HTTP_METHOD_POST, GLOB.configuration.metrics.metrics_endpoint, get_metrics_json(), list(
		"Authorization" = "ApiKey [GLOB.configuration.metrics.metrics_api_token]",
		"Content-Type" = "application/json"
	))

/datum/controller/subsystem/metrics/proc/get_metrics_json()
	var/list/out = list()
	out["@timestamp"] = time_stamp() // This is required by ElasticSearch, complete with this name. DO NOT REMOVE THIS.
	out["cpu"] = world.cpu
	out["maptick"] = world.map_cpu
	out["elapsed_processed"] = world.time
	out["elapsed_real"] = (REALTIMEOFDAY - world_init_time)
	out["client_count"] = length(GLOB.clients)
	out["round_id"] = text2num(GLOB.round_id) // This is so we can filter the metrics by a single round ID
	out["server_id"] = GLOB.configuration.system.instance_id // And this is so we can filter by instance ID

	// Funnel in all SS metrics
	var/list/ss_data = list()
	for(var/datum/controller/subsystem/SS in Master.subsystems)
		ss_data[SS.ss_id] = SS.get_metrics()

	out["subsystems"] = ss_data
	// And send it all
	return json_encode(out)

/*

// Uncomment this if you add new metrics to verify how the JSON formats

/client/verb/debugmetricts()
	usr << browse(SSmetrics.get_metrics_json(), "window=aadebug")
*/
