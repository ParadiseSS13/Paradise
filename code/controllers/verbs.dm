//TODO: rewrite and standardise all controller datums to the datum/controller type
//TODO: allow all controllers to be deleted for clean restarts (see WIP master controller stuff) - MC done - lighting done


/client/proc/restart_controller(controller in list("Master","Failsafe"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restart one of the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return
	usr = null
	src = null
	switch(controller)
		if("Failsafe")
			new /datum/controller/failsafe()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "RFailsafe")
	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")
	return

/client/proc/debug_controller(controller in list("failsafe","Scheduler","StonedMaster","Ticker","Air","Jobs","Sun","Radio","Configuration","pAI",
	"Cameras","Garbage", "Transfer Controller","Event","Alarm","Nano","Vote","Fires",
	"Mob","NPC AI","Shuttle","Timer","Weather","Space","Mob Hunt Server"))
	set category = "Debug"
	set name = "Debug Controller"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return
	switch(controller)
		if("failsafe")
			debug_variables(Failsafe)
			SSblackbox.record_feedback("tally", "admin_verb", 1,  "dfailsafe")
		if("Scheduler")
			debug_variables(processScheduler)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DprocessScheduler")
		if("StonedMaster")
			debug_variables(Master)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Dsmc")
		if("Ticker")
			debug_variables(ticker)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DTicker")
		if("Air")
			debug_variables(SSair)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DAir")
		if("Jobs")
			debug_variables(SSjobs)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DJobs")
		if("Sun")
			debug_variables(SSsun)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DSun")
		if("Radio")
			debug_variables(SSradio)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DRadio")
		if("Configuration")
			debug_variables(config)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DConf")
		if("pAI")
			debug_variables(paiController)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DpAI")
		if("Cameras")
			debug_variables(cameranet)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DCameras")
		if("Event")
			debug_variables(SSevents)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DEvent")
		if("Alarm")
			debug_variables(SSalarms)
			SSblackbox.record_feedback("tally", "admin_verb", 1,  "DAlarm")
		if("Garbage")
			debug_variables(SSgarbage)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DGarbage")
		if("Nano")
			debug_variables(SSnanoui)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DNano")
		if("Vote")
			debug_variables(SSvote)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DVote")
		if("Fires")
			debug_variables(SSfires)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DFires")
		if("Mob")
			debug_variables(SSmobs)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DMob")
		if("NPC AI")
			debug_variables(SSnpcai)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DNPCAI")
		if("Shuttle")
			debug_variables(SSshuttle)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DShuttle")
		if("Timer")
			debug_variables(SStimer)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DTimer")
		if("Weather")
			debug_variables(SSweather)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DWeather")
		if("Space")
			debug_variables(space_manager)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DSpace")
		if("Mob Hunt Server")
			debug_variables(SSmob_hunt)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "DMobHuntServer")

	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
	return
