/datum/station_goal/secondary
	name = "Generic Secondary Goal"
	required_crew = 1
	// Should match the values used for requests consoles.
	var/department = "Unknown"
	var/complete = FALSE
	var/progress_type = /datum/secondary_goal_progress
	var/datum/secondary_goal_progress/progress
	var/datum/secondary_goal_tracker/tracker

/datum/station_goal/secondary/robotics_test
	name = "Test Goal"
	department = "Robotics"
	report_message = "Die."

/datum/station_goal/secondary/proc/Initialize()
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

/proc/generate_secondary_goal(department, requester = "CentCom", mob/user = null)
	var/list/possible = list()
	for(var/T in subtypesof(/datum/station_goal/secondary))
		var/datum/station_goal/secondary/G = T
		if(initial(G.department) != department)
			continue
		possible += G

	if(!length(possible))
		if(user)
			to_chat(user, "<span class='info'>No goals available for [department].</span>")
		return

	var/datum/station_goal/secondary/picked = pick(possible)
	var/datum/station_goal/secondary/built = new picked
	built.Initialize()
	built.send_report(requester)
	if(SSticker)
		SSticker.mode.secondary_goals += built
