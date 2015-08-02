/datum/controller/process/alarm/setup()
	name = "alarm"
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/alarm/doWork()
	alarm_manager.fire()
