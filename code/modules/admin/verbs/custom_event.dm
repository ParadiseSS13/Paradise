USER_VERB(change_custom_event, R_EVENT, "Change Custom Event", "Set a custom event.", VERB_CATEGORY_EVENT)
	var/input = input(client, "Enter the description of the custom event. Be descriptive. To cancel the event, make this blank or hit cancel.", "Custom Event", GLOB.custom_event_msg) as message|null
	if(!input || input == "")
		GLOB.custom_event_msg = null
		log_admin("[key_name(client)] has cleared the custom event text.")
		message_admins("[key_name_admin(client)] has cleared the custom event text.")
		return

	log_admin("[key_name(client)] has changed the custom event text.")
	message_admins("[key_name_admin(client)] has changed the custom event text.")

	GLOB.custom_event_msg = input

	to_chat(world, "<h1 class='alert'>Custom Event</h1>")
	to_chat(world, "<h2 class='alert'>A custom event is starting. OOC Info:</h2>")
	to_chat(world, SPAN_ALERT("[html_encode(GLOB.custom_event_msg)]"))
	to_chat(world, "<br>")

// normal verb for players to view info
/client/verb/cmd_view_custom_event()
	set category = "OOC"
	set name = "Custom Event Info"

	var/list/custom_event_information = list()
	if(!GLOB.custom_event_msg || GLOB.custom_event_msg == "")
		custom_event_information += "There currently is no known custom event taking place."
		custom_event_information += "Keep in mind: it is possible that an admin has not properly set this."
		to_chat(src, chat_box_regular(custom_event_information.Join("<br>")))
		return

	custom_event_information += "<h1 class='alert'>Custom Event</h1>"
	custom_event_information += "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>"
	custom_event_information += SPAN_ALERT("[html_encode(GLOB.custom_event_msg)]")
	to_chat(src, chat_box_regular(custom_event_information.Join("<br>")))
