/datum/controller/process/event
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/event/setup()
	name = "event"
	schedule_interval = 20 // every 2 seconds
	updateQueueInstance = new

/datum/controller/process/event/doWork()
	updateQueueInstance.init(event_manager, "process")
	updateQueueInstance.Run()

/datum/controller/process/event/onFinish()
	checkEvent()
