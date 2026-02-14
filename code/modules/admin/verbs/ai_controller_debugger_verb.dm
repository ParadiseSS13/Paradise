USER_CONTEXT_MENU(open_ai_controller_debugger, R_DEV_TEAM, "\[Dev\] AI Controller Debugger", atom/A as mob|obj in view())
	if(!istype(A.ai_controller))
		to_chat(client, SPAN_WARNING("[A] does not have a valid AI controller."))
		return

	var/datum/ui_module/ai_controller_debugger/AICD = new(A.ai_controller)
	AICD.ui_interact(client.mob)
