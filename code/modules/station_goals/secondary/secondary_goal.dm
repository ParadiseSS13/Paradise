/datum/station_goal/secondary
	name = "Generic Secondary Goal"
	required_crew = 1
	/// Admin-only shor description of the goal.
	var/admin_desc = "No description"
	/// Assigned department. Should match the values used for requests consoles.
	var/department = "Unknown"
	/// The person who requested the goal.
	var/requester_name
	/// The money account of the person who requested the goal.
	var/personal_account
	/// Should we (still) send a personal crate on the next shipment?
	var/should_send_crate = TRUE
	/// Type path of the progress tracker used.
	var/progress_type = /datum/secondary_goal_progress
	/// Progress type of this goal.
	var/datum/secondary_goal_progress/progress
	/// Tracker that manages the goal progress, permanent and temporary.
	var/datum/secondary_goal_tracker/tracker
	/// The goal weight of a secondary goal type defines how many copies of it are in the grab bag that new secondary goals are pulled from. When the bag is empty, it gets refilled with the same number of each secondary goal type. Max 10.
	weight = 0

/datum/station_goal/secondary/proc/Initialize(requester_name_in, requester_account)
	SHOULD_CALL_PARENT(TRUE)
	requester_name = requester_name_in
	personal_account = requester_account
	randomize_params()
	progress = new progress_type
	progress.configure(src)
	tracker = new(src, progress)
	tracker.register(SSshuttle.supply)

// Override this to randomly configure the goal before generating a progress
// tracker.
/datum/station_goal/secondary/proc/randomize_params()
	return

/datum/station_goal/secondary/send_report(requester, intro_override = FALSE)
	var/list/message_parts = list()
	if(intro_override)
		message_parts += intro_override
	else
		message_parts += "Received secondary goal request from [requester] for [department]."
		message_parts += "Querying master task list...."
		message_parts += "Suitable task found. Task details:"
	message_parts += ""
	message_parts += report_message
	message_parts += ""
	message_parts += "All requested materials must be properly labeled for transport, or be inside a properly-labeled container. You can configure a hand labeler to create suitable labels by by swiping your ID card on it."
	if(should_send_crate)
		message_parts += "For your convenience, a pre-labeled personal crate will be sent to your cargo department."
		send_requests_console_message("A new secondary goal crate for [requester] from [department] is ready to ship with your next order.", "Procurement Office", "Cargo Bay", "Stamped with the Central Command rubber stamp.", "Verified by A.L.I.C.E (CentCom AI)", RQ_HIGHPRIORITY)
	send_requests_console_message(message_parts, "Procurement Office", department, "Stamped with the Central Command rubber stamp.", "Verified by A.L.I.C.E (CentCom AI)", RQ_HIGHPRIORITY)
	if(department !=  "Captain's Desk")
		send_requests_console_message(message_parts, "Procurement Office", "Captain's Desk", "Stamped with the Central Command rubber stamp.", "Verified by A.L.I.C.E (CentCom AI)", RQ_NORMALPRIORITY)
	if(department !=  "Bridge")
		send_requests_console_message(message_parts, "Procurement Office", "Bridge", "Stamped with the Central Command rubber stamp.", "Verified by A.L.I.C.E (CentCom AI)", RQ_NORMALPRIORITY)

/proc/init_secondary_goal_grab_bags()
	SSticker.mode.secondary_goal_grab_bags = list()
	for(var/T in subtypesof(/datum/station_goal/secondary))
		var/datum/station_goal/secondary/G = T
		if(initial(G.weight) < 1)
			continue
		var/department = initial(G.department)
		if(isnull(SSticker.mode.secondary_goal_grab_bags[department]))
			SSticker.mode.secondary_goal_grab_bags[department] = list()
		for(var/i in 1 to min(10, initial(G.weight)))
			SSticker.mode.secondary_goal_grab_bags[department] += G

/proc/generate_secondary_goal(department, requester = null, mob/user = null)
	if(isnull(SSticker.mode.secondary_goal_grab_bags))
		init_secondary_goal_grab_bags()

	var/list/possible = SSticker.mode.secondary_goal_grab_bags[department]

	if(isnull(possible))
		if(user)
			to_chat(user, "<span class='notice'>No goals available for [department]. Goals are currently available for [english_list(SSticker.mode.secondary_goal_grab_bags)].</span>")
		return

	if(length(possible) == 0)
		for(var/T in subtypesof(/datum/station_goal/secondary))
			var/datum/station_goal/secondary/G = T
			if(initial(G.weight) < 1 || initial(G.department) != department)
				continue
			for(var/i in 1 to min(10, initial(G.weight)))
				possible += G

	var/datum/station_goal/secondary/picked = pick_n_take(possible)
	var/datum/station_goal/secondary/built = new picked

	var/requester_name = null
	var/requester_account = null
	var/obj/item/card/id/ID = requester
	if(ID)
		requester_name = ID.registered_name
		requester_account = GLOB.station_money_database.find_user_account(ID.associated_account_number)
	built.Initialize(requester_name, requester_account)
	if(!ID)
		built.send_report("CentCom")
	else
		built.send_report(ID.assignment ? "[ID.assignment] [ID.registered_name]" : ID.registered_name)
	SSticker.mode.secondary_goals += built
	SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(built.name, "times generated"))

/datum/station_goal/secondary/Topic(href, href_list)
	if(!check_rights(R_EVENT))
		return

	if(href_list["announce"])
		send_report("CentCom", "A task for [department] has been issued by Central Command:")
		message_admins("[key_name_admin(usr)] sent an announcement for secondary goal [src] ([admin_desc])")
		log_admin("[key_name_admin(usr)] sent an announcement for secondary goal [src] ([admin_desc])")
	else if(href_list["remove"])
		SSticker.mode.secondary_goals -= src
		message_admins("[key_name_admin(usr)] removed secondary goal [src] ([admin_desc])")
		log_admin("[key_name_admin(usr)] removed secondary goal [src] ([admin_desc])")
		tracker.unregister(SSshuttle.supply)
		qdel(src)
		usr.client.modify_goals()
	else if(href_list["mark_complete"])
		completed = 1
		tracker.unregister(SSshuttle.supply)
		usr.client.modify_goals()
		message_admins("[key_name_admin(usr)] marked secondary goal [src] ([admin_desc]) as complete")
		log_admin("[key_name_admin(usr)] marked secondary goal [src] ([admin_desc]) as complete")
	else if(href_list["reset_progress"])
		completed = 0
		tracker.reset()
		usr.client.modify_goals()
		message_admins("[key_name_admin(usr)] reset progress of secondary goal [src] ([admin_desc])")
		log_admin("[key_name_admin(usr)] reset progress of secondary goal [src] ([admin_desc])")
