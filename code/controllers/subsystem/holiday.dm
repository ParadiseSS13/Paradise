SUBSYSTEM_DEF(holiday)
	name = "Holiday"
	init_order = INIT_ORDER_HOLIDAY // 3
	flags = SS_NO_FIRE
	var/list/holidays
	var/Holiday

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

	Get_Holiday()
	return ..()

//sets up the Holiday global variable. Shouldbe called on game configuration or something.
/datum/controller/subsystem/holiday/proc/Get_Holiday()
	if(!Holiday)	return		// Holiday stuff was not enabled in the config!

	Holiday = null				// reset our switch now so we can recycle it as our Holiday name

	var/YY	=	text2num(time2text(world.timeofday, "YY")) 	// get the current year
	var/MM	=	text2num(time2text(world.timeofday, "MM")) 	// get the current month
	var/DD	=	text2num(time2text(world.timeofday, "DD")) 	// get the current day

	//Main switch. If any of these are too dumb/inappropriate, or you have better ones, feel free to change whatever
	switch(MM)
		if(1)	//Jan
			switch(DD)
				if(1)							Holiday = "New Year's Day"

		if(2)	//Feb
			switch(DD)
				if(2)							Holiday = "Groundhog Day"
				if(14)							Holiday = "Valentine's Day"
				if(17)							Holiday = "Random Acts of Kindness Day"

		if(3)	//Mar
			switch(DD)
				if(14)							Holiday = "Pi Day"
				if(17)							Holiday = "St. Patrick's Day"
				if(27)
					if(YY == 16)
						Holiday = "Easter"
				if(31)
					if(YY == 13)
						Holiday = "Easter"

		if(4)	//Apr
			switch(DD)
				if(1)
					Holiday = "April Fool's Day"
					if(YY == 18 && prob(50)) 	Holiday = "Easter"
				if(5)
					if(YY == 15)				Holiday = "Easter"
				if(16)
					if(YY == 17)				Holiday = "Easter"
				if(20)
					Holiday = "Four-Twenty"
					if(YY == 14 && prob(50))	Holiday = "Easter"
				if(22)							Holiday = "Earth Day"

		if(5)	//May
			switch(DD)
				if(1)							Holiday = "Labour Day"
				if(4)							Holiday = "FireFighter's Day"
				if(12)							Holiday = "Owl and Pussycat Day"	//what a dumb day of observence...but we -do- have costumes already :3

		if(6)	//Jun

		if(7)	//Jul
			switch(DD)
				if(1)							Holiday = "Doctor's Day"
				if(2)							Holiday = "UFO Day"
				if(8)							Holiday = "Writer's Day"
				if(30)							Holiday = "Friendship Day"

		if(8)	//Aug
			switch(DD)
				if(5)							Holiday = "Beer Day"

		if(9)	//Sep
			switch(DD)
				if(19)							Holiday = "Talk-Like-a-Pirate Day"
				if(28)							Holiday = "Stupid-Questions Day"

		if(10)	//Oct
			switch(DD)
				if(4)							Holiday = "Animal's Day"
				if(7)							Holiday = "Smiling Day"
				if(16)							Holiday = "Boss' Day"
				if(31)							Holiday = "Halloween"

		if(11)	//Nov
			switch(DD)
				if(1)							Holiday = "Vegan Day"
				if(13)							Holiday = "Kindness Day"
				if(19)							Holiday = "Flowers Day"
				if(21)							Holiday = "Saying-'Hello' Day"

		if(12)	//Dec
			switch(DD)
				if(10)							Holiday = "Human-Rights Day"
				if(14)							Holiday = "Monkey Day"
				if(21)							if(YY==12)	Holiday = "End of the World"
				if(22)							Holiday = "Orgasming Day"		//lol. These all actually exist
				if(24)							Holiday = "Christmas Eve"
				if(25)							Holiday = "Christmas"
				if(26)							Holiday = "Boxing Day"
				if(31)							Holiday = "New Year's Eve"

	if(!Holiday)
		//Friday the 13th
		if(DD == 13)
			if(time2text(world.timeofday, "DDD") == "Fri")
				Holiday = "Friday the 13th"


//Run at the start of a round
/datum/controller/subsystem/holiday/proc/Holiday_Game_Start()
	if(Holiday)
		to_chat(world, "<font color='blue'>and...</font>")
		to_chat(world, "<h4>Happy [Holiday] Everybody!</h4>")
		switch(Holiday)			//special holidays
			if("Easter")
				//do easter stuff
			if("Christmas Eve","Christmas")
				Christmas_Game_Start()
	return
