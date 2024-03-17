/datum/station_goal/secondary
	name = "Generic Secondary Goal"
	required_crew = 1
	// Should match the values used for requests consoles.
	var/department = "Unknown"
	var/personal_account
	var/progress_type = /datum/secondary_goal_progress
	var/datum/secondary_goal_progress/progress
	var/datum/secondary_goal_tracker/tracker
	// Abstract goals can't be used directly.
	var/abstract = TRUE

/datum/station_goal/secondary/proc/Initialize(var/requester_account)
	personal_account = requester_account
	randomize_params()
	progress = new progress_type
	progress.configure(src)
	tracker = new(src, progress)
	tracker.register(SSshuttle.supply)

// Override this to randomly configure the goal before generating a progress
// tracker.
/datum/station_goal/secondary/proc/randomize_params()

/datum/station_goal/secondary/send_report(requester)
	var/list/message_parts = list()
	message_parts += "Received secondary goal request from [requester] for [department].\nQuerying master task list....\nSuitable task found. Task details:\n\n"
	message_parts += report_message
	var/combined_message = message_parts.Join("")
	send_requests_console_message(combined_message, "Central Command", department, "Stamped with the Central Command rubber stamp.", "Verified by A.L.I.C.E (CentCom AI)", RQ_HIGHPRIORITY)
	send_requests_console_message(combined_message, "Central Command", "Captain's Desk", "Stamped with the Central Command rubber stamp.", "Verified by A.L.I.C.E (CentCom AI)", RQ_NORMALPRIORITY)
	send_requests_console_message(combined_message, "Central Command", "Bridge", "Stamped with the Central Command rubber stamp.", "Verified by A.L.I.C.E (CentCom AI)", RQ_NORMALPRIORITY)

/proc/generate_secondary_goal(department, requester = null, mob/user = null)
	var/list/possible = list()
	for(var/T in subtypesof(/datum/station_goal/secondary))
		var/datum/station_goal/secondary/G = T
		if(initial(G.department) != department || initial(G.abstract))
			continue
		possible += G

	if(!length(possible))
		if(user)
			to_chat(user, "<span class='info'>No goals available for [department].</span>")
		return

	var/datum/station_goal/secondary/picked = pick(possible)
	var/datum/station_goal/secondary/built = new picked

	var/requester_account = null
	var/obj/item/card/id/ID = requester
	if(ID)
		requester_account = GLOB.station_money_database.find_user_account(ID.associated_account_number)
	built.Initialize(requester_account)
	if(!ID)
		built.send_report("CentCom")
	else
		built.send_report(ID.assignment ? "[ID.assignment] [ID.registered_name]" : ID.registered_name)
	SSticker.mode.secondary_goals += built
