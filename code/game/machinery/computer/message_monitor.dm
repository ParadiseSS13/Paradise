#define MAIN_MENU 0
#define MESSAGE_MENU 1
#define HACKED_MENU 2
#define CUSTOM_MESSAGE_MENU 3
#define CONSOLE_LOGS_MENU 4

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
	/// Screen we show to the user
	var/screen = MAIN_MENU // 0 = Main menu, 1 = Message Logs, 2 = Hacked screen, 3 = Custom Message
	/// Is it beaing hacked into by a silicon?
	var/hacking = FALSE
	/// Are they authenticated?
	#warn Change auth before PRing this
	var/auth = TRUE
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
	screen = HACKED_MENU
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
	screen = MAIN_MENU // Return the screen back to normal

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
	return !(!linkedServer || (linkedServer.stat & (NOPOWER|BROKEN)))

/obj/machinery/computer/message_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MessageMonitorConsole", name)
		ui.open()

/obj/machinery/computer/message_monitor/ui_data(mob/user)
	var/list/data = list()

	data["authenticated"] = auth
	data["possibleServers"] = GLOB.message_servers
	data["server"] = linkedServer.name
	data["active"] = linkedServer.active
	data["password"] = linkedServer.decryptkey

	// PDA stuff.
	var/list/PDA_log = list()
	for(var/datum/data_pda_msg/P in linkedServer.pda_msgs)
		PDA_log += list(list("recipient" = P.recipient,
							"sender" = P.sender,
							"message" = P.message))

	data["PDALog"] = PDA_log

	// Request console stuff.
	var/list/RC_log = list()
	for(var/datum/data_rc_msg/L in linkedServer.rc_msgs)
		RC_log += list(list("recievingDep" = L.rec_dpt,
							"sendingDep" = L.send_dpt,
							"message" = L.message,
							"stamp" = L.stamp,
							"idAuth" = L.id_auth,
							"priority" = L.priority))

	data["RequestLog"] = RC_log

	return data

/obj/machinery/computer/message_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("server")
			to_chat(ui.user, SPAN_NOTICE("IT FUCKING WORKS"))
		if("password")
			var/password = tgui_input_text(ui.user, "Please input the decryption password", "Authentication")
			linkedServer.decryptkey = password

		// Turn the server on/off
		if("active")
			to_chat(ui.user, SPAN_NOTICE("IT FUCKING WORKS"))
			linkedServer.active = !linkedServer.active
			linkedServer.update_icon(UPDATE_ICON_STATE)

		if("deleteR")
			if(!check_password())
				to_chat(ui.user, SPAN_WARNING("No server found"))
				return
			var/datum/data_rc_msg/R = locate(params["Rmessage"])
			log_debug("[R]")
			if(istype(R, /datum/data_rc_msg))
				linkedServer.rc_msgs -= R
				to_chat(ui.user, SPAN_NOTICE("Request message deleted!"))
			else
				to_chat(ui.user, SPAN_WARNING("Could not delete the request message!"))

		if("deleteP")
			if(!check_password())
				to_chat(ui.user, SPAN_WARNING("No server found"))
				return
			var/datum/data_pda_msg/P = locate(params["Pmessage"])
			log_debug("[P]")
			if(istype(P, /datum/data_pda_msg))
				linkedServer.pda_msgs -= P
				to_chat(ui.user, SPAN_NOTICE("PDA message deleted!"))
			else
				to_chat(ui.user, SPAN_WARNING("Could not delete the PDA message!"))

		if("clear_msg")
			if(check_password())
				linkedServer.pda_msgs = list()
				to_chat(ui.user, SPAN_NOTICE("All PDA messages cleared!"))
			else
				to_chat(ui.user, SPAN_WARNING("No server found"))

		if("clear_req")
			if(check_password())
				linkedServer.rc_msgs = list()
				to_chat(ui.user, SPAN_NOTICE("All Request Console messages cleared!"))
			else
				to_chat(ui.user, SPAN_WARNING("No server found"))

		if("admin_msg")
			return

		if("custom_key")
			return




#undef MAIN_MENU
#undef MESSAGE_MENU
#undef HACKED_MENU
#undef CUSTOM_MESSAGE_MENU
#undef CONSOLE_LOGS_MENU
