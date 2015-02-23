/datum/controller/process/bot/setup()
	name = "bot controller"
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/bot/doWork()
	for(var/obj/machinery/bot/Bot in aibots)
		if(!Bot.gc_destroyed)
			spawn(0)
				Bot.bot_process()
			continue
		aibots -= Bot