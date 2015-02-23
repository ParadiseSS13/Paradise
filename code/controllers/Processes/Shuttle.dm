/datum/controller/process/Shuttle/setup()
	name = "shuttle controller"
	schedule_interval = 20 // every 2 seconds

	if(!shuttle_controller)
		shuttle_controller = new

/datum/controller/process/Shuttle/doWork()
	shuttle_controller.process()
