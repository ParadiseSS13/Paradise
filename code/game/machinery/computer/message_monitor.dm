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
	var/hacking = TRUE
	/// Are they authenticated?
	var/auth = FALSE
	var/optioncount = 8
	// Custom Message Properties
	/// Sender of a custom message
	var/customsender = "System Administrator"
	/// Recipient of a custom message
	var/obj/item/pda/customrecepient = null
	var/customjob = "Admin"
	var/custommessage  = "This is a test, please ignore."

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
	if(!isnull(src.linkedServer))
		icon_screen = hack_icon // An error screen I made in the computers.dmi
		emagged = TRUE
		screen = HACKED_MENU
		do_sparks(5, 0, src)
		var/obj/item/paper/monitorkey/MK = new/obj/item/paper/monitorkey
		MK.loc = src.loc
		playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
		// Will help make emagging the console not so easy to get away with.
		MK.info += "<br><br><font color='red'>�%@%(*$%&(�&?*(%&�/{}</font>"
		update_icon()
		spawn(100*length(src.linkedServer.decryptkey))
			UnmagConsole()
			update_icon()
	else
		to_chat(user, SPAN_WARNING("No server found"))


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
		var/currentKey = src.linkedServer.decryptkey
		to_chat(user, SPAN_WARNING("Brute-force completed! The key is '[currentKey]'."))
	src.hacking = TRUE
	src.icon_screen = normal_icon
	src.screen = MAIN_MENU // Return the screen back to normal

/obj/machinery/computer/message_monitor/proc/UnmagConsole()
	src.icon_screen = normal_icon
	src.emagged = FALSE

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
	data["power"] = linkedServer.active
	data["password"] = linkedServer.decryptkey

	// PDA stuff.
	var/list/senders = list()
	var/list/recipients = list()
	var/list/messages = list()
	for(var/datum/data_pda_msg/PDA_data in linkedServer.pda_msgs)
		senders += PDA_data.sender
		recipients += PDA_data.recipient
		messages += PDA_data.message

	data["sender"] = senders
	data["recipient"] = recipients
	data["message"] = messages

	// Request console stuff.
	var/list/sendingDep = list()
	var/list/recievingDep = list()
	var/list/message = list()
	var/list/stamp = list()
	var/list/idAuth = list()
	var/list/priority = list()
	for(var/datum/data_rc_msg/RC_data in linkedServer.rc_msgs)
		sendingDep += RC_data.send_dpt
		recievingDep += RC_data.rec_dpt
		message += RC_data.message
		stamp += RC_data.stamp
		idAuth += RC_data.id_auth
		priority += RC_data.priority
	data["sendingDep"] = sendingDep
	data["recievingDep"] = recievingDep
	data["message"] = message
	data["stamp"] = stamp
	data["idAuth"] = idAuth
	data["priority"] = priority

	return data

/obj/machinery/computer/message_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(!usr.contents.Find(ui.src_object) || !(in_range(ui.src_object, usr) && isturf(ui.src_object)) || !issilicon(usr))
		return
	switch(action)
		if("server")
			to_chat(ui.user, SPAN_NOTICE("IT FUCKING WORKS"))
		if("password")
			var/password = tgui_input_text(ui.user, "Please input the decryption password", "Authentication")

		// Turn the server on/off
		if("power")
			if(auth)
				linkedServer.active = !linkedServer.active

		if("clear_msg")
			return

		if("clear_req")
			return

		if("admin_msg")
			return

		if("custom_key")
			return




#undef MAIN_MENU
#undef MESSAGE_MENU
#undef HACKED_MENU
#undef CUSTOM_MESSAGE_MENU
#undef CONSOLE_LOGS_MENU
