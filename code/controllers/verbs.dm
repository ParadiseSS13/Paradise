//TODO: rewrite and standardise all controller datums to the datum/controller type
//TODO: allow all controllers to be deleted for clean restarts (see WIP master controller stuff) - MC done - lighting done

USER_VERB(restart_controller, R_DEBUG, "Restart Controller", \
		"Restart one of the various periodic loop controllers for the game (be careful!)", \
		VERB_CATEGORY_DEBUG, \
		controller in list("Master", "Failsafe"))
	switch(controller)
		if("Master")
			Recreate_MC()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Restart MC")
		if("Failsafe")
			new /datum/controller/failsafe()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Restart Failsafe")

	message_admins("Admin [key_name_admin(client)] has restarted the [controller] controller.")

USER_VERB(debug_misc_controller, R_DEBUG, "Debug Misc Controller", \
		"Debug the various non-subsystem controllers for the game (be careful!)", \
		VERB_CATEGORY_DEBUG,
		controller in list("Configuration", "pAI", "Cameras", "Space Manager"))
	switch(controller)
		if("Configuration")
			SSuser_verbs.invoke_verb(client, /datum/user_verb/debug_variables, GLOB.configuration)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug Config")
		if("pAI")
			SSuser_verbs.invoke_verb(client, /datum/user_verb/debug_variables, GLOB.paiController)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug pAI")
		if("Cameras")
			SSuser_verbs.invoke_verb(client, /datum/user_verb/debug_variables, GLOB.cameranet)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug Cameras")
		if("Space Manager")
			SSuser_verbs.invoke_verb(client, /datum/user_verb/debug_variables, GLOB.space_manager)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug Space")

	message_admins("Admin [key_name_admin(client)] is debugging the [controller] controller.")
