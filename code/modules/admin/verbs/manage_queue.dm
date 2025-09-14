/client/proc/manage_queue()
	set name = "Manage Queue Server"
	set desc = "Manage the queue server and its settings"
	set category = "Server"

	if(!check_rights(R_SERVER))
		return

	var/list/choices = list("Show Status", "Toggle Queue Server", "Set Threshold", "Toggle Setting Persistence")
	var/choice = input(usr, "Please, select an option", "Queue Server Manipulation") as null|anything in choices

	switch(choice)
		if("Show Status")
			to_chat(usr, "<b>Queue Server Status</b>")
			to_chat(usr, "Enabled: <b>[SSqueue.queue_enabled ? "<font color='green'>Yes</font>" : "<font color='red'>No</font>"]</b>")
			to_chat(usr, "Queue Threshold: <b>[SSqueue.queue_threshold]</b>")
			to_chat(usr, "Setting Persistence: <b>[SSqueue.persist_queue ? "<font color='green'>Yes</font>" : "<font color='red'>No</font>"]</b>")
		if("Toggle Queue Server")
			SSqueue.queue_enabled = !SSqueue.queue_enabled
			to_chat(usr, "Queue server is now <b>[SSqueue.queue_enabled ? "<font color='green'>Enabled</font>" : "<font color='red'>Disabled</font>"]</b>")
			message_admins("[key_name_admin(usr)] has [SSqueue.queue_enabled ? "enabled" : "disabled"] the server queue.")
			log_admin("[key_name(usr)] has [SSqueue.queue_enabled ? "enabled" : "disabled"] the server queue.")
			GLOB.discord_manager.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "**\[Queue Server]** `[usr.ckey]` has now **[SSqueue.queue_enabled ? "enabled" : "disabled"]** the queue server.")
		if("Set Threshold")
			var/new_threshold = input(usr, "Enter new threshold", "Queue Server Manipulation", SSqueue.queue_threshold) as num|null
			if(!new_threshold)
				return
			SSqueue.queue_threshold = new_threshold
			to_chat(usr, "Queue threshold is now <b>[SSqueue.queue_threshold]</b>")
			message_admins("[key_name_admin(usr)] has set the queue threshold to [SSqueue.queue_threshold].")
			log_admin("[key_name(usr)] has set the queue threshold to [SSqueue.queue_threshold].")
			GLOB.discord_manager.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "**\[Queue Server]** `[usr.ckey]` has set the queue threshold to **[SSqueue.queue_threshold]**.")
		if("Toggle Setting Persistence")
			SSqueue.persist_queue = !SSqueue.persist_queue
			to_chat(usr, "Queue server setting persistence is now <b>[SSqueue.persist_queue ? "<font color='green'>Enabled</font>" : "<font color='red'>Disabled</font>"]</b>")
			message_admins("[key_name_admin(usr)] has [SSqueue.persist_queue ? "enabled" : "disabled"] the server queue settings persistence.")
			log_admin("[key_name(usr)] has [SSqueue.persist_queue ? "enabled" : "disabled"] the server queue settings persistence.")
			GLOB.discord_manager.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "**\[Queue Server]** `[usr.ckey]` has now **[SSqueue.persist_queue ? "enabled" : "disabled"]** server queue settings persistence.")

/client/proc/add_queue_server_bypass()
	set name = "Add Queue Server Bypass"
	set desc = "Allow a ckey to bypass the server queue"
	set category = "Server"

	if(!check_rights(R_SERVER))
		return

	var/bypass_ckey = tgui_input_text(usr, "Please, enter a ckey. Enter nothing to cancel", "Queue Server Bypass")

	if(!bypass_ckey)
		return

	var/clean_ckey = ckey(bypass_ckey)

	if(!clean_ckey)
		to_chat(usr, "Invalid ckey supplied")
		return

	SSqueue.queue_bypass_list.Add(clean_ckey)
	message_admins("[key_name_admin(usr)] has added the ckey [clean_ckey] to the queue bypass list.")
	log_admin("[key_name(usr)] has added the ckey [clean_ckey] to the queue bypass list.")
