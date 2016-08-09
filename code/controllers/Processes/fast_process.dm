var/datum/controller/process/fast_process/fast_processes

/datum/controller/process/fast_process
	var/list/currentrun = list()

/datum/controller/process/fast_process/setup()
	name = "fast processing"
	schedule_interval = 2 //every 0.2 seconds
	start_delay = 9
	fast_processes = src
	log_startup_progress("Fast Processing starting up.")

/datum/controller/process/fast_process/statProcess()
	..()
	stat(null, "[fast_processing.len] fast machines")

/datum/controller/process/fast_process/doWork()
	src.currentrun = fast_processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/obj/thing = currentrun[1]
		currentrun.Cut(1, 2)
		if(thing)
			try
				thing.process()
			catch(var/exception/e)
				catchException(e, thing)
		else
			catchBadType(thing)
			fast_processing -= thing