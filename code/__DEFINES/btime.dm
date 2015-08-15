// Comment this out if the external btime library is unavailable
#define PRECISE_TIMER_AVAILABLE

#ifdef PRECISE_TIMER_AVAILABLE
var/global/__btime__libName = "btime.[world.system_type==MS_WINDOWS?"dll":"so"]"
#define TimeOfHour (__extern__timeofhour)
#define __extern__timeofhour text2num(call(__btime__libName, "gettime")())
/hook/startup/proc/checkbtime()
	try
		// This will always return 1 unless the btime library cannot be accessed
		if(TimeOfHour || 1) return 1
	catch(var/exception/e)
		log_to_dd("PRECISE_TIMER_AVAILABLE is defined in btime.dm, but calling the btime library failed: [e]")
		log_to_dd("This is a fatal error. The world will now shut down.")
		del(world)
#else
#define TimeOfHour (world.timeofday % 36000)
#endif
