var/global/datum/controller/process/sun/sun

/datum/controller/process/sun
	var/angle
	var/dx
	var/dy
	var/rate
	var/list/solars	= list()		// for debugging purposes, references solars list at the constructor

/datum/controller/process/sun/setup()
	name = "sun"
	schedule_interval = 600 // every 60 seconds
	sun = src
	log_startup_progress("Sun ticker starting up.")

	angle = rand (0,360)			// the station position to the sun is randomised at round start
	rate = rand(50,200)/100			// 50% - 200% of standard rotation
	if(prob(50))					// same chance to rotate clockwise than counter-clockwise
		rate = -rate

/datum/controller/process/sun/doWork()
	calc_position()
	update_solar_machinery()


// calculate the sun's position given the time of day
// at the standard rate (100%) the angle is increase/decreased by 6 degrees every minute.
// a full rotation thus take a game hour in that case
/datum/controller/process/sun/proc/calc_position()
	angle = (360 + angle + rate * 6) % 360	 // increase/decrease the angle to the sun, adjusted by the rate

	// now calculate and cache the (dx,dy) increments for line drawing
	var/s = sin(angle)
	var/c = cos(angle)

	// Either "abs(s) < abs(c)" or "abs(s) >= abs(c)"
	// In both cases, the greater is greater than 0, so, no "if 0" check is needed for the divisions

	if(abs(s) < abs(c))
		dx = s / abs(c)
		dy = c / abs(c)
	else
		dx = s / abs(s)
		dy = c / abs(s)

//now tell the solar control computers to update their status and linked devices
/datum/controller/process/sun/proc/update_solar_machinery()
	for(last_object in solars)
		var/obj/machinery/power/solar_control/SC = last_object
		if(istype(SC) && isnull(SC.gcDestroyed))
			if(!SC.powernet)
				solars -= SC
				continue
			try
				SC.update()
			catch(var/exception/e)
				catchException(e, SC)
			SCHECK
		else
			catchBadType(SC)
			solars -= SC
