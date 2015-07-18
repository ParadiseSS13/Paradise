/datum/controller/process/supply/setup()
	name = "supply"
	schedule_interval = 300 // every 30 seconds

/datum/controller/process/supply/doWork()
	supply_controller.process()