var/global/datum/controller/process/ticker/tickerProcess

/datum/controller/process/ticker
	var/lastTickerTimeDuration
	var/lastTickerTime

/datum/controller/process/ticker/setup()
	name = "ticker"
	schedule_interval = 20 // every 2 seconds

	lastTickerTime = world.timeofday
	log_startup_progress("Time ticker starting up.")

	if(!ticker)
		ticker = new

	spawn(0)
		if(ticker)
			ticker.pregame()

DECLARE_GLOBAL_CONTROLLER(ticker, tickerProcess)

/datum/controller/process/ticker/doWork()
	var/currentTime = world.timeofday

	if(currentTime < lastTickerTime) // check for midnight rollover
		lastTickerTimeDuration = (currentTime - (lastTickerTime - TICKS_IN_DAY)) / TICKS_IN_SECOND
	else
		lastTickerTimeDuration = (currentTime - lastTickerTime) / TICKS_IN_SECOND

	lastTickerTime = currentTime

	ticker.process()

/datum/controller/process/ticker/proc/getLastTickerTimeDuration()
	return lastTickerTimeDuration
