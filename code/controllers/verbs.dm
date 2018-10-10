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
			feedback_add_details("admin_verb","RFailsafe")
	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")
	return

/client/proc/debug_controller(controller in list("Master",
	"failsafe","Scheduler","StonedMaster","Ticker","Air","Jobs","Sun","Radio","Configuration","pAI",
	"Cameras","Garbage", "Transfer Controller","Event","Alarm","Nano","Vote","Fires",
	"Mob","NPC AI","Shuttle","Timer","Weather","Space","Mob Hunt Server"))
	set category = "Debug"
	set name = "Debug Controller"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return
	switch(controller)
		if("Master")
			debug_variables(master_controller)
			feedback_add_details("admin_verb","DMC")
		if("failsafe")
			debug_variables(Failsafe)
			feedback_add_details("admin_verb", "dfailsafe")
		if("Scheduler")
			debug_variables(processScheduler)
			feedback_add_details("admin_verb","DprocessScheduler")
		if("StonedMaster")
			debug_variables(Master)
			feedback_add_details("admin_verb","Dsmc")
		if("Ticker")
			debug_variables(ticker)
			feedback_add_details("admin_verb","DTicker")
		if("Air")
			debug_variables(SSair)
			feedback_add_details("admin_verb","DAir")
		if("Jobs")
			debug_variables(job_master)
			feedback_add_details("admin_verb","DJobs")
		if("Sun")
			debug_variables(SSsun)
			feedback_add_details("admin_verb","DSun")
		if("Radio")
			debug_variables(radio_controller)
			feedback_add_details("admin_verb","DRadio")
		if("Configuration")
			debug_variables(config)
			feedback_add_details("admin_verb","DConf")
		if("pAI")
			debug_variables(paiController)
			feedback_add_details("admin_verb","DpAI")
		if("Cameras")
			debug_variables(cameranet)
			feedback_add_details("admin_verb","DCameras")
		if("Event")
			debug_variables(event_manager)
			feedback_add_details("admin_verb","DEvent")
		if("Alarm")
			debug_variables(alarm_manager)
			feedback_add_details("admin_verb", "DAlarm")
		if("Garbage")
			debug_variables(SSgarbage)
			feedback_add_details("admin_verb","DGarbage")
		if("Nano")
			debug_variables(SSnanoui)
			feedback_add_details("admin_verb","DNano")
		if("Vote")
			debug_variables(vote)
			feedback_add_details("admin_verb","DVote")
		if("Fires")
			debug_variables(SSfires)
			feedback_add_details("admin_verb","DFires")
		if("Mob")
			debug_variables(SSmobs)
			feedback_add_details("admin_verb","DMob")
		if("NPC AI")
			debug_variables(SSnpcai)
			feedback_add_details("admin_verb","DNPCAI")
		if("Shuttle")
			debug_variables(SSshuttle)
			feedback_add_details("admin_verb","DShuttle")
		if("Timer")
			debug_variables(SStimer)
			feedback_add_details("admin_verb","DTimer")
		if("Weather")
			debug_variables(SSweather)
			feedback_add_details("admin_verb","DWeather")
		if("Space")
			debug_variables(space_manager)
			feedback_add_details("admin_verb","DSpace")
		if("Mob Hunt Server")
			debug_variables(SSmob_hunt)
			feedback_add_details("admin_verb","DMobHuntServer")

	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
	return
