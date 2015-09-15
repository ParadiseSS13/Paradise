// So you can be all 10 SECONDS
#define SECONDS *10
#define MINUTES *600
#define HOURS   *36000

//Returns the world time in english
/proc/worldtime2text(time = world.time)
	return "[round(time / 36000)+12]:[(time / 600 % 60) < 10 ? add_zero(time / 600 % 60, 1) : time / 600 % 60]"

/proc/time_stamp()
	return time2text(world.timeofday, "hh:mm:ss")
	
/proc/gameTimestamp(format = "hh:mm:ss") // Get the game time in text
	return time2text(world.time - timezoneOffset + 432000, format)

/* Returns 1 if it is the selected month and day */
proc/isDay(var/month, var/day)
	if(isnum(month) && isnum(day))
		var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
		var/DD = text2num(time2text(world.timeofday, "DD")) // get the current day
		if(month == MM && day == DD)
			return 1

		// Uncomment this out when debugging!
		//else
			//return 1

//returns timestamp in a sql and ISO 8601 friendly format
/proc/SQLtime()
	return time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

/**
 * Returns "watch handle" (really just a timestamp :V)
 */
/proc/start_watch()
	return world.timeofday

/**
 * Returns number of seconds elapsed.
 * @param wh number The "Watch Handle" from start_watch(). (timestamp)
 */
/proc/stop_watch(wh)
	return round(0.1*(world.timeofday-wh),0.1)
	
/proc/month2number(month)
	return month_names.Find(month)
	