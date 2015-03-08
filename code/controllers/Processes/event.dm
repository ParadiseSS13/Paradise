/datum/controller/process/event/setup()
	name = "event"
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/event/doWork()
	event_manager.process()