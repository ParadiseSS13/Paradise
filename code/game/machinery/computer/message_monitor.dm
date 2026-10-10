// Allows you to monitor messages that passes the server.
/obj/machinery/computer/message_monitor
	name = "message monitoring console"
	desc = "Used to monitor the crew's messages that are sent via PDA. It can also be used to view Request Console messages."
	icon_screen = "comm_logs"
	light_color = LIGHT_COLOR_GREEN
	var/hack_icon = "tcboss"
	var/normal_icon = "comm_logs"
	circuit = /obj/item/circuitboard/message_monitor
	/// PDA server linked to.
	var/obj/machinery/message_server/linkedServer = null
	//Messages - Saves me time if I want to change something.
	/// Is it beaing hacked into by a silicon?
	var/hacking = FALSE
	/// Is the console authenticated?
	var/auth = FALSE
	// Custom Message Properties
	/// Sender of a custom message
	var/customsender = "System Administrator"
	/// Recipient of a custom message
	var/obj/item/pda/customrecepient = null

	light_color = LIGHT_COLOR_DARKGREEN

/obj/machinery/computer/message_monitor/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD // Give the message server time to initialize

/obj/machinery/computer/message_monitor/LateInitialize()
	//If the monitor isn't linked to a server, and there's a server available, default it to the first one in the list.
	if(!linkedServer && length(GLOB.message_servers))
		linkedServer = GLOB.message_servers[1]
		RegisterSignal(linkedServer, COMSIG_PARENT_QDELETING, PROC_REF(unlink_server))

/obj/machinery/computer/message_monitor/proc/unlink_server()
	SIGNAL_HANDLER
	linkedServer = null

/obj/machinery/computer/message_monitor/Destroy()
	customrecepient = null
	linkedServer = null
	return ..()

/obj/machinery/computer/message_monitor/screwdriver_act(mob/user, obj/item/I)
	if(emagged) //Stops people from just unscrewing the monitor and putting it back to get the console working again.
		to_chat(user, SPAN_WARNING("It is too hot to mess with!"))
		return
	return ..()

/obj/machinery/computer/message_monitor/emag_act(mob/user)
	// Will create sparks and print out the console's password. You will then have to wait a while for the console to be back online.
	// It'll take more time if there's more characters in the password..
	if(emagged)
		return FALSE

	if(isnull(linkedServer))
		to_chat(user, SPAN_WARNING("No server found"))
		return FALSE

	icon_screen = hack_icon // An error screen I made in the computers.dmi
	emagged = TRUE
	do_sparks(5, 0, src)
	var/obj/item/paper/monitorkey/MK = new/obj/item/paper/monitorkey
	MK.loc = loc
	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
	// Will help make emagging the console not so easy to get away with.
	MK.info += "<br><br><font color='red'>�%@%(*$%&(�&?*(%&�/{}</font>"
	update_icon()
	spawn(100*length(linkedServer.decryptkey))
		UnmagConsole()
		update_icon()



/obj/machinery/computer/message_monitor/update_icon_state()
	if(emagged || hacking)
		icon_screen = hack_icon
	else
		icon_screen = normal_icon

/obj/machinery/computer/message_monitor/attack_hand(mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

/obj/machinery/computer/message_monitor/proc/BruteForce(mob/user as mob)
	if(isnull(linkedServer))
		to_chat(user, SPAN_WARNING("Could not complete brute-force: Linked Server Disconnected!"))
	else
		var/currentKey = linkedServer.decryptkey
		to_chat(user, SPAN_WARNING("Brute-force completed! The key is '[currentKey]'."))
	hacking = TRUE
	icon_screen = normal_icon

/obj/machinery/computer/message_monitor/proc/UnmagConsole()
	icon_screen = normal_icon
	emagged = FALSE

/obj/item/paper/monitorkey
	name = "Monitor Decryption Key"
	var/obj/machinery/message_server/server = null

/obj/item/paper/monitorkey/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/paper/monitorkey/LateInitialize()
	for(var/obj/machinery/message_server/server in GLOB.message_servers)
		if(!isnull(server))
			if(!isnull(server.decryptkey))
				info = "<center><h2>Daily Key Reset</h2></center>\n\t<br>The new message monitor key is '[server.decryptkey]'.<br>Please keep this a secret and away from the clown.<br>If necessary, change the password to a more secure one."
				info_links = info
				overlays += "paper_words"
				break

/// Checks for a password and server status returns `TRUE` if the conditions are vaible, othervise returns `FLASE`
/obj/machinery/computer/message_monitor/proc/check_password()
	if(isnull(linkedServer))
		return FALSE
	return !(!linkedServer || (linkedServer.stat & (NOPOWER|BROKEN)))

/obj/machinery/computer/message_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MessageMonitorConsole", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/message_monitor/ui_data(mob/user)
	var/list/data = list()

	data["authenticated"] = auth
	if(linkedServer)
		data["active"] = linkedServer.active
		data["password"] = linkedServer.decryptkey
		data["server"] = linkedServer.UID()
		// PDA stuff.
		var/list/PDA_log = list()
		for(var/datum/data_pda_msg/P in linkedServer.pda_msgs)
			PDA_log += list(list("recipient" = P.recipient,
								"sender" = P.sender,
								"message" = P.message,
								"uid" = P.UID()))

		data["PDALog"] = PDA_log

		// Request console stuff.
		var/list/RC_log = list()
		for(var/datum/data_rc_msg/L in linkedServer.rc_msgs)
			RC_log += list(list("recievingDep" = L.rec_dpt,
								"sendingDep" = L.send_dpt,
								"message" = L.message,
								"stamp" = L.stamp,
								"idAuth" = L.id_auth,
								"priority" = L.priority,
								"uid" = L.UID()))

		data["RequestLog"] = RC_log

	// All  messaging server UIDs.
	var/list/servers = list()
	for(var/obj/machinery/message_server/S in GLOB.message_servers)
		servers += S.UID()

	data["servers"] = servers

	// All possible PDAs to send messages to.
	var/list/recipients = list()
	for(var/obj/item/pda/P in GLOB.PDAs)
		var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)
		if(!PM || !PM.can_receive())
			continue
		recipients += list(list("uid" = P.UID(), "name" = P.name))

	data["recipients"] = recipients

	return data

/obj/machinery/computer/message_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		// Log into the server
		if("decrypt")
			var/obj/machinery/message_server/chosen_server = locateUID(params["server"])
			if(!istype(chosen_server, /obj/machinery/message_server))
				to_chat(ui.user, SPAN_ALERT("uh oh something went wrong please Ahelp or file a bug report, decrypt action."))
				return
			var/chosen_password = params["password"]
			if(chosen_server.decryptkey == chosen_password)
				to_chat(ui.user, SPAN_NOTICE("Decryption successful!"))
				auth = TRUE
				linkedServer = chosen_server
			else
				to_chat(ui.user, SPAN_WARNING("Decryption failed!"))

		// Log out of the server
		if("logout")
			auth = FALSE
			linkedServer = null

		// Chnage the password
		if("password")
			if(!check_password())
				to_chat(ui.user, SPAN_WARNING("No server found"))
				return
			var/password = tgui_input_text(ui.user, "Please input the decryption password", "Authentication")
			linkedServer.decryptkey = password
			to_chat(ui.user, SPAN_NOTICE("Password successfully changed to [password]"))

		// Turn the server on/off
		if("active")
			linkedServer.active = !linkedServer.active
			linkedServer.update_icon(UPDATE_ICON_STATE)
			to_chat(ui.user, SPAN_NOTICE("Server is now [linkedServer.active ? "active" : "inactive"]"))

		// Deletes a specific Request console messages
		if("deleteR")
			if(!check_password())
				to_chat(ui.user, SPAN_WARNING("No server found"))
				return
			var/datum/data_rc_msg/msg = locateUID(params["Rmessage"])
			var/datum/data_rc_msg/R = locate(msg) in linkedServer.rc_msgs
			if(!istype(R, /datum/data_rc_msg))
				to_chat(ui.user, SPAN_ALERT("Uh oh something went wrong please Ahelp or file a bug report, DeleteR error."))
				return
			to_chat(ui.user, SPAN_NOTICE("Request message deleted!"))

		// Deletes a specific PDA messages
		if("deleteP")
			if(!check_password())
				to_chat(ui.user, SPAN_WARNING("No server found"))
				return
			var/datum/data_pda_msg/P = locateUID(params["Pmessage"])
			if(!istype(P, /datum/data_pda_msg))
				to_chat(ui.user, SPAN_ALERT("Uh oh something went wrong please Ahelp or file a bug report, DeleteP error."))
				return
			linkedServer.pda_msgs -= P
			to_chat(ui.user, SPAN_NOTICE("PDA message deleted!"))

		// Deletes all PDA messaages from the server
		if("clear_msg")
			if(!check_password())
				to_chat(ui.user, SPAN_WARNING("No server found"))
				return
			linkedServer.pda_msgs = list()
			to_chat(ui.user, SPAN_NOTICE("All PDA messages cleared!"))


		// Deletes all request console messages from the server
		if("clear_req")
			if(!check_password())
				to_chat(ui.user, SPAN_WARNING("No server found"))
				return
			linkedServer.rc_msgs = list()
			to_chat(ui.user, SPAN_NOTICE("All Request Console messages cleared!"))

		if("admin_msg")
			if(!check_password())
				to_chat(ui.user, SPAN_WARNING("No server found"))
				return
			var/sender = params["sender"]
			var/senderJob = params["senderJob"]
			var/obj/item/pda/recipient_PDA = locateUID(params["recipient"])
			var/message = params["message"]
			if(!istype(recipient_PDA, /obj/item/pda))
				to_chat(ui.user, SPAN_WARNING("Uh oh something went wrong please Ahelp or file a bug report, admin_msg error."))
				return
			linkedServer.send_pda_message("[recipient_PDA.owner]", "[sender]", "[message]")
			var/datum/data/pda/app/messenger/recipient_messenger = recipient_PDA.find_program(/datum/data/pda/app/messenger/)
			if(!istype(recipient_messenger, /datum/data/pda/app/messenger/))
				to_chat(ui.user, SPAN_WARNING("Uh oh something went wrong please Ahelp or file a bug report, admin_msg error."))
				return
			recipient_messenger.notify("<b>Message from [sender] ([senderJob]), </b>\"[message]\" (<a href='byond://?src=[UID()];choice=Message;target=\ref[src]'>Reply</a>)")
			// Logging.
			log_pda("(PDA: [sender]) sent \"[message]\" to [recipient_PDA.owner]", ui.user)
			investigate_log("PDA Message - Custom Name: \"[sender]\", Custom Job: \"[senderJob]\", Real Sender: \"[key_name(ui.user)]\" ([ADMIN_PP(ui.user,"PP")]) -> [recipient_PDA.owner] ([ADMIN_VV(recipient_PDA, "VV")]), Message: \"[message]\"", "pda")
			ui.user.create_log(MISC_LOG, "sent PDA message \"[message]\" using [ui.src_object] as [sender] ([senderJob]) to [recipient_PDA]")
