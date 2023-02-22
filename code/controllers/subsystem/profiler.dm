SUBSYSTEM_DEF(profiler)
	name = "Profiler"
	init_order = INIT_ORDER_PROFILER
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	wait = 5 MINUTES
	flags = SS_NO_TICK_CHECK
	cpu_display = SS_CPUDISPLAY_LOW // its usage itself is high but its every 5 mins so
	/// Time it took to fetch normal profile data (ms)
	var/nfetch_cost = 0
	/// Time it took to write the normal file (ms)
	var/nwrite_cost = 0
	/// Time it took to fetch map profile data (ms)
	var/mfetch_cost = 0
	/// Time it took to write the map file (ms)
	var/mwrite_cost = 0
	/// Time it took to encode the data for redis (ms)
	var/send_encode_cost = 0
	/// Time it took to send the stuff down FFI for redis (ms)
	var/send_ffi_cost = 0

/datum/controller/subsystem/profiler/get_stat_details()
	return "NF:[round(nfetch_cost, 1)]ms | NW:[round(nwrite_cost, 1)]ms | MF:[round(mfetch_cost, 1)]ms | MW:[round(mwrite_cost, 1)]ms | SE:[round(send_encode_cost, 1)]ms | SF:[round(send_ffi_cost, 1)]ms"

/datum/controller/subsystem/profiler/Initialize()
	if(!GLOB.configuration.general.enable_auto_profiler)
		StopProfiling() //Stop the early start profiler if we dont want it on in the config
		flags |= SS_NO_FIRE

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
	world.Profile(PROFILE_START, "sendmaps")

/datum/controller/subsystem/profiler/proc/StopProfiling()
	world.Profile(PROFILE_STOP)
	world.Profile(PROFILE_STOP, "sendmaps")

// Write the file while also cost tracking
/datum/controller/subsystem/profiler/proc/DumpFile()
	var/timer = TICK_USAGE_REAL

	// FETCH PROC PROFILE //

	// Fetch info
	var/current_profile_data = world.Profile(PROFILE_REFRESH, "json")
	nfetch_cost = MC_AVERAGE(nfetch_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
	CHECK_TICK // this shouldnt sleep given its being called from fire() but ehhhhhhhhhhhhhhhh

	if(!length(current_profile_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, profiling stopped manually before dump.")

	var/njson_file = file("[GLOB.log_directory]/profile.json")

	// Put it in a file
	if(fexists(njson_file))
		fdel(njson_file)

	timer = TICK_USAGE_REAL
	WRITE_FILE(njson_file, current_profile_data)
	nwrite_cost = MC_AVERAGE(nwrite_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))



	// FETCH MAPTICK PROFILE //

	// Fetch info
	var/current_sendmaps_data = world.Profile(PROFILE_REFRESH, "sendmaps", "json")
	mfetch_cost = MC_AVERAGE(mfetch_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
	CHECK_TICK

	var/mjson_file = file("[GLOB.log_directory]/map_profile.json")

	// Put it in a file
	if(fexists(mjson_file))
		fdel(mjson_file)

	timer = TICK_USAGE_REAL
	WRITE_FILE(mjson_file, current_sendmaps_data)
	mwrite_cost = MC_AVERAGE(mwrite_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))


	// Send it down redis
	if(!SSredis.connected)
		return

	// Encode
	timer = TICK_USAGE_REAL

	var/list/ffi_data = list()
	ffi_data["round_id"] = GLOB.round_id
	// We dont have to JSON decode here. The other end can worry about a 2-layer decode.
	// Performance matters on this end. It doesnt on the other end
	ffi_data["profile_data"] = current_profile_data
	ffi_data["sendmaps_data"] = current_sendmaps_data
	var/ffi_string = json_encode(ffi_data)
	send_encode_cost = MC_AVERAGE(send_encode_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

	// Now actually fire it off
	timer = TICK_USAGE_REAL
	SSredis.publish("profilerdaemon.input", ffi_string)
	send_ffi_cost = MC_AVERAGE(send_ffi_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
