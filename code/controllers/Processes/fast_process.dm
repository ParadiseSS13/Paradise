/datum/controller/process/fast_process/setup()
	name = "fast processing"
	schedule_interval = 2 //every 0.2 seconds
	start_delay = 9
	log_startup_progress("Fast Processing starting up.")

/datum/controller/process/fast_process/statProcess()
	..()
	stat(null, "[fast_processing.len] fast machines")

/datum/controller/process/fast_process/doWork()
	for(last_object in fast_processing)
		var/obj/O = last_object
		try
			O.process()
		catch(var/exception/e)
			catchException(e, O)