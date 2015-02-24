/datum/controller/process/bot
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/bot/setup()
	name = "bot"
	schedule_interval = 20 // every 2 seconds
	updateQueueInstance = new

/datum/controller/process/bot/started()
	..()
	if(!updateQueueInstance)
		if(!aibots)
			aibots = list()
		else if(aibots.len)
			updateQueueInstance = new

/datum/controller/process/bot/doWork()
	if(updateQueueInstance)
		updateQueueInstance.init(aibots, "bot_process")
		updateQueueInstance.Run()
