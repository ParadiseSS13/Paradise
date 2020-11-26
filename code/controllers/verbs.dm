//TODO: rewrite and standardise all controller datums to the datum/controller type
//TODO: allow all controllers to be deleted for clean restarts (see WIP master controller stuff) - MC done - lighting done


/client/proc/restart_controller(controller in list("Master", "Failsafe"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restart one of the various periodic loop controllers for the game (be careful!)"

	if(!check_rights(R_DEBUG))
		return
	switch(controller)
		if("Master")
			Recreate_MC()
			feedback_add_details("admin_verb","RMaster")
		if("Failsafe")
			new /datum/controller/failsafe()
			feedback_add_details("admin_verb","RFailsafe")

	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")

/client/proc/debug_controller(controller in list("Configuration", "pAI", "Cameras", "Space Manager","Quirks"))
	set category = "Debug"
	set name = "Debug Misc Controller"
	set desc = "Debug the various non-subsystem controllers for the game (be careful!)"

	if(!check_rights(R_DEBUG))
		return
	switch(controller)
		if("Configuration")
			debug_variables(config)
			feedback_add_details("admin_verb","DConf")
		if("pAI")
			debug_variables(GLOB.paiController)
			feedback_add_details("admin_verb","DpAI")
		if("Cameras")
			debug_variables(GLOB.cameranet)
			feedback_add_details("admin_verb","DCameras")
		if("Space Manager")
			debug_variables(GLOB.space_manager)
			feedback_add_details("admin_verb","DSpace")
		if("Quirks")
			debug_variables(SSquirks)
			feedback_add_details("admin_verb","DQuirks")

	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
