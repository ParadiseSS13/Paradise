PROCESSING_SUBSYSTEM_DEF(obj_tab_items)
	name = "Obj Tab Items"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	wait = 0.1 SECONDS

// I know this is mostly copypasta, but I want to change the processing logic
// Sorry bestie :( // my name is AA and I am putting a ) here to make the bracket pairs right
/datum/controller/subsystem/processing/obj_tab_items/fire(resumed = FALSE)
	if(!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(length(current_run))
		var/datum/thing = current_run[length(current_run)]
		if(QDELETED(thing))
			processing -= thing
		else if(thing.process(wait * 0.1) == PROCESS_KILL)
			// fully stop so that a future START_PROCESSING will work
			STOP_PROCESSING(src, thing)
		if(MC_TICK_CHECK)
			return
		current_run.len--
