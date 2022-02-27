SUBSYSTEM_DEF(profiler)
	name = "Profiler"
	init_order = INIT_ORDER_PROFILER
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	wait = 5 MINUTES
	flags = SS_NO_TICK_CHECK
	/// Time it took to fetch profile data (ms)
	var/fetch_cost = 0
	/// Time it took to write the file (ms)
	var/write_cost = 0
	/// Time it took to encode the data for redis (ms)
	var/send_encode_cost = 0
	/// Time it took to send the stuff down FFI for redis (ms)
	var/send_ffi_cost = 0

/datum/controller/subsystem/profiler/stat_entry()
	..("F:[round(fetch_cost, 1)]ms | W:[round(write_cost, 1)]ms | SE:[round(send_encode_cost, 1)]ms | SF:[round(send_ffi_cost, 1)]ms")

/datum/controller/subsystem/profiler/Initialize()
	if(!GLOB.configuration.general.enable_auto_profiler)
		StopProfiling() //Stop the early start profiler if we dont want it on in the config
		flags |= SS_NO_FIRE
	return ..()

/datum/controller/subsystem/profiler/fire()
	DumpFile()

/datum/controller/subsystem/profiler/Shutdown()
	if(GLOB.configuration.general.enable_auto_profiler)
		DumpFile()
	return ..()

// These procs may seem useless, but they exist like this so we can proc call them on and off
// You cant proc-call onto /world
/datum/controller/subsystem/profiler/proc/StartProfiling()
	world.Profile(PROFILE_START)

/datum/controller/subsystem/profiler/proc/StopProfiling()
	world.Profile(PROFILE_STOP)

// Write the file while also cost tracking
/datum/controller/subsystem/profiler/proc/DumpFile()
	var/timer = TICK_USAGE_REAL
	// Fetch info
	var/current_profile_data = world.Profile(PROFILE_REFRESH, format = "json")
	fetch_cost = MC_AVERAGE(fetch_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
	CHECK_TICK
	if(!length(current_profile_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, profiling stopped manually before dump.")
	var/json_file = file("[GLOB.log_directory]/profile.json")
	// Put it in a file
	if(fexists(json_file))
		fdel(json_file)
	timer = TICK_USAGE_REAL
	WRITE_FILE(json_file, current_profile_data)
	write_cost = MC_AVERAGE(write_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

	// Send it down redis
	if(SSredis.connected)
		// Encode
		timer = TICK_USAGE_REAL

		var/list/ffi_data = list()
		ffi_data["round_id"] = GLOB.round_id
		// We dont have to JSON decode here. The other end can worry about a 2-layer decode.
		// Performance matters on this end. It doesnt on the other end
		ffi_data["profile_data"] = current_profile_data
		var/ffi_string = json_encode(ffi_data)
		send_encode_cost = MC_AVERAGE(send_encode_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		// Now actually fire it off
		timer = TICK_USAGE_REAL
		SSredis.publish("profilerdaemon.input", ffi_string)
		send_ffi_cost = MC_AVERAGE(send_ffi_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
