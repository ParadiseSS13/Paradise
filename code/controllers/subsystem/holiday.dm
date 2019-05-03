SUBSYSTEM_DEF(holiday)
	name = "Holiday"
	init_order = INIT_ORDER_HOLIDAY // 3
	flags = SS_NO_FIRE
	wait = 1200
	var/list/holidays
	var/holiday = null

/datum/controller/subsystem/holiday/Initialize(start_timeofday)
	if(!config.allow_holidays)
		return ..() //holiday stuff was not enabled in the config!

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

	Get_holiday()
	return ..()

// Only do this every 2 minutes
/datum/controller/subsystem/holiday/fire()
	switch(holiday)			//special holidays

		if("",null)			//no holiday today! Back to work!
			return

		if("Christmas","Christmas Eve")
			if(prob(eventchance))
				ChristmasEvent()

/datum/controller/subsystem/holiday/proc/Get_holiday()
	if(!holiday)	return		// holiday stuff was not enabled in the config!

	holiday = null				// reset our switch now so we can recycle it as our holiday name

	var/YY	=	text2num(time2text(world.timeofday, "YY")) 	// get the current year
	var/MM	=	text2num(time2text(world.timeofday, "MM")) 	// get the current month
	var/DD	=	text2num(time2text(world.timeofday, "DD")) 	// get the current day

	//Main switch. If any of these are too dumb/inappropriate, or you have better ones, feel free to change whatever
	switch(MM)
		if(1)	//Jan
			switch(DD)
				if(1)							holiday = "New Year's Day"

		if(2)	//Feb
			switch(DD)
				if(2)							holiday = "Groundhog Day"
				if(14)							holiday = "Valentine's Day"
				if(17)							holiday = "Random Acts of Kindness Day"

		if(3)	//Mar
			switch(DD)
				if(14)							holiday = "Pi Day"
				if(17)							holiday = "St. Patrick's Day"
				if(27)
					if(YY == 16)
						holiday = "Easter"
				if(31)
					if(YY == 13)
						holiday = "Easter"

		if(4)	//Apr
			switch(DD)
				if(1)
					holiday = "April Fool's Day"
					if(YY == 18 && prob(50)) 	holiday = "Easter"
				if(5)
					if(YY == 15)				holiday = "Easter"
				if(16)
					if(YY == 17)				holiday = "Easter"
				if(20)
					holiday = "Four-Twenty"
					if(YY == 14 && prob(50))	holiday = "Easter"
				if(22)							holiday = "Earth Day"

		if(5)	//May
			switch(DD)
				if(1)							holiday = "Labour Day"
				if(4)							holiday = "FireFighter's Day"
				if(12)							holiday = "Owl and Pussycat Day"	//what a dumb day of observence...but we -do- have costumes already :3

		if(6)	//Jun

		if(7)	//Jul
			switch(DD)
				if(1)							holiday = "Doctor's Day"
				if(2)							holiday = "UFO Day"
				if(8)							holiday = "Writer's Day"
				if(30)							holiday = "Friendship Day"

		if(8)	//Aug
			switch(DD)
				if(5)							holiday = "Beer Day"

		if(9)	//Sep
			switch(DD)
				if(19)							holiday = "Talk-Like-a-Pirate Day"
				if(28)							holiday = "Stupid-Questions Day"

		if(10)	//Oct
			switch(DD)
				if(4)							holiday = "Animal's Day"
				if(7)							holiday = "Smiling Day"
				if(16)							holiday = "Boss' Day"
				if(31)							holiday = "Halloween"

		if(11)	//Nov
			switch(DD)
				if(1)							holiday = "Vegan Day"
				if(13)							holiday = "Kindness Day"
				if(19)							holiday = "Flowers Day"
				if(21)							holiday = "Saying-'Hello' Day"

		if(12)	//Dec
			switch(DD)
				if(10)							holiday = "Human-Rights Day"
				if(14)							holiday = "Monkey Day"
				if(21)							if(YY==12)	holiday = "End of the World"
				if(22)							holiday = "Orgasming Day"		//lol. These all actually exist
				if(24)							holiday = "Christmas Eve"
				if(25)							holiday = "Christmas"
				if(26)							holiday = "Boxing Day"
				if(31)							holiday = "New Year's Eve"

	if(!holiday)
		//Friday the 13th
		if(DD == 13)
			if(time2text(world.timeofday, "DDD") == "Fri")
				holiday = "Friday the 13th"

//Run at the  start of a round
/datum/controller/subsystem/holiday/proc/holiday_game_start()
	if(holiday)
		to_chat(world, "<font color='blue'>and...</font>")
		to_chat(world, "<h4>Happy [holiday] Everybody!</h4>")
		switch(holiday)			//special holidays
			if("Easter")
				//do easter stuff
			if("Christmas Eve","Christmas")
				Christmas_Game_Start()

	return

/datum/controller/subsystem/holiday/proc/Christmas_Game_Start()
	for(var/obj/structure/flora/tree/pine/xmas in world)
		if(!is_station_level(xmas.z))	continue
		for(var/turf/simulated/floor/T in orange(1,xmas))
			for(var/i=1,i<=rand(1,5),i++)
				new /obj/item/a_gift(T)
	for(var/mob/living/simple_animal/pet/corgi/Ian/Ian in GLOB.mob_list) // How this didnt error before? Oh wait. IT WAS A FUCKING HOOK
		Ian.place_on_head(new /obj/item/clothing/head/helmet/space/santahat(Ian))

/datum/controller/subsystem/holiday/proc/ChristmasEvent()
	for(var/obj/structure/flora/tree/pine/xmas in world)
		var/mob/living/simple_animal/hostile/tree/evil_tree = new /mob/living/simple_animal/hostile/tree(xmas.loc)
		evil_tree.icon_state = xmas.icon_state
		evil_tree.icon_living = evil_tree.icon_state
		evil_tree.icon_dead = evil_tree.icon_state
		evil_tree.icon_gib = evil_tree.icon_state
		qdel(xmas)