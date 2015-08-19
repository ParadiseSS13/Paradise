/datum/controller/process/emergencyShuttle/setup()
	name = "e-shuttle"
	schedule_interval = 20 // every 2 seconds

	if(!emergency_shuttle)
		emergency_shuttle = new

/datum/controller/process/emergencyShuttle/doWork()
	emergency_shuttle.process()
