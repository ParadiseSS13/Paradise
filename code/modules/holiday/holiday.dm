/datum/holiday
	var/name = "Bugsgiving"
	//Right now, only holidays that take place on a certain day or within a time period are supported
	//It would be nice to support things like "the second monday in march" or "the first sunday after the second sunday in june"
	var/begin_day = 1
	var/begin_month = 0
	var/end_day = 0 // Default of 0 means the holiday lasts a single day
	var/end_month = 0
	var/eventChance = 0

// This proc gets run before the game starts when the holiday is activated. Do festive shit here.
/datum/holiday/proc/celebrate()

// When the round starts, this proc is ran to get a text message to display to everyone to wish them a happy holiday
/datum/holiday/proc/greet()
	return "Have a happy [name]!"

// Returns special prefixes for the station name on certain days. You wind up with names like "Christmas Object Epsilon". See new_station_name()
/datum/holiday/proc/getStationPrefix()
	//get the first word of the Holiday and use that
	var/i = findtext(name," ",1,0)
	return copytext(name,1,i)

// Return 1 if this holidy should be celebrated today
/datum/holiday/proc/shouldCelebrate(dd, mm, yy)
	if(!end_day)
		end_day = begin_day
	if(!end_month)
		end_month = begin_month

	if(end_month > begin_month) //holiday spans multiple months in one year
		if(mm == end_month) //in final month
			if(dd <= end_day)
				return 1

		else if(mm == begin_month)//in first month
			if(dd >= begin_day)
				return 1

		else if(mm in begin_month to end_month) //holiday spans 3+ months and we're in the middle, day doesn't matter at all
			return 1

	else if(end_month == begin_month) // starts and stops in same month, simplest case
		if(mm == begin_month && (dd in begin_day to end_day))
			return 1

	else // starts in one year, ends in the next
		if(mm >= begin_month && dd >= begin_day) // Holiday ends next year
			return 1
		if(mm <= end_month && dd <= end_day) // Holiday started last year
			return 1

	return 0

/datum/holiday/proc/handle_event() //used for special holiday events
	return

// The actual holidays

/datum/holiday/new_year
	name = NEW_YEAR
	begin_day = 30 // 1 day early
	begin_month = DECEMBER
	end_day = 5 //4 days extra
	end_month = JANUARY

/datum/holiday/valentines
	name = VALENTINES
	begin_day = 9 //6 days early
	begin_month = FEBRUARY
	end_day = 15 //1 day extra

/datum/holiday/april_fools
	name = APRIL_FOOLS
	begin_day = 1
	begin_month = APRIL
	end_day = 8 //7 days extra so everyone can enjoy the festivities

// No holidays in June :'(

/datum/holiday/halloween
	name = HALLOWEEN
	begin_day = 24 //7 days early
	begin_month = OCTOBER
	end_day = 7 //7 days extra
	end_month = NOVEMBER

/datum/holiday/halloween/greet()
	return "Have a spooky Halloween!"

/datum/holiday/monkey
	name = "Monkey Day"
	begin_day = 14
	begin_month = DECEMBER

/datum/holiday/xmas
	name = CHRISTMAS
	begin_day = 18 //7 days early
	begin_month = DECEMBER
	end_day = 8 //14 days extra, christmas is important
	end_month = JANUARY
	eventChance = 20

/datum/holiday/xmas/greet()
	var/greeting = "Have a merry Christmas!"
	if(prob(30))
		greeting += "<br><br>To celebrate, choose a random crewmate on the Manifest and give them a gift!"
	return greeting

/datum/holiday/friday_thirteenth
	name = "Friday the 13th"

/datum/holiday/friday_thirteenth/shouldCelebrate(dd, mm, yy)
	if(dd == 13)
		if(time2text(world.timeofday, "DDD") == "Fri")
			return 1
	return 0

/datum/holiday/friday_thirteenth/getStationPrefix()
	return pick("Mike","Friday","Evil","Myers","Murder","Deathly","Stabby")

/datum/holiday/easter
	name = EASTER
	var/const/days_early = 1 //to make editing the holiday easier
	var/const/days_extra = 6

/datum/holiday/easter/shouldCelebrate(dd, mm, yy)
// Easter's celebration day is as snowflakey as Uhangi's code

	if(!begin_month)

		var/yy_string = "[yy]"
// year = days after March 22that Easter falls on that year.
// For 2015 Easter is on April 5th, so 2015 = 14 since the 5th is 14 days past the 22nd
// If it's 2040 and this is still in use, invent a time machine and teach me a better way to do this. Also tell us about HL3.
		var/list/easters = list(
		"15" = 14,\
		"16" = 6,\
		"17" = 25,\
		"18" = 10,\
		"19" = 30,\
		"20" = 22,\
		"21" = 13,\
		"22" = 26,\
		"23" = 18,\
		"24" = 9,\
		"25" = 29,\
		"26" = 14,\
		"27" = 6,\
		"28" = 25,\
		"29" = 10,\
		"30" = 30,\
		"31" = 23,\
		"32" = 6,\
		"33" = 26,\
		"34" = 18,\
		"35" = 3,\
		"36" = 22,\
		"37" = 14,\
		"38" = 34,\
		"39" = 19,\
		"40" = 9,\
		)

		begin_day = easters[yy_string]
		if(begin_day <= 9)
			begin_day += 22
			begin_month = MARCH
		else
			begin_day -= 9
			begin_month = APRIL

		end_day = begin_day + days_extra
		end_month = begin_month
		if(end_day >= 32 && end_month == MARCH) //begins in march, ends in april
			end_day -= 31
			end_month++
		if(end_day >= 31 && end_month == APRIL) //begins in april, ends in june
			end_day -= 30
			end_month++

		begin_day -= days_early
		if(begin_day <= 0)
			if(begin_month == APRIL)
				begin_day += 31
				begin_month-- //begins in march, ends in april

//	to_chat(world, "Easter calculates to be on [begin_day] of [begin_month] ([days_early] early) to [end_day] of [end_month] ([days_extra] extra) for 20[yy]")
	return ..()


/client/proc/Set_Holiday(T as text|null)
	set name = ".Set Holiday"
	set category = "Event"
	set desc = "Force-set the Holiday variable to make the game think it's a certain day."
	if(!check_rights(R_SERVER))	return

	var/list/choice = list()
	for(var/H in subtypesof(/datum/holiday))
		choice += "[H]"

	choice += "--CANCEL--"

	var/selected = input("What holiday would you like to force?","Holiday Forcing","--CANCEL--") in choice

	if(selected == "--CANCEL--")
		return

	var/selected2path = text2path(selected)
	if(!ispath(selected2path) || !selected2path)	return

	var/datum/holiday/H = new selected2path
	if(!istype(H))	return

	H.celebrate()
	if(!SSholiday.holidays)
		SSholiday.holidays = list()
	SSholiday.holidays[H.name] = H

	//update our hub status
	world.update_status()

	message_admins("<span class='notice'>ADMIN: Event: [key_name_admin(src)] force-set Holiday to \"[H]\"</span>")
	log_admin("[key_name(src)] force-set Holiday to \"[H]\"")
