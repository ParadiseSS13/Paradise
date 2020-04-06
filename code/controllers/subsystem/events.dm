SUBSYSTEM_DEF(events)
	name = "Events"
	init_order = INIT_ORDER_EVENTS
	runlevels = RUNLEVEL_GAME
	// Report events at the end of the rouund
	var/report_at_round_end = 0

    // UI vars
	var/window_x = 700
	var/window_y = 600
	var/table_options = " align='center'"
	var/head_options = " style='font-weight:bold;'"
	var/row_options1 = " width='85px'"
	var/row_options2 = " width='260px'"
	var/row_options3 = " width='150px'"

    // Event vars
	var/datum/event_container/selected_event_container = null
	var/list/active_events = list()
	var/list/finished_events = list()
	var/list/allEvents
	var/list/event_containers = list(
			EVENT_LEVEL_MUNDANE 	= new/datum/event_container/mundane,
			EVENT_LEVEL_MODERATE	= new/datum/event_container/moderate,
			EVENT_LEVEL_MAJOR 		= new/datum/event_container/major
		)

	var/datum/event_meta/new_event = new

/datum/controller/subsystem/events/Initialize()
	allEvents = subtypesof(/datum/event)
	return ..()

/datum/controller/subsystem/events/fire()
	for(var/datum/event/E in active_events)
		E.process()

	for(var/i = EVENT_LEVEL_MUNDANE to EVENT_LEVEL_MAJOR)
		var/list/datum/event_container/EC = event_containers[i]
		EC.process()

/datum/controller/subsystem/events/proc/event_complete(var/datum/event/E)
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

/datum/controller/subsystem/events/proc/delay_events(var/severity, var/delay)
	var/list/datum/event_container/EC = event_containers[severity]
	EC.next_event_time += delay

/datum/controller/subsystem/events/proc/Interact(var/mob/living/user)

	var/html = GetInteractWindow()

	var/datum/browser/popup = new(user, "event_manager", "Event Manager", window_x, window_y)
	popup.set_content(html)
	popup.open()

/datum/controller/subsystem/events/proc/RoundEnd()
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

/datum/controller/subsystem/events/proc/GetInteractWindow()
	var/html = "<A align='right' href='?src=[UID()];refresh=1'>Refresh</A>"

	if(selected_event_container)
		var/event_time = max(0, selected_event_container.next_event_time - world.time)
		html += "<A align='right' href='?src=[UID()];back=1'>Back</A><br>"
		html += "Time till start: [round(event_time / 600, 0.1)]<br>"
		html += "<div class='block'>"
		html += "<h2>Available [GLOB.severity_to_string[selected_event_container.severity]] Events (queued & running events will not be displayed)</h2>"
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
			html += "<td>[GLOB.severity_to_string[severity]]</td>"
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
			html += "<td>[GLOB.severity_to_string[severity]]</td>"
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
			html += "<td>[GLOB.severity_to_string[EM.severity]]</td>"
			html += "<td>[EM.name]</td>"
			html += "<td>[no_end ? "N/A" : station_time_timestamp("hh:mm:ss", ends_at)]</td>"
			html += "<td>[no_end ? "N/A" : ends_in]</td>"
			html += "<td><A align='right' href='?src=[UID()];stop=\ref[E]'>Stop</A></td>"
			html += "</tr>"
		html += "</table>"
		html += "</div>"

	return html

/datum/controller/subsystem/events/Topic(href, href_list)
	if(..())
		return


	if(href_list["toggle_report"])
		report_at_round_end = !report_at_round_end
		admin_log_and_message_admins("has [report_at_round_end ? "enabled" : "disabled"] the round end event report.")
	else if(href_list["dec_timer"])
		var/datum/event_container/EC = locate(href_list["event"])
		var/decrease = (60 * RaiseToPower(10, text2num(href_list["dec_timer"])))
		EC.next_event_time -= decrease
		admin_log_and_message_admins("decreased timer for [GLOB.severity_to_string[EC.severity]] events by [decrease/600] minute(s).")
	else if(href_list["inc_timer"])
		var/datum/event_container/EC = locate(href_list["event"])
		var/increase = (60 * RaiseToPower(10, text2num(href_list["inc_timer"])))
		EC.next_event_time += increase
		admin_log_and_message_admins("increased timer for [GLOB.severity_to_string[EC.severity]] events by [increase/600] minute(s).")
	else if(href_list["select_event"])
		var/datum/event_container/EC = locate(href_list["select_event"])
		var/datum/event_meta/EM = EC.SelectEvent()
		if(EM)
			admin_log_and_message_admins("has queued the [GLOB.severity_to_string[EC.severity]] event '[EM.name]'.")
	else if(href_list["pause"])
		var/datum/event_container/EC = locate(href_list["pause"])
		EC.delayed = !EC.delayed
		admin_log_and_message_admins("has [EC.delayed ? "paused" : "resumed"] countdown for [GLOB.severity_to_string[EC.severity]] events.")
	else if(href_list["interval"])
		var/delay = input("Enter delay modifier. A value less than one means events fire more often, higher than one less often.", "Set Interval Modifier") as num|null
		if(delay && delay > 0)
			var/datum/event_container/EC = locate(href_list["interval"])
			EC.delay_modifier = delay
			admin_log_and_message_admins("has set the interval modifier for [GLOB.severity_to_string[EC.severity]] events to [EC.delay_modifier].")
	else if(href_list["stop"])
		if(alert("Stopping an event may have unintended side-effects. Continue?","Stopping Event!","Yes","No") != "Yes")
			return
		var/datum/event/E = locate(href_list["stop"])
		var/datum/event_meta/EM = E.event_meta
		admin_log_and_message_admins("has stopped the [GLOB.severity_to_string[EM.severity]] event '[EM.name]'.")
		E.kill()
	else if(href_list["view_events"])
		selected_event_container = locate(href_list["view_events"])
	else if(href_list["back"])
		selected_event_container = null
	else if(href_list["set_name"])
		var/name = clean_input("Enter event name.", "Set Name")
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
				admin_log_and_message_admins("has changed the weight of the [GLOB.severity_to_string[EM.severity]] event '[EM.name]' to [EM.weight].")
	else if(href_list["toggle_oneshot"])
		var/datum/event_meta/EM = locate(href_list["toggle_oneshot"])
		EM.one_shot = !EM.one_shot
		if(EM != new_event)
			admin_log_and_message_admins("has [EM.one_shot ? "set" : "unset"] the oneshot flag for the [GLOB.severity_to_string[EM.severity]] event '[EM.name]'.")
	else if(href_list["toggle_enabled"])
		var/datum/event_meta/EM = locate(href_list["toggle_enabled"])
		EM.enabled = !EM.enabled
		admin_log_and_message_admins("has [EM.enabled ? "enabled" : "disabled"] the [GLOB.severity_to_string[EM.severity]] event '[EM.name]'.")
	else if(href_list["remove"])
		if(alert("This will remove the event from rotation. Continue?","Removing Event!","Yes","No") != "Yes")
			return
		var/datum/event_meta/EM = locate(href_list["remove"])
		var/datum/event_container/EC = locate(href_list["EC"])
		EC.available_events -= EM
		admin_log_and_message_admins("has removed the [GLOB.severity_to_string[EM.severity]] event '[EM.name]'.")
	else if(href_list["add"])
		if(!new_event.name || !new_event.event_type)
			return
		if(alert("This will add a new event to the rotation. Continue?","Add Event!","Yes","No") != "Yes")
			return
		new_event.severity = selected_event_container.severity
		selected_event_container.available_events += new_event
		admin_log_and_message_admins("has added \a [GLOB.severity_to_string[new_event.severity]] event '[new_event.name]' of type [new_event.event_type] with weight [new_event.weight].")
		new_event = new
	else if(href_list["clear"])
		var/datum/event_container/EC = locate(href_list["clear"])
		if(EC.next_event)
			admin_log_and_message_admins("has dequeued the [GLOB.severity_to_string[EC.severity]] event '[EC.next_event.name]'.")
			EC.next_event = null

	Interact(usr)
