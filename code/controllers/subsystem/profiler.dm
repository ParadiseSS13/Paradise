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

/datum/controller/subsystem/profiler/stat_entry()
	..("F:[round(fetch_cost, 1)]ms | W:[round(write_cost, 1)]ms")

/datum/controller/subsystem/profiler/Initialize()
	if(!config.auto_profile)
		StopProfiling() //Stop the early start profiler if we dont want it on in the config
		flags |= SS_NO_FIRE
	return ..()

/datum/controller/subsystem/profiler/fire()
	DumpFile()

/datum/controller/subsystem/profiler/Shutdown()
	if(config.auto_profile)
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
	var/current_profile_data = world.Profile(PROFILE_REFRESH, format = "json")
	fetch_cost = MC_AVERAGE(fetch_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
	CHECK_TICK
	if(!length(current_profile_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, profiling stopped manually before dump.")
	var/json_file = file("[GLOB.log_directory]/profile.json")
	if(fexists(json_file))
		fdel(json_file)
	timer = TICK_USAGE_REAL
	WRITE_FILE(json_file, current_profile_data)
	write_cost = MC_AVERAGE(write_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
