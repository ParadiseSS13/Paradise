PROCESSING_SUBSYSTEM_DEF(fluid)
	name = "Fluids"
	priority = FIRE_PRIORITY_OBJ
	wait = 0.5 SECONDS
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	offline_implications = "Fluid machinery will no longer run. No immediate action required." // Fluids are not something crucial to the round
	/// A list with all fluid datums that have to be rebuilt next tick. Associated
	var/list/datums_to_rebuild = list()

GLOBAL_LIST_EMPTY(fluid_id_to_path)
GLOBAL_LIST_EMPTY(fluid_name_to_path)

/datum/controller/subsystem/processing/fluid/Initialize()
	. = ..()
	for(var/datum/fluid/liquid as anything in subtypesof(/datum/fluid))
		GLOB.fluid_id_to_path[liquid.fluid_id] = liquid.type
		GLOB.fluid_name_to_path[liquid.fluid_name] = liquid.type

/datum/controller/subsystem/processing/fluid/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["fluids"] = length(processing)
	.["custom"] = cust

/datum/controller/subsystem/processing/fluid/fire(resumed = FALSE)
	if(!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(length(current_run))
		var/datum/thing = current_run[length(current_run)]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		else if(thing.process(wait) == PROCESS_KILL)
			// fully stop so that a future START_PROCESSING will work
			STOP_PROCESSING(src, thing)
		if(MC_TICK_CHECK)
			return

	if(!length(datums_to_rebuild))
		return
	for(var/rebuild_list as anything in datums_to_rebuild)
		var/datum/fluid_pipe/pipe = rebuild_list[1]
		var/list/neighbours = rebuild_list[2]

		pipe.rebuild_pipenet(neighbours)

	datums_to_rebuild = list()
