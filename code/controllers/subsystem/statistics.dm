SUBSYSTEM_DEF(statistics)
	name = "Statistics"
	wait = 6000 // 10 minute delay between fires
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME // Only count time actually ingame to avoid logging pre-round dips
	offline_implications = "Player count and admin count statistics will no longer be logged to the database. No immediate action is needed."


/datum/controller/subsystem/statistics/Initialize(start_timeofday)
	if(!config.sql_enabled)
		flags |= SS_NO_FIRE // Disable firing if SQL is disabled
	return ..()

/datum/controller/subsystem/statistics/fire(resumed = 0)
	sql_poll_players()

/datum/controller/subsystem/statistics/proc/sql_poll_players()
	if(!config.sql_enabled)
		return
	var/playercount = GLOB.clients.len
	var/admincount = GLOB.admins.len
	if(!GLOB.dbcon.IsConnected())
		log_game("SQL ERROR during player polling. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = GLOB.dbcon.NewQuery("INSERT INTO [format_table_name("legacy_population")] (playercount, admincount, time) VALUES ([playercount], [admincount], '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during playercount polling. Error: \[[err]\]\n")
