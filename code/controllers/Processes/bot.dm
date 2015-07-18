/datum/controller/process/bot

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
	for(var/obj/machinery/bot/B in aibots)
		if(istype(B) && isnull(B.gcDestroyed))
			// Some bots sleep when they process, but there's not many bots, so just spawn them off
			spawn(-1)
				try
					B.bot_process()
				catch(var/exception/e)
					catchException(e, B)
			// Use src explicitly after a try/catch, or BYOND messes src up. I have no idea why.
			src.scheck()
		else
			aibots -= B