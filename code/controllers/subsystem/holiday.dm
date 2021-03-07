SUBSYSTEM_DEF(holiday)
	name = "Holiday"
	init_order = INIT_ORDER_HOLIDAY // 3
	flags = SS_NO_FIRE
	var/list/holidays

/datum/controller/subsystem/holiday/Initialize(start_timeofday)
	if(!config.allow_holidays)
		return ..() //Holiday stuff was not enabled in the config!

	var/YY = text2num(time2text(world.timeofday, "YY")) 	// get the current year
	var/MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
	var/DD = text2num(time2text(world.timeofday, "DD")) 	// get the current day

	for(var/H in subtypesof(/datum/holiday))
		var/datum/holiday/holiday = new H()
		if(holiday.shouldCelebrate(DD, MM, YY))
			holiday.celebrate()
			if(!holidays)
				holidays = list()
			holidays[holiday.name] = holiday

	if(holidays)
		holidays = shuffle(holidays)
		world.update_status()
		for(var/datum/holiday/H in holidays)
			if(H.eventChance)
				if(prob(H.eventChance))
					H.handle_event()

	return ..()
