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


/client/proc/debug_controller(controller in list("Master","failsafe","Ticker","Air","Lighting","Jobs","Sun","Radio","Configuration","pAI", "Cameras","Garbage", "Transfer Controller","Event","Alarm","Scheduler","Nano","Vote"))
	set category = "Debug"
	set name = "Debug Controller"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return
	switch(controller)
		if("Master")
			debug_variables(master_controller)
			feedback_add_details("admin_verb","DMC")
		if("failsafe")
			debug_variables(failsafe)
			feedback_add_details("admin_verb", "dfailsafe")
		if("Ticker")
			debug_variables(ticker)
			feedback_add_details("admin_verb","DTicker")
		if("Air")
			debug_variables(air_master)
			feedback_add_details("admin_verb","DAir")
		if("Lighting")
			debug_variables(lighting_controller)
			feedback_add_details("admin_verb","DLighting")
		if("Jobs")
			debug_variables(job_master)
			feedback_add_details("admin_verb","DJobs")
		if("Sun")
			debug_variables(sun)
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
			debug_variables(garbageCollector)
			feedback_add_details("admin_verb","DGarbage")
		if("Scheduler")
			debug_variables(processScheduler)
			feedback_add_details("admin_verb","DprocessScheduler")
		if("Nano")
			debug_variables(nanomanager)
			feedback_add_details("admin_verb","DNano")
		if("Vote")
			debug_variables(vote)
			feedback_add_details("admin_verb","DVote")

	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
	return
