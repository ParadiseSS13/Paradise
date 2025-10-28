USER_VERB(manage_queue, R_SERVER, "Manage Queue Server", "Manage the queue server and its settings", VERB_CATEGORY_SERVER)
	var/list/choices = list("Show Status", "Toggle Queue Server", "Set Threshold", "Toggle Setting Persistence")
	var/choice = input(client, "Please, select an option", "Queue Server Manipulation") as null|anything in choices

	switch(choice)
		if("Show Status")
			to_chat(client, "<b>Queue Server Status</b>")
			to_chat(client, "Enabled: <b>[SSqueue.queue_enabled ? "<font color='green'>Yes</font>" : "<font color='red'>No</font>"]</b>")
			to_chat(client, "Queue Threshold: <b>[SSqueue.queue_threshold]</b>")
			to_chat(client, "Setting Persistence: <b>[SSqueue.persist_queue ? "<font color='green'>Yes</font>" : "<font color='red'>No</font>"]</b>")
		if("Toggle Queue Server")
			SSqueue.queue_enabled = !SSqueue.queue_enabled
			to_chat(client, "Queue server is now <b>[SSqueue.queue_enabled ? "<font color='green'>Enabled</font>" : "<font color='red'>Disabled</font>"]</b>")
			message_admins("[key_name_admin(client)] has [SSqueue.queue_enabled ? "enabled" : "disabled"] the server queue.")
			log_admin("[key_name(client)] has [SSqueue.queue_enabled ? "enabled" : "disabled"] the server queue.")
			GLOB.discord_manager.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "**\[Queue Server]** `[client.ckey]` has now **[SSqueue.queue_enabled ? "enabled" : "disabled"]** the queue server.")
		if("Set Threshold")
			var/new_threshold = input(client, "Enter new threshold", "Queue Server Manipulation", SSqueue.queue_threshold) as num|null
			if(!new_threshold)
				return
			SSqueue.queue_threshold = new_threshold
			to_chat(client, "Queue threshold is now <b>[SSqueue.queue_threshold]</b>")
			message_admins("[key_name_admin(client)] has set the queue threshold to [SSqueue.queue_threshold].")
			log_admin("[key_name(client)] has set the queue threshold to [SSqueue.queue_threshold].")
			GLOB.discord_manager.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "**\[Queue Server]** `[client.ckey]` has set the queue threshold to **[SSqueue.queue_threshold]**.")
		if("Toggle Setting Persistence")
			SSqueue.persist_queue = !SSqueue.persist_queue
			to_chat(client, "Queue server setting persistence is now <b>[SSqueue.persist_queue ? "<font color='green'>Enabled</font>" : "<font color='red'>Disabled</font>"]</b>")
			message_admins("[key_name_admin(client)] has [SSqueue.persist_queue ? "enabled" : "disabled"] the server queue settings persistence.")
			log_admin("[key_name(client)] has [SSqueue.persist_queue ? "enabled" : "disabled"] the server queue settings persistence.")
			GLOB.discord_manager.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "**\[Queue Server]** `[client.ckey]` has now **[SSqueue.persist_queue ? "enabled" : "disabled"]** server queue settings persistence.")

USER_VERB(add_queue_server_bypass, R_SERVER, "Add Queue Server Bypass", "Allow a ckey to bypass the server queue", VERB_CATEGORY_SERVER)
	var/bypass_ckey = tgui_input_text(client, "Please, enter a ckey. Enter nothing to cancel", "Queue Server Bypass")

	if(!bypass_ckey)
		return

	var/clean_ckey = ckey(bypass_ckey)

	if(!clean_ckey)
		to_chat(client, "Invalid ckey supplied")
		return

	SSqueue.queue_bypass_list.Add(clean_ckey)
	message_admins("[key_name_admin(client)] has added the ckey [clean_ckey] to the queue bypass list.")
	log_admin("[key_name(client)] has added the ckey [clean_ckey] to the queue bypass list.")
