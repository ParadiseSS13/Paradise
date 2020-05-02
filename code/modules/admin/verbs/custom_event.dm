// verb for admins to set custom event
/client/proc/cmd_admin_change_custom_event()
	set category = "Event"
	set name = "Change Custom Event"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/input = input(usr, "Enter the description of the custom event. Be descriptive. To cancel the event, make this blank or hit cancel.", "Custom Event", GLOB.custom_event_msg) as message|null
	if(!input || input == "")
		GLOB.custom_event_msg = null
		log_admin("[key_name(usr)] has cleared the custom event text.")
		message_admins("[key_name_admin(usr)] has cleared the custom event text.")
		return

	log_admin("[key_name(usr)] has changed the custom event text.")
	message_admins("[key_name_admin(usr)] has changed the custom event text.")

	GLOB.custom_event_msg = input

	to_chat(world, "<h1 class='alert'>Custom Event</h1>")
	to_chat(world, "<h2 class='alert'>A custom event is starting. OOC Info:</h2>")
	to_chat(world, "<span class='alert'>[html_encode(GLOB.custom_event_msg)]</span>")
	to_chat(world, "<br>")

// normal verb for players to view info
/client/verb/cmd_view_custom_event()
	set category = "OOC"
	set name = "Custom Event Info"

	if(!GLOB.custom_event_msg || GLOB.custom_event_msg == "")
		to_chat(src, "There currently is no known custom event taking place.")
		to_chat(src, "Keep in mind: it is possible that an admin has not properly set this.")
		return

	to_chat(src, "<h1 class='alert'>Custom Event</h1>")
	to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
	to_chat(src, "<span class='alert'>[html_encode(GLOB.custom_event_msg)]</span>")
	to_chat(src, "<br>")
