/******************** Requests Console ********************/
/** Originally written by errorage, updated by: Carn, needs more work though. I just added some security fixes */

//Request Console Screens
#define RCS_MAINMENU	0	// Main menu
#define RCS_RQSUPPLY	1	// Request supplies
#define RCS_RQASSIST	2	// Request assistance
#define RCS_SENDINFO	3	// Relay information
#define RCS_SENTPASS	4	// Message sent successfully
#define RCS_SENTFAIL	5	// Message sent unsuccessfully
#define RCS_VIEWMSGS	6	// View messages
#define RCS_MESSAUTH	7	// Authentication before sending
#define RCS_ANNOUNCE	8	// Send announcement
#define RCS_SHIPPING	9	// Print Shipping Labels/Packages
#define RCS_SHIP_LOG	10	// View Shipping Label Log
#define RCS_SECONDARY	11	// Request secodary goal

//Radio list. For a console to announce messages on a specific radio, it's "department" variable must be in the list below.
#define ENGI_ROLES list("Atmospherics", "Engineering", "Chief Engineer's Desk")
#define SEC_ROLES list("Warden", "Security", "Detective", "Head of Security's Desk")
#define MISC_ROLES list("Bar", "Chapel", "Kitchen", "Hydroponics", "Janitorial")
#define MED_ROLES list("Virology", "Chief Medical Officer's Desk", "Medbay")
#define COM_ROLES list("Blueshield", "NT Representative", "Head of Personnel's Desk", "Captain's Desk", "Bridge")
#define SCI_ROLES list("Robotics", "Science", "Research Director's Desk")
#define SUPPLY_ROLES list("Cargo Bay", "Mining Dock", "Mining Outpost", "Quartermaster's Desk")

GLOBAL_LIST_EMPTY(req_console_assistance)
GLOBAL_LIST_EMPTY(req_console_supplies)
GLOBAL_LIST_EMPTY(req_console_information)
GLOBAL_LIST_EMPTY(allRequestConsoles)

/obj/machinery/requests_console
	name = "Requests Console"
	desc = "A console intended to send requests to different departments on the station."
	anchored = TRUE
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp_off"
	max_integrity = 300
	armor = list(MELEE = 70, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, RAD = 0, FIRE = 90, ACID = 90)
	/// The name of the containing department. Set this to the same thing if you want several consoles in one department.
	var/department
	/// Bitflag. Zero is reply-only. See [RC_ASSIST], [RC_SUPPLY], [RC_INFO].
	var/departmentType
	var/list/message_log = list() //List of all messages
	var/newmessagepriority = RQ_NONEW_MESSAGES
	var/screen = RCS_MAINMENU
	var/silent = FALSE // set to TRUE for it not to beep all the time
	/// Whether this console can be used to send department announcements
	var/announcementConsole = FALSE
	/// Will be set to TRUE when you authenticate yourself for announcements
	var/announceAuth = FALSE
	/// Will be set to TRUE when you authenticate yourself for requesting a secondary goal
	var/secondaryGoalAuth = FALSE
	/// Will contain the name of the person who verified it
	var/msgVerified = "Not verified"
	/// If a message is stamped, this will contain the stamp name
	var/msgStamped = "Not stamped"
	var/message = ""
	var/recipient = ""; //the department which will be receiving the message
	var/priority = -1 ; //Priority of the message being sent
	var/datum/announcer/announcer = new(config_type = /datum/announcement_configuration/requests_console)
	/// The ID card of the person requesting a secondary goal.
	var/goalRequester
	var/list/shipping_log = list()
	var/ship_tag_name = ""
	var/ship_tag_index = 0
	var/print_cooldown = 0	//cooldown on shipping label printer, stores the  in-game time of when the printer will next be ready
	var/obj/item/radio/Radio
	var/reminder_timer_id = TIMER_ID_NULL
	var/has_active_secondary_goal = FALSE

/obj/machinery/requests_console/power_change()
	if(!..())
		return
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/machinery/requests_console/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return

	. += "req_comp[newmessagepriority]"

	underlays += emissive_appearance(icon, "req_comp_lightmask")

/obj/machinery/requests_console/Initialize(mapload)
	Radio = new /obj/item/radio(src)
	Radio.listening = TRUE
	Radio.config(list("Engineering", "Medical", "Supply", "Command", "Science", "Service", "Security", "AI Private" = FALSE))
	Radio.follow_target = src
	. = ..()

	var/area/containing_area = get_area(src)
	if(isnull(department))
		department = containing_area.request_console_name || trimtext(replacetext(containing_area.name, "\improper", ""))
	if(isnull(departmentType))
		departmentType = containing_area.request_console_flags
	announcementConsole = containing_area.request_console_announces

	announcer.config.default_title = "[department] announcement"

	name = "[department] Requests Console"
	GLOB.allRequestConsoles += src
	if(departmentType & RC_ASSIST)
		GLOB.req_console_assistance |= department
	if(departmentType & RC_SUPPLY)
		GLOB.req_console_supplies |= department
	if(departmentType & RC_INFO)
		GLOB.req_console_information |= department

	update_icon()
	// NOT BOOLEAN. DO NOT CONVERT.
	set_light(1)

/obj/machinery/requests_console/Destroy()
	GLOB.allRequestConsoles -= src
	var/lastDeptRC = TRUE
	for(var/obj/machinery/requests_console/Console in GLOB.allRequestConsoles)
		if(Console.department == department)
			lastDeptRC = FALSE
			break
	if(lastDeptRC)
		if(departmentType & RC_ASSIST)
			GLOB.req_console_assistance -= department
		if(departmentType & RC_SUPPLY)
			GLOB.req_console_supplies -= department
		if(departmentType & RC_INFO)
			GLOB.req_console_information -= department
	QDEL_NULL(Radio)
	return ..()

/obj/machinery/requests_console/attack_ghost(user as mob)
	if(stat & NOPOWER)
		return

	ui_interact(user)

/obj/machinery/requests_console/attack_hand(user as mob)
	if(..(user))
		return

	ui_interact(user)

/obj/machinery/requests_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/requests_console/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RequestConsole", "[department] Request Console")
		ui.open()

/obj/machinery/requests_console/ui_data(mob/user)
	var/list/data = list()

	data["department"] = department
	data["screen"] = screen
	data["message_log"] = message_log
	data["newmessagepriority"] = newmessagepriority
	data["silent"] = silent
	data["announcementConsole"] = announcementConsole

	data["assist_dept"] = GLOB.req_console_assistance
	data["supply_dept"] = GLOB.req_console_supplies
	data["info_dept"]   = GLOB.req_console_information
	data["ship_dept"]	= GLOB.TAGGERLOCATIONS

	data["message"] = message
	data["recipient"] = recipient
	data["priortiy"] = priority
	data["msgStamped"] = msgStamped
	data["msgVerified"] = msgVerified
	data["announceAuth"] = announceAuth
	data["secondaryGoalAuth"] = secondaryGoalAuth
	data["secondaryGoalEnabled"] = !has_active_secondary_goal
	data["shipDest"] = ship_tag_name
	data["shipping_log"] = shipping_log

	return data

/obj/machinery/requests_console/ui_act(action, list/params)
	if(..())
		return

	add_fingerprint(usr)

	. = TRUE

	switch(action)
		if("writeInput")
			if(!reject_bad_text(params["write"]))
				return
			recipient = params["write"] //write contains the string of the receiving department's name
			var/new_message = tgui_input_text(usr, "Write your message:", "Awaiting Input", encode = FALSE)
			if(isnull(new_message))
				reset_message(FALSE)
				return
			message = new_message
			screen = RCS_MESSAUTH
			var/new_priority = text2num(params["priority"])
			switch(new_priority)
				if(RQ_LOWPRIORITY)
					priority = RQ_LOWPRIORITY
				if(RQ_NORMALPRIORITY)
					priority = RQ_NORMALPRIORITY
				if(RQ_HIGHPRIORITY)
					priority = RQ_HIGHPRIORITY
				else
					// Forcibly update UI state
					return TRUE

		if("writeAnnouncement")
			var/new_message = tgui_input_text(usr, "Write your message:", "Awaiting Input", message, multiline = TRUE, encode = FALSE)
			if(isnull(new_message))
				return
			message = new_message

		if("sendAnnouncement")
			if(!announcementConsole)
				return
			if(!announceAuth) // No you don't
				return
			announcer.Announce(message)
			reset_message(TRUE)

		if("requestSecondaryGoal")
			has_active_secondary_goal = check_for_active_secondary_goal(goalRequester)
			if(has_active_secondary_goal || !secondaryGoalAuth)
				return
			var/found_message_server = FALSE
			for(var/obj/machinery/message_server/MS as anything in GLOB.message_servers)
				if(MS.active)
					found_message_server = TRUE
					break
			if(!found_message_server)
				screen = RCS_SENTFAIL
				return

			generate_secondary_goal(department, goalRequester, usr)
			reset_message(FALSE)
			view_messages()
			screen = RCS_VIEWMSGS

		if("department")
			if(send_requests_console_message(message, department, recipient, msgStamped, msgVerified, priority, Radio))
				screen = RCS_SENTPASS
			else
				screen = RCS_SENTFAIL

		//Handle screen switching
		if("setScreen")
			// Ensures screen cant be set higher or lower than it should be
			var/tempScreen = round(clamp(text2num(params["setScreen"]), 0, 11), 1)
			if(tempScreen == RCS_ANNOUNCE && !announcementConsole)
				return
			if(tempScreen == RCS_VIEWMSGS)
				view_messages()
			if(tempScreen == RCS_MAINMENU)
				reset_message()
			if(tempScreen == RCS_SECONDARY)
				has_active_secondary_goal = check_for_active_secondary_goal(goalRequester)
			screen = tempScreen

		if("shipSelect")
			ship_tag_name = params["shipSelect"]
			ship_tag_index = GLOB.TAGGERLOCATIONS.Find(ship_tag_name)

		//Handle Shipping Label Printing
		if("printLabel")
			var/error_message
			if(!ship_tag_index)
				error_message = "Please select a destination."
			else if(!msgVerified)
				error_message = "Please verify shipper ID."
			else if(world.time < print_cooldown)
				error_message = "Please allow the printer time to prepare the next shipping label."
			if(error_message)
				atom_say("[error_message]")
				return
			print_label(ship_tag_name, ship_tag_index)
			shipping_log.Add(list(list("Shipping Label printed for [ship_tag_name]", "[msgVerified]"))) // List in a list for passing into TGUI
			reset_message(TRUE)

		//Handle silencing the console
		if("toggleSilent")
			silent = !silent

/obj/machinery/requests_console/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	var/obj/item/stamp/stamp = used
	if(istype(stamp))
		if(screen == RCS_MESSAUTH && !inoperable(MAINT))
			msgStamped = "Stamped with the [stamp.name]"
			SStgui.update_uis(src)

		return ITEM_INTERACT_COMPLETE

	var/obj/item/card/id/id_card = used
	if(!istype(id_card))
		return ..()

	if(inoperable(MAINT))
		return ITEM_INTERACT_COMPLETE
	if(screen == RCS_MESSAUTH)
		msgVerified = "Verified by [id_card.registered_name] ([id_card.assignment])"
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE
	if(screen == RCS_ANNOUNCE)
		if(ACCESS_RC_ANNOUNCE in id_card.GetAccess())
			announceAuth = TRUE
			announcer.author = id_card.assignment ? "[id_card.assignment] [id_card.registered_name]" : id_card.registered_name
		else
			reset_message()
			to_chat(user, "<span class='warning'>You are not authorized to send announcements.</span>")
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE
	if(screen == RCS_SECONDARY)
		secondaryGoalAuth = TRUE
		goalRequester = id_card
		has_active_secondary_goal = check_for_active_secondary_goal(goalRequester)

		return ITEM_INTERACT_COMPLETE
	if(screen == RCS_SHIPPING)
		msgVerified = "Sender verified as [id_card.registered_name] ([id_card.assignment])"
		SStgui.update_uis(src)

		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/requests_console/proc/reset_message(mainmenu = FALSE)
	message = ""
	recipient = ""
	priority = RQ_NONEW_MESSAGES
	msgVerified = "Not verified"
	msgStamped = "Not stamped"
	announceAuth = FALSE
	secondaryGoalAuth = FALSE
	announcer.author = ""
	goalRequester = ""
	ship_tag_name = ""
	ship_tag_index = FALSE
	if(mainmenu)
		screen = RCS_MAINMENU

/obj/machinery/requests_console/proc/createMessage(source, title, message, priority, forced = FALSE, verified = "", stamped = "")
	var/linkedSender
	if(inoperable() && !forced)
		message_log.Add(list(list("Message lost due to console failure. Please contact [station_name()]'s system administrator or AI for technical assistance.")))
		return
	if(istype(source, /obj/machinery/requests_console))
		var/obj/machinery/requests_console/sender = source
		linkedSender = sender.department
	else
		linkedSender = source
	if(newmessagepriority < priority)
		newmessagepriority = priority
		update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	if(!silent)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, TRUE)
		atom_say(title)
		if(reminder_timer_id == TIMER_ID_NULL && priority > RQ_LOWPRIORITY)
			reminder_timer_id = addtimer(CALLBACK(src, PROC_REF(remind_unread_messages)), 5 MINUTES, TIMER_STOPPABLE | TIMER_LOOP)

	switch(priority)
		if(RQ_HIGHPRIORITY) // High
			message_log.Add(list(list("High Priority - From: [linkedSender]") + message + list(verified, stamped))) // List in a list for passing into TGUI
		else // Normal
			message_log.Add(list(list("From: [linkedSender]") + message + list(verified, stamped))) // List in a list for passing into TGUI
	set_light(2)

/obj/machinery/requests_console/proc/remind_unread_messages()
	if(reminder_timer_id == TIMER_ID_NULL)
		return

	if(newmessagepriority == RQ_NONEW_MESSAGES)
		deltimer(reminder_timer_id)
		reminder_timer_id = TIMER_ID_NULL
		return

	atom_say("Unread message(s) available.")

/obj/machinery/requests_console/proc/print_label(tag_name, tag_index)
	var/obj/item/shipping_package/sp = new /obj/item/shipping_package(get_turf(src))
	sp.sortTag = tag_index
	sp.update_appearance(UPDATE_DESC)
	print_cooldown = world.time + 600	//1 minute cooldown before you can print another label, but you can still configure the next one during this time

/obj/machinery/requests_console/proc/view_messages()
	for(var/obj/machinery/requests_console/Console in GLOB.allRequestConsoles)
		if(Console.department == department)
			Console.newmessagepriority = RQ_NONEW_MESSAGES
			Console.update_icon(UPDATE_OVERLAYS)
			Console.set_light(1)
			if(reminder_timer_id != TIMER_ID_NULL)
				deltimer(reminder_timer_id)
				reminder_timer_id = TIMER_ID_NULL

/obj/machinery/requests_console/proc/check_for_active_secondary_goal(obj/item/card/id/id)
	if(!istype(id))
		return FALSE
	for(var/datum/station_goal/secondary/goal in SSticker.mode.secondary_goals)
		if(goal.requester_name == id.registered_name && !goal.completed)
			return TRUE
	return FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/requests_console, 30, 30)

/proc/send_requests_console_message(message, sender, recipient, stamped, verified, priority, obj/item/radio/radio)
	if(!message)
		return
	var/found_message_server = FALSE
	for(var/obj/machinery/message_server/MS as anything in GLOB.message_servers)
		if(!MS.active)
			continue
		MS.send_rc_message(ckey(recipient), sender, message, stamped, verified, priority)
		found_message_server = TRUE

	if(!found_message_server)
		return FALSE

	if(!radio)
		return TRUE

	var/radiochannel = ""
	if(recipient in ENGI_ROLES)
		radiochannel = "Engineering"
	else if(recipient in SEC_ROLES)
		radiochannel = "Security"
	else if(recipient in MISC_ROLES)
		radiochannel = "Service"
	else if(recipient in MED_ROLES)
		radiochannel = "Medical"
	else if(recipient in COM_ROLES)
		radiochannel = "Command"
	else if(recipient in SCI_ROLES)
		radiochannel = "Science"
	else if(recipient == "AI")
		radiochannel = "AI Private"
	else if(recipient in SUPPLY_ROLES)
		radiochannel = "Supply"
	radio.autosay("Alert; a new message has been received from [sender]", "[recipient] Requests Console", "[radiochannel]")

	return TRUE

/obj/machinery/requests_console/smith
	department = "Smith"
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/requests_console/smith, 30, 30)

#undef RCS_MAINMENU
#undef RCS_RQSUPPLY
#undef RCS_RQASSIST
#undef RCS_SENDINFO
#undef RCS_SENTPASS
#undef RCS_SENTFAIL
#undef RCS_VIEWMSGS
#undef RCS_MESSAUTH
#undef RCS_ANNOUNCE
#undef RCS_SHIPPING
#undef RCS_SHIP_LOG
#undef RCS_SECONDARY
#undef ENGI_ROLES
#undef SEC_ROLES
#undef MISC_ROLES
#undef MED_ROLES
#undef COM_ROLES
#undef SCI_ROLES
#undef SUPPLY_ROLES
