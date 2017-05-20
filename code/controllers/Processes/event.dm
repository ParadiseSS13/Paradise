/datum/controller/process/event/setup()
	name = "event"
	schedule_interval = 20 // every 2 seconds
	if(!holiday_master)
		holiday_master = new
		holiday_master.Setup()

/datum/controller/process/event/doWork()
	event_manager.process()
	holiday_master.process()

/////////
//Holiday controller
/////////

var/global/datum/controller/holiday/holiday_master //This has to be defined before world.

/datum/controller/holiday
	var/list/holidays

/datum/controller/holiday/proc/Setup()
	getHoliday()

/datum/controller/holiday/proc/process()
	if(holiday_master.holidays)
		for(var/datum/holiday/H in holiday_master.holidays)
			if(H.eventChance)
				if(prob(H.eventChance))
					H.handle_event()

/datum/controller/holiday/proc/getHoliday()
	if(!config.allow_holidays)	return //Holiday stuff was not enabled in the config!

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
