SUBSYSTEM_DEF(maprotate)
	name = "Maprotate"
	flags = SS_NO_FIRE

	var/rotation_mode = MAPROTATION_MODE_NORMAL_VOTE

// Debugging purposes. Im not having people change this on the fly.
/datum/controller/subsystem/maprotate/vv_edit_var(var_name, var_value)
	if (var_name == "rotation_mode" && !check_rights(R_MAINTAINER))
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

	switch(day_index)
		if(2, 4) // Tuesday or thursday
			log_startup_progress("Its Tuesday or Thursday, which means there is no map vote, thus its randomised!")
			rotation_mode = MAPROTATION_MODE_FULL_RANDOM

		if(6, 7) // Saturday or sunday, weekend
			log_startup_progress("Its a weekend, which means the map vote wont contain the current map")
			rotation_mode = MAPROTATION_MODE_NO_DUPLICATES

		else
			log_startup_progress("Its not a weekend, or a Tuesday or Thursday, which means the map vote will contain the current map")
			rotation_mode = MAPROTATION_MODE_NORMAL_VOTE


	return ..()
