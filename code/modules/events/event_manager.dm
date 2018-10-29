/datum/event_manager
	var/window_x = 700
	var/window_y = 600
	var/report_at_round_end = 0
	var/table_options = " align='center'"
	var/head_options = " style='font-weight:bold;'"
	var/row_options1 = " width='85px'"
	var/row_options2 = " width='260px'"
	var/row_options3 = " width='150px'"
	var/datum/event_container/selected_event_container = null

	var/list/datum/event/active_events = list()
	var/list/datum/event/finished_events = list()

	var/list/datum/event/allEvents
	var/list/datum/event_container/event_containers = list(
			EVENT_LEVEL_MUNDANE 	= new/datum/event_container/mundane,
			EVENT_LEVEL_MODERATE	= new/datum/event_container/moderate,
			EVENT_LEVEL_MAJOR 		= new/datum/event_container/major
		)

	var/datum/event_meta/new_event = new

/datum/event_manager/New()
	allEvents = subtypesof(/datum/event)

/datum/event_manager/proc/process()
	for(var/datum/event/E in event_manager.active_events)
		E.process()

	for(var/i = EVENT_LEVEL_MUNDANE to EVENT_LEVEL_MAJOR)
		var/list/datum/event_container/EC = event_containers[i]
		EC.process()

/datum/event_manager/proc/event_complete(var/datum/event/E)
	if(!E.event_meta)	// datum/event is used here and there for random reasons, maintaining "backwards compatibility"
		log_debug("Event of '[E.type]' with missing meta-data has completed.")
		return

	finished_events += E

	var/theseverity

	if(!E.severity)
		theseverity = EVENT_LEVEL_MODERATE

	if(!E.severity == EVENT_LEVEL_MUNDANE && !E.severity == EVENT_LEVEL_MODERATE && !E.severity == EVENT_LEVEL_MAJOR)
		theseverity = EVENT_LEVEL_MODERATE //just to be careful

	if(E.severity)
		theseverity = E.severity

	// Add the event back to the list of available events
	var/datum/event_container/EC = event_containers[theseverity]
	var/datum/event_meta/EM = E.event_meta
	EC.available_events += EM

	log_debug("Event '[EM.name]' has completed at [station_time_timestamp()].")

/datum/event_manager/proc/delay_events(var/severity, var/delay)
	var/list/datum/event_container/EC = event_containers[severity]
	EC.next_event_time += delay

/datum/event_manager/proc/Interact(var/mob/living/user)

	var/html = GetInteractWindow()

	var/datum/browser/popup = new(user, "event_manager", "Event Manager", window_x, window_y)
	popup.set_content(html)
	popup.open()

/datum/event_manager/proc/RoundEnd()
	if(!report_at_round_end)
		return

	to_chat(world, "<br><br><br><font size=3><b>Random Events This Round:</b></font>")
	for(var/datum/event/E in active_events|finished_events)
		var/datum/event_meta/EM = E.event_meta
		if(EM.name == "Nothing")
			continue
		var/message = "'[EM.name]' began at [station_time_timestamp("hh:mm:ss", E.startedAt)] "
		if(E.isRunning)
			message += "and is still running."
		else
			if(E.endedAt - E.startedAt > MinutesToTicks(5)) // Only mention end time if the entire duration was more than 5 minutes
				message += "and ended at [station_time_timestamp("hh:mm:ss", E.endedAt)]."
			else
				message += "and ran to completion."

		to_chat(world, message)

/datum/event_manager/proc/GetInteractWindow()
	var/html = "<A align='right' href='?src=[UID()];refresh=1'>Refresh</A>"

	if(selected_event_container)
		var/event_time = max(0, selected_event_container.next_event_time - world.time)
		html += "<A align='right' href='?src=[UID()];back=1'>Back</A><br>"
		html += "Time till start: [round(event_time / 600, 0.1)]<br>"
		html += "<div class='block'>"
		html += "<h2>Available [severity_to_string[selected_event_container.severity]] Events (queued & running events will not be displayed)</h2>"
		html += "<table[table_options]>"
		html += "<tr[head_options]><td[row_options2]>Name </td><td>Weight </td><td>MinWeight </td><td>MaxWeight </td><td>OneShot </td><td>Enabled </td><td><span class='alert'>CurrWeight </span></td><td>Remove</td></tr>"
		for(var/datum/event_meta/EM in selected_event_container.available_events)
			html += "<tr>"
			html += "<td>[EM.name]</td>"
			html += "<td><A align='right' href='?src=[UID()];set_weight=\ref[EM]'>[EM.weight]</A></td>"
			html += "<td>[EM.min_weight]</td>"
			html += "<td>[EM.max_weight]</td>"
			html += "<td><A align='right' href='?src=[UID()];toggle_oneshot=\ref[EM]'>[EM.one_shot]</A></td>"
			html += "<td><A align='right' href='?src=[UID()];toggle_enabled=\ref[EM]'>[EM.enabled]</A></td>"
			html += "<td><span class='alert'>[EM.get_weight(number_active_with_role())]</span></td>"
			html += "<td><A align='right' href='?src=[UID()];remove=\ref[EM];EC=\ref[selected_event_container]'>Remove</A></td>"
			html += "</tr>"
		html += "</table>"
		html += "</div>"

		html += "<div class='block'>"
		html += "<h2>Add Event</h2>"
		html += "<table[table_options]>"
		html += "<tr [head_options]><td[row_options2]>Name</td><td[row_options2]>Type</td><td[row_options1]>Weight</td><td[row_options1]>OneShot</td></tr>"
		html += "<tr>"
		html += "<td><A align='right' href='?src=[UID()];set_name=\ref[new_event]'>[new_event.name ? new_event.name : "Enter Event"]</A></td>"
		html += "<td><A align='right' href='?src=[UID()];set_type=\ref[new_event]'>[new_event.event_type ? new_event.event_type : "Select Type"]</A></td>"
		html += "<td><A align='right' href='?src=[UID()];set_weight=\ref[new_event]'>[new_event.weight ? new_event.weight : 0]</A></td>"
		html += "<td><A align='right' href='?src=[UID()];toggle_oneshot=\ref[new_event]'>[new_event.one_shot]</A></td>"
		html += "</tr>"
		html += "</table>"
		html += "<A align='right' href='?src=[UID()];add=\ref[selected_event_container]'>Add</A><br>"
		html += "</div>"
	else
		html += "<A align='right' href='?src=[UID()];toggle_report=1'>Round End Report: [report_at_round_end ? "On": "Off"]</A><br>"
		html += "<div class='block'>"
		html += "<h2>Event Start</h2>"

		html += "<table[table_options]>"
		html += "<tr[head_options]><td[row_options1]>Severity</td><td[row_options1]>Starts At</td><td[row_options1]>Starts In</td><td[row_options3]>Adjust Start</td><td[row_options1]>Pause</td><td[row_options1]>Interval Mod</td></tr>"
		for(var/severity = EVENT_LEVEL_MUNDANE to EVENT_LEVEL_MAJOR)
			var/datum/event_container/EC = event_containers[severity]
			var/next_event_at = max(0, EC.next_event_time - world.time)
			html += "<tr>"
			html += "<td>[severity_to_string[severity]]</td>"
			html += "<td>[station_time_timestamp("hh:mm:ss", max(EC.next_event_time, world.time))]</td>"
			html += "<td>[round(next_event_at / 600, 0.1)]</td>"
			html += "<td>"
			html +=   "<A align='right' href='?src=[UID()];dec_timer=2;event=\ref[EC]'>--</A>"
			html +=   "<A align='right' href='?src=[UID()];dec_timer=1;event=\ref[EC]'>-</A>"
			html +=   "<A align='right' href='?src=[UID()];inc_timer=1;event=\ref[EC]'>+</A>"
			html +=   "<A align='right' href='?src=[UID()];inc_timer=2;event=\ref[EC]'>++</A>"
			html += "</td>"
			html += "<td>"
			html +=   "<A align='right' href='?src=[UID()];pause=\ref[EC]'>[EC.delayed ? "Resume" : "Pause"]</A>"
			html += "</td>"
			html += "<td>"
			html +=   "<A align='right' href='?src=[UID()];interval=\ref[EC]'>[EC.delay_modifier]</A>"
			html += "</td>"
			html += "</tr>"
		html += "</table>"
		html += "</div>"

		html += "<div class='block'>"
		html += "<h2>Next Event</h2>"
		html += "<table[table_options]>"
		html += "<tr[head_options]><td[row_options1]>Severity</td><td[row_options2]>Name</td><td[row_options3]>Event Rotation</td><td>Clear</td></tr>"
		for(var/severity = EVENT_LEVEL_MUNDANE to EVENT_LEVEL_MAJOR)
			var/datum/event_container/EC = event_containers[severity]
			var/datum/event_meta/EM = EC.next_event
			html += "<tr>"
			html += "<td>[severity_to_string[severity]]</td>"
			html += "<td><A align='right' href='?src=[UID()];select_event=\ref[EC]'>[EM ? EM.name : "Random"]</A></td>"
			html += "<td><A align='right' href='?src=[UID()];view_events=\ref[EC]'>View</A></td>"
			html += "<td><A align='right' href='?src=[UID()];clear=\ref[EC]'>Clear</A></td>"
			html += "</tr>"
		html += "</table>"
		html += "</div>"

		html += "<div class='block'>"
		html += "<h2>Running Events</h2>"
		html += "Estimated times, affected by master controller delays."
		html += "<table[table_options]>"
		html += "<tr[head_options]><td[row_options1]>Severity</td><td[row_options2]>Name</td><td[row_options1]>Ends At</td><td[row_options1]>Ends In</td><td[row_options3]>Stop</td></tr>"
		for(var/datum/event/E in active_events)
			if(!E.event_meta)
				continue
			var/datum/event_meta/EM = E.event_meta
			var/ends_at = E.startedAt + (E.lastProcessAt() * 20)	// A best estimate, based on how often the manager processes
			var/ends_in = max(0, round((ends_at - world.time) / 600, 0.1))
			var/no_end = E.noAutoEnd
			html += "<tr>"
			html += "<td>[severity_to_string[EM.severity]]</td>"
			html += "<td>[EM.name]</td>"
			html += "<td>[no_end ? "N/A" : station_time_timestamp("hh:mm:ss", ends_at)]</td>"
			html += "<td>[no_end ? "N/A" : ends_in]</td>"
			html += "<td><A align='right' href='?src=[UID()];stop=\ref[E]'>Stop</A></td>"
			html += "</tr>"
		html += "</table>"
		html += "</div>"

	return html

/datum/event_manager/Topic(href, href_list)
	if(..())
		return


	if(href_list["toggle_report"])
		report_at_round_end = !report_at_round_end
		admin_log_and_message_admins("has [report_at_round_end ? "enabled" : "disabled"] the round end event report.")
	else if(href_list["dec_timer"])
		var/datum/event_container/EC = locate(href_list["event"])
		var/decrease = (60 * RaiseToPower(10, text2num(href_list["dec_timer"])))
		EC.next_event_time -= decrease
		admin_log_and_message_admins("decreased timer for [severity_to_string[EC.severity]] events by [decrease/600] minute(s).")
	else if(href_list["inc_timer"])
		var/datum/event_container/EC = locate(href_list["event"])
		var/increase = (60 * RaiseToPower(10, text2num(href_list["inc_timer"])))
		EC.next_event_time += increase
		admin_log_and_message_admins("increased timer for [severity_to_string[EC.severity]] events by [increase/600] minute(s).")
	else if(href_list["select_event"])
		var/datum/event_container/EC = locate(href_list["select_event"])
		var/datum/event_meta/EM = EC.SelectEvent()
		if(EM)
			admin_log_and_message_admins("has queued the [severity_to_string[EC.severity]] event '[EM.name]'.")
	else if(href_list["pause"])
		var/datum/event_container/EC = locate(href_list["pause"])
		EC.delayed = !EC.delayed
		admin_log_and_message_admins("has [EC.delayed ? "paused" : "resumed"] countdown for [severity_to_string[EC.severity]] events.")
	else if(href_list["interval"])
		var/delay = input("Enter delay modifier. A value less than one means events fire more often, higher than one less often.", "Set Interval Modifier") as num|null
		if(delay && delay > 0)
			var/datum/event_container/EC = locate(href_list["interval"])
			EC.delay_modifier = delay
			admin_log_and_message_admins("has set the interval modifier for [severity_to_string[EC.severity]] events to [EC.delay_modifier].")
	else if(href_list["stop"])
		if(alert("Stopping an event may have unintended side-effects. Continue?","Stopping Event!","Yes","No") != "Yes")
			return
		var/datum/event/E = locate(href_list["stop"])
		var/datum/event_meta/EM = E.event_meta
		admin_log_and_message_admins("has stopped the [severity_to_string[EM.severity]] event '[EM.name]'.")
		E.kill()
	else if(href_list["view_events"])
		selected_event_container = locate(href_list["view_events"])
	else if(href_list["back"])
		selected_event_container = null
	else if(href_list["set_name"])
		var/name = input("Enter event name.", "Set Name") as text|null
		if(name)
			var/datum/event_meta/EM = locate(href_list["set_name"])
			EM.name = name
	else if(href_list["set_type"])
		var/type = input("Select event type.", "Select") as null|anything in allEvents
		if(type)
			var/datum/event_meta/EM = locate(href_list["set_type"])
			EM.event_type = type
	else if(href_list["set_weight"])
		var/weight = input("Enter weight. A higher value means higher chance for the event of being selected.", "Set Weight") as num|null
		if(weight && weight > 0)
			var/datum/event_meta/EM = locate(href_list["set_weight"])
			EM.weight = weight
			if(EM != new_event)
				admin_log_and_message_admins("has changed the weight of the [severity_to_string[EM.severity]] event '[EM.name]' to [EM.weight].")
	else if(href_list["toggle_oneshot"])
		var/datum/event_meta/EM = locate(href_list["toggle_oneshot"])
		EM.one_shot = !EM.one_shot
		if(EM != new_event)
			admin_log_and_message_admins("has [EM.one_shot ? "set" : "unset"] the oneshot flag for the [severity_to_string[EM.severity]] event '[EM.name]'.")
	else if(href_list["toggle_enabled"])
		var/datum/event_meta/EM = locate(href_list["toggle_enabled"])
		EM.enabled = !EM.enabled
		admin_log_and_message_admins("has [EM.enabled ? "enabled" : "disabled"] the [severity_to_string[EM.severity]] event '[EM.name]'.")
	else if(href_list["remove"])
		if(alert("This will remove the event from rotation. Continue?","Removing Event!","Yes","No") != "Yes")
			return
		var/datum/event_meta/EM = locate(href_list["remove"])
		var/datum/event_container/EC = locate(href_list["EC"])
		EC.available_events -= EM
		admin_log_and_message_admins("has removed the [severity_to_string[EM.severity]] event '[EM.name]'.")
	else if(href_list["add"])
		if(!new_event.name || !new_event.event_type)
			return
		if(alert("This will add a new event to the rotation. Continue?","Add Event!","Yes","No") != "Yes")
			return
		new_event.severity = selected_event_container.severity
		selected_event_container.available_events += new_event
		admin_log_and_message_admins("has added \a [severity_to_string[new_event.severity]] event '[new_event.name]' of type [new_event.event_type] with weight [new_event.weight].")
		new_event = new
	else if(href_list["clear"])
		var/datum/event_container/EC = locate(href_list["clear"])
		if(EC.next_event)
			admin_log_and_message_admins("has dequeued the [severity_to_string[EC.severity]] event '[EC.next_event.name]'.")
			EC.next_event = null

	Interact(usr)

/client/proc/forceEvent(var/type in event_manager.allEvents)
	set name = "Trigger Event (Debug Only)"
	set category = "Debug"

	if(!holder)
		return

	if(ispath(type))
		new type(new /datum/event_meta(EVENT_LEVEL_MAJOR))
		message_admins("[key_name_admin(usr)] has triggered an event. ([type])", 1)

/client/proc/event_manager_panel()
	set name = "Event Manager Panel"
	set category = "Event"
	if(event_manager)
		event_manager.Interact(usr)
	feedback_add_details("admin_verb","EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/proc/findEventArea() //Here's a nice proc to use to find an area for your event to land in!
	var/area/candidate = null

	var/list/safe_areas = list(
	/area/turret_protected/ai,
	/area/turret_protected/ai_upload,
	/area/engine,
	/area/solar,
	/area/holodeck,
	/area/shuttle/arrival,
	/area/shuttle/escape,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod5/station,
	/area/shuttle/specops/station,
	/area/shuttle/prison/station,
	/area/shuttle/administration/station
	)

	//These are needed because /area/engine has to be removed from the list, but we still want these areas to get fucked up.
	var/list/danger_areas = list(
	/area/engine/break_room,
	/area/engine/chiefs_office)

	var/list/event_areas = list()

	for(var/areapath in the_station_areas)
		event_areas += typesof(areapath)
	for(var/areapath in safe_areas)
		event_areas -= typesof(areapath)
	for(var/areapath in danger_areas)
		event_areas += typesof(areapath)

	while(event_areas.len > 0)
		var/list/event_turfs = null
		candidate = locate(pick_n_take(event_areas))
		event_turfs = get_area_turfs(candidate)
		if(event_turfs.len > 0)
			break

	return candidate

/datum/event/proc/num_players()
	var/players = 0
	for(var/mob/living/carbon/human/P in GLOB.player_list)
		if(P.client)
			players++
	return players

// Returns how many characters are currently active(not logged out, not AFK for more than 10 minutes)
// with a specific role.
// Note that this isn't sorted by department, because e.g. having a roboticist shouldn't make meteors spawn.
/proc/number_active_with_role()
	var/list/active_with_role = list()
	active_with_role["Engineer"] = 0
	active_with_role["Medical"] = 0
	active_with_role["Security"] = 0
	active_with_role["Scientist"] = 0
	active_with_role["AI"] = 0
	active_with_role["Cyborg"] = 0
	active_with_role["Janitor"] = 0
	active_with_role["Botanist"] = 0
	active_with_role["Any"] = GLOB.player_list.len

	for(var/mob/M in GLOB.player_list)
		if(!M.mind || !M.client || M.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue

		if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "engineering robot module")
			active_with_role["Engineer"]++
		if(M.mind.assigned_role in list("Chief Engineer", "Station Engineer"))
			active_with_role["Engineer"]++

		if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "medical robot module")
			active_with_role["Medical"]++
		if(M.mind.assigned_role in list("Chief Medical Officer", "Medical Doctor"))
			active_with_role["Medical"]++

		if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "security robot module")
			active_with_role["Security"]++
		if(M.mind.assigned_role in security_positions)
			active_with_role["Security"]++

		if(M.mind.assigned_role in list("Research Director", "Scientist"))
			active_with_role["Scientist"]++

		if(M.mind.assigned_role == "AI")
			active_with_role["AI"]++

		if(M.mind.assigned_role == "Cyborg")
			active_with_role["Cyborg"]++

		if(M.mind.assigned_role == "Janitor")
			active_with_role["Janitor"]++

		if(M.mind.assigned_role == "Botanist")
			active_with_role["Botanist"]++

	return active_with_role
