/datum/controller/process/supply/setup()
	name = "supply"
	schedule_interval = 10 // every second

/datum/controller/process/supply/doWork()
	supply_controller.process()