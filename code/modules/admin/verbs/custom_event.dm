// verb for admins to set custom event
/client/proc/cmd_admin_change_custom_event()
	set category = "Event"
	set name = "Change Custom Event"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/input = input(usr, "Enter the description of the custom event. Be descriptive. To cancel the event, make this blank or hit cancel.", "Custom Event", custom_event_msg) as message|null
	if(!input || input == "")
		custom_event_msg = null
		log_admin("[key_name(usr)] has cleared the custom event text.")
		message_admins("[key_name_admin(usr)] has cleared the custom event text.")
		return

	log_admin("[key_name(usr)] has changed the custom event text.")
	message_admins("[key_name_admin(usr)] has changed the custom event text.")

	custom_event_msg = input

	to_chat(world, "<h1 class='alert'>Custom Event</h1>")
	to_chat(world, "<h2 class='alert'>A custom event is starting. OOC Info:</h2>")
	to_chat(world, "<span class='alert'>[html_encode(custom_event_msg)]</span>")
	to_chat(world, "<br>")

// normal verb for players to view info
/client/verb/cmd_view_custom_event()
	set category = "OOC"
	set name = "Custom Event Info"

	if(!custom_event_msg || custom_event_msg == "")
		to_chat(src, "There currently is no known custom event taking place.")
		to_chat(src, "Keep in mind: it is possible that an admin has not properly set this.")
		return

	to_chat(src, "<h1 class='alert'>Custom Event</h1>")
	to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
	to_chat(src, "<span class='alert'>[html_encode(custom_event_msg)]</span>")
	to_chat(src, "<br>")

//admin event info to be view by admins

/client/proc/cmd_admin_custom_event_info()
	set category = "Event"
	set name = "Change Custom Admin Event Info"

	if(!check_rights(R_EVENT))
		to_chat(src, "Only administrators may use this command.")
		return

	var/input = input(usr, "Enter the description of the custom event. This is informations for admins only. Use it to notify other admins of event info but not players.", "Custom Event Info", custom_event_msg) as message|null
	if(!input || input == "")
		custom_event_admin_msg = null
		log_admin("[key_name(usr)] has cleared the custom admin event info text.")
		message_admins("[key_name_admin(usr)] has cleared the custom admin event text.")
		return

	log_admin("[key_name(usr)] has changed the custom admin event info text.")
	message_admins("[key_name_admin(usr)] has changed the custom admin event info text.")

	custom_event_admin_msg = input

	for(var/client/X in GLOB.admins)
		if(check_rights(R_EVENT,0,X.mob))
			to_chat(X, "<h1 class='alert'>Custom Admin Event Info</h1>")
			to_chat(X, "<h2 class='alert'>A custom event is starting. OOC Admin Info:</h2>")
			to_chat(X, "<span class='alert'>[html_encode(custom_event_admin_msg)]</span>")
			to_chat(X,"<br>")

/client/proc/cmd_view_custom_event_info()
	set category = "Event"
	set name = "Custom Event Admin Info"

	if(!check_rights(R_EVENT))
		to_chat(src, "Only administrators may use this command.")
		return

	if(!custom_event_admin_msg || custom_event_admin_msg == "")
		to_chat(src, "There currently is no known custom admin event taking place.")
		return

	to_chat(src, "<h1 class='alert'>Custom Event Info</h1>")
	to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
	to_chat(src, "<span class='alert'>[html_encode(custom_event_admin_msg)]</span>")
	to_chat(src, "<br>")
