/datum/station_goal/secondary
	name = "Generic Secondary Goal"
	required_creq = 1
	// Should match the values used for requests consoles.
	var/department = "Unknown"

/datum/station_goal/secondary/send_report()
	send_requests_console_message(report_message, "Central Command", department, "centcom", TRUE, RQ_HIGHPRIORITY)
