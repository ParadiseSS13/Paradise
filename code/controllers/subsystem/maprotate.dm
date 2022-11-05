SUBSYSTEM_DEF(maprotate)
	name = "Maprotate"
	flags = SS_NO_FIRE

	var/rotation_mode = MAPROTATION_MODE_NORMAL_VOTE
	var/setup_done = FALSE

// Debugging purposes. Im not having people change this on the fly.
/datum/controller/subsystem/maprotate/vv_edit_var(var_name, var_value)
	if (((var_name == "rotation_mode") || (var_name == "setup_done")) && !check_rights(R_MAINTAINER))
		return FALSE

	. = ..()

/datum/controller/subsystem/maprotate/Initialize(start_timeofday)
	if(!SSdbcore.IsConnected())
		return ..()

	// Yes. I am using the DB server to get a numerical weekday

	// 0 = Monday
	// 1 = Tuesday
	// 2 = Wednesday
	// 3 = Thursday
	// 4 = Friday
	// 5 = Saturday
	// 6 = Sunday

	var/datum/db_query/dbq = SSdbcore.NewQuery("SELECT WEEKDAY(NOW()) AS d")
	if(!dbq.warn_execute())
		log_startup_progress("Somehow, we failed to extract a numerical day from the DB. ?????????????")
		return ..()

	var/day_index = 0

	// Were gonna increase the DB value by 1 so we have 1-7, therefore we can use 0 as fail

	if(dbq.NextRow())
		day_index = text2num(dbq.item[1]) + 1

	qdel(dbq)

	if(!day_index)
		log_startup_progress("Somehow, we failed to extract a valid numerical day from the DB. ?????????????")
		return ..()


	// String interpolation is faster than num2text() for some reason
	var/dindex_str = "[day_index]"

	// Special is defined for this day
	if(dindex_str in GLOB.configuration.vote.map_vote_day_types)
		var/vote_type = GLOB.configuration.vote.map_vote_day_types[dindex_str]
		// We have an index, but is it valid
		if(vote_type in list(MAPROTATION_MODE_NORMAL_VOTE, MAPROTATION_MODE_NO_DUPLICATES, MAPROTATION_MODE_FULL_RANDOM))
			log_startup_progress("It is [num2day(day_index)], which means [mode2string(vote_type)]")
			rotation_mode = vote_type
			setup_done = TRUE

		// Its not valid
		else
			log_startup_progress("The defined rotation mode for this day is invalid. Please inform AA.")

	// No special defined for this day
	else
		log_startup_progress("There is no special rotation defined for this day")


	return ..()

/datum/controller/subsystem/maprotate/proc/num2day(n)
	switch(n)
		if(1)
			return "Monday"
		if(2)
			return "Tuesday"
		if(3)
			return "Wednesday"
		if(4)
			return "Thursday"
		if(5)
			return "Friday"
		if(6)
			return "Saturday"
		if(7)
			return "Sunday"
		else
			return "A day that does not exist in the Gregorian Calendar."

/datum/controller/subsystem/maprotate/proc/mode2string(m)
	switch(m)
		if(MAPROTATION_MODE_NORMAL_VOTE)
			return "there is normal map voting."
		if(MAPROTATION_MODE_NO_DUPLICATES)
			return "map votes will not include the current map."
		if(MAPROTATION_MODE_FULL_RANDOM)
			return "the map for next round is randomised."
