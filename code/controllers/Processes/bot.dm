/datum/controller/process/bot/setup()
	name = "bot"
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/bot/started()
	..()
	if(!aibots)
		aibots = list()

/datum/controller/process/bot/statProcess()
	..()
	stat(null, "[aibots && aibots.len] bots")

/datum/controller/process/bot/doWork()
	for(last_object in aibots)
		var/obj/machinery/bot/B = last_object
		if(istype(B) && isnull(B.gcDestroyed))
			// Some bots sleep when they process, but there's not many bots, so just spawn them off
			spawn(-1)
				try
					B.bot_process()
				catch(var/exception/e)
					catchException(e, B)
			SCHECK
		else
			catchBadType(B)
			aibots -= B
