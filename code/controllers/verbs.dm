//TODO: rewrite and standardise all controller datums to the datum/controller type
//TODO: allow all controllers to be deleted for clean restarts (see WIP master controller stuff) - MC done - lighting done

ADMIN_VERB(restart_controller, R_DEBUG, "Restart Controller", \
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

	message_admins("Admin [key_name_admin(user)] has restarted the [controller] controller.")

ADMIN_VERB(debug_misc_controller, R_DEBUG, "Debug Misc Controller", \
		"Debug the various non-subsystem controllers for the game (be careful!)", \
		VERB_CATEGORY_DEBUG,
		controller in list("Configuration", "pAI", "Cameras", "Space Manager"))
	switch(controller)
		if("Configuration")
			SSadmin_verbs.invoke_verb(user, /datum/admin_verb/debug_variables, GLOB.configuration)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug Config")
		if("pAI")
			SSadmin_verbs.invoke_verb(user, /datum/admin_verb/debug_variables, GLOB.paiController)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug pAI")
		if("Cameras")
			SSadmin_verbs.invoke_verb(user, /datum/admin_verb/debug_variables, GLOB.cameranet)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug Cameras")
		if("Space Manager")
			SSadmin_verbs.invoke_verb(user, /datum/admin_verb/debug_variables, GLOB.space_manager)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug Space")

	message_admins("Admin [key_name_admin(user)] is debugging the [controller] controller.")
