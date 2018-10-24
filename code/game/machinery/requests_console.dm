/******************** Requests Console ********************/
/** Originally written by errorage, updated by: Carn, needs more work though. I just added some security fixes */

//Request Console Department Types
#define RC_ASSIST 1		//Request Assistance
#define RC_SUPPLY 2		//Request Supplies
#define RC_INFO   4		//Relay Info

//Request Console Screens
#define RCS_MAINMENU 0	// Main menu
#define RCS_RQSUPPLY 1	// Request supplies
#define RCS_RQASSIST 2	// Request assistance
#define RCS_SENDINFO 3	// Relay information
#define RCS_SENTPASS 4	// Message sent successfully
#define RCS_SENTFAIL 5	// Message sent unsuccessfully
#define RCS_VIEWMSGS 6	// View messages
#define RCS_MESSAUTH 7	// Authentication before sending
#define RCS_ANNOUNCE 8	// Send announcement
#define RCS_SHIPPING 9	// Print Shipping Labels/Packages
#define RCS_SHIP_LOG 10	// View Shipping Label Log

//Radio list
#define ENGI_ROLES list("Atmospherics","Mechanic","Engineering","Chief Engineer's Desk","Telecoms Admin")
#define SEC_ROLES list("Warden","Security","Brig Medbay","Head of Security's Desk")
#define MISC_ROLES list("Bar","Chapel","Kitchen","Hydroponics","Janitorial")
#define MED_ROLES list("Virology","Chief Medical Officer's Desk","Medbay")
#define COM_ROLES list("Blueshield","NT Representative","Head of Personnel's Desk","Captain's Desk","Bridge")
#define SCI_ROLES list("Robotics","Science","Research Director's Desk")

var/req_console_assistance = list()
var/req_console_supplies = list()
var/req_console_information = list()
var/list/obj/machinery/requests_console/allConsoles = list()

/obj/machinery/requests_console
	name = "Requests Console"
	desc = "A console intended to send requests to different departments on the station."
	anchored = 1
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp0"
	armor = list(melee = 70, bullet = 30, laser = 30, energy = 30, bomb = 0, bio = 0, rad = 0)
	var/department = "Unknown" //The list of all departments on the station (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/list/message_log = list() //List of all messages
	var/departmentType = 0 		//Bitflag. Zero is reply-only. Map currently uses raw numbers instead of defines.
	var/newmessagepriority = 0
		// 0 = no new message
		// 1 = normal priority
		// 2 = high priority
	var/screen = RCS_MAINMENU
	var/silent = 0 // set to 1 for it not to beep all the time
//	var/hackState = 0
		// 0 = not hacked
		// 1 = hacked
	var/announcementConsole = 0
		// 0 = This console cannot be used to send department announcements
		// 1 = This console can send department announcementsf
	var/open = 0 // 1 if open
	var/announceAuth = 0 //Will be set to 1 when you authenticate yourself for announcements
	var/msgVerified = "" //Will contain the name of the person who varified it
	var/msgStamped = "" //If a message is stamped, this will contain the stamp name
	var/message = "";
	var/recipient = ""; //the department which will be receiving the message
	var/priority = -1 ; //Priority of the message being sent
	light_range = 0
	var/datum/announcement/announcement = new
	var/list/shipping_log = list()
	var/ship_tag_name = ""
	var/ship_tag_index = 0
	var/print_cooldown = 0	//cooldown on shipping label printer, stores the  in-game time of when the printer will next be ready
	var/obj/item/radio/Radio
	var/radiochannel = ""

/obj/machinery/requests_console/power_change()
	..()
	update_icon()

/obj/machinery/requests_console/update_icon()
	if(stat & NOPOWER)
		if(icon_state != "req_comp_off")
			icon_state = "req_comp_off"
	else
		icon_state = "req_comp[newmessagepriority]"

/obj/machinery/requests_console/New()
	Radio = new /obj/item/radio(src)
	Radio.listening = 1
	Radio.config(list("Engineering","Medical","Supply","Command","Science","Service","Security", "AI Private" = 0))
	Radio.follow_target = src
	..()

	announcement.title = "[department] announcement"
	announcement.newscast = 0

	name = "[department] Requests Console"
	allConsoles += src
	if(departmentType & RC_ASSIST)
		req_console_assistance |= department
	if(departmentType & RC_SUPPLY)
		req_console_supplies |= department
	if(departmentType & RC_INFO)
		req_console_information |= department

	set_light(1)

/obj/machinery/requests_console/Destroy()
	allConsoles -= src
	var/lastDeptRC = 1
	for(var/obj/machinery/requests_console/Console in allConsoles)
		if(Console.department == department)
			lastDeptRC = 0
			break
	if(lastDeptRC)
		if(departmentType & RC_ASSIST)
			req_console_assistance -= department
		if(departmentType & RC_SUPPLY)
			req_console_supplies -= department
		if(departmentType & RC_INFO)
			req_console_information -= department
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

/obj/machinery/requests_console/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "request_console.tmpl", "[department] Request Console", 520, 410)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/requests_console/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]

	data["department"] = department
	data["screen"] = screen
	data["message_log"] = message_log
	data["newmessagepriority"] = newmessagepriority
	data["silent"] = silent
	data["announcementConsole"] = announcementConsole

	data["assist_dept"] = req_console_assistance
	data["supply_dept"] = req_console_supplies
	data["info_dept"]   = req_console_information
	data["ship_dept"]	= GLOB.TAGGERLOCATIONS

	data["message"] = message
	data["recipient"] = recipient
	data["priortiy"] = priority
	data["msgStamped"] = msgStamped
	data["msgVerified"] = msgVerified
	data["announceAuth"] = announceAuth
	data["shipDest"] = ship_tag_name
	data["shipping_log"] = shipping_log

	return data

/obj/machinery/requests_console/Topic(href, href_list)
	if(..())
		return 1
	usr.set_machine(src)
	add_fingerprint(usr)

	if(reject_bad_text(href_list["write"]))
		recipient = href_list["write"] //write contains the string of the receiving department's name

		var/new_message = sanitize(input("Write your message:", "Awaiting Input", ""))
		if(new_message)
			message = new_message
			screen = RCS_MESSAUTH
			switch(href_list["priority"])
				if("1") priority = 1
				if("2")	priority = 2
				else	priority = 0
		else
			reset_message(1)

	if(href_list["writeAnnouncement"])
		var/new_message = sanitize(input("Write your message:", "Awaiting Input", ""))
		if(new_message)
			message = new_message
		else
			reset_message(1)

	if(href_list["sendAnnouncement"])
		if(!announcementConsole)	return
		announcement.Announce(message, msg_sanitized = 1)
		reset_message(1)

	if( href_list["department"] && message )
		var/log_msg = message
		var/pass = 0
		screen = RCS_SENTFAIL
		for(var/obj/machinery/message_server/MS in world)
			if(!MS.active) continue
			MS.send_rc_message(ckey(href_list["department"]),department,log_msg,msgStamped,msgVerified,priority)
			pass = 1
		if(pass)
			screen = RCS_SENTPASS
			if(recipient in ENGI_ROLES)
				radiochannel = "Engineering"
			if(recipient in SEC_ROLES)
				radiochannel = "Security"
			if(recipient in MISC_ROLES)
				radiochannel = "Service"
			if(recipient in MED_ROLES)
				radiochannel = "Medical"
			if(recipient in COM_ROLES)
				radiochannel = "Command"
			if(recipient in SCI_ROLES)
				radiochannel = "Science"
			if(recipient == "AI")
				radiochannel = "AI Private"
			if(recipient == "Cargo Bay")
				radiochannel = "Supply"
			message_log += "<B>Message sent to [recipient] at [station_time_timestamp()]</B><BR>[message]"
			Radio.autosay("Alert; a new requests console message received for [recipient] from [department]", null, "[radiochannel]")
		else
			audible_message(text("[bicon(src)] *The Requests Console beeps: '<b>NOTICE:</b> No server detected!'"),,4)

	//Handle screen switching
	if(href_list["setScreen"])
		var/tempScreen = text2num(href_list["setScreen"])
		if(tempScreen == RCS_ANNOUNCE && !announcementConsole)
			return
		if(tempScreen == RCS_VIEWMSGS)
			for(var/obj/machinery/requests_console/Console in allConsoles)
				if(Console.department == department)
					Console.newmessagepriority = 0
					Console.icon_state = "req_comp0"
					Console.set_light(1)
		if(tempScreen == RCS_MAINMENU)
			reset_message()
		screen = tempScreen

	if(href_list["shipSelect"])
		ship_tag_name = href_list["shipSelect"]
		ship_tag_index = GLOB.TAGGERLOCATIONS.Find(ship_tag_name)

	//Handle Shipping Label Printing
	if(href_list["printLabel"])
		var/error_message = ""
		if(!ship_tag_index)
			error_message = "Please select a destination."
		else if(!msgVerified)
			error_message = "Please verify shipper ID."
		else if(world.time < print_cooldown)
			error_message = "Please allow the printer time to prepare the next shipping label."
		if(error_message)
			audible_message(text("[bicon(src)] *The Requests Console beeps: '<b>NOTICE:</b> [error_message]'"),,4)
			return
		print_label(ship_tag_name, ship_tag_index)
		shipping_log += "<B>Shipping Label printed for [ship_tag_name]</b><br>[msgVerified]"
		reset_message(1)

	//Handle silencing the console
	if(href_list["toggleSilent"])
		silent = !silent

	SSnanoui.update_uis(src)
	return

					//err... hacking code, which has no reason for existing... but anyway... it was once supposed to unlock priority 3 messanging on that console (EXTREME priority...), but the code for that was removed.
/obj/machinery/requests_console/attackby(obj/item/I, mob/user)
	/*
	if(istype(O, /obj/item/crowbar))
		if(open)
			open = 0
			icon_state="req_comp0"
		else
			open = 1
			if(hackState == 0)
				icon_state="req_comp_open"
			else if(hackState == 1)
				icon_state="req_comp_rewired"
	if(istype(O, /obj/item/screwdriver))
		if(open)
			if(hackState == 0)
				hackState = 1
				icon_state="req_comp_rewired"
			else if(hackState == 1)
				hackState = 0
				icon_state="req_comp_open"
		else
			to_chat(user, "You can't do much with that.")*/

	if(istype(I, /obj/item/card/id))
		if(inoperable(MAINT))
			return
		if(screen == RCS_MESSAUTH)
			var/obj/item/card/id/T = I
			msgVerified = text("<font color='green'><b>Verified by [T.registered_name] ([T.assignment])</b></font>")
			updateUsrDialog()
		if(screen == RCS_ANNOUNCE)
			var/obj/item/card/id/ID = I
			if(access_RC_announce in ID.GetAccess())
				announceAuth = 1
				announcement.announcer = ID.assignment ? "[ID.assignment] [ID.registered_name]" : ID.registered_name
			else
				reset_message()
				to_chat(user, "<span class='warning'>You are not authorized to send announcements.</span>")
			updateUsrDialog()
		if(screen == RCS_SHIPPING)
			var/obj/item/card/id/T = I
			msgVerified = text("<font color='green'><b>Sender verified as [T.registered_name] ([T.assignment])</b></font>")
			updateUsrDialog()
	if(istype(I, /obj/item/stamp))
		if(inoperable(MAINT))
			return
		if(screen == RCS_MESSAUTH)
			var/obj/item/stamp/T = I
			msgStamped = text("<font color='blue'><b>Stamped with the [T.name]</b></font>")
			updateUsrDialog()
	else
		return ..()

/obj/machinery/requests_console/proc/reset_message(var/mainmenu = 0)
	message = ""
	recipient = ""
	priority = 0
	msgVerified = ""
	msgStamped = ""
	announceAuth = 0
	announcement.announcer = ""
	ship_tag_name = ""
	ship_tag_index = 0
	if(mainmenu)
		screen = RCS_MAINMENU

/obj/machinery/requests_console/proc/createMessage(source, title, message, priority)
	var/linkedSender
	if(istype(source, /obj/machinery/requests_console))
		var/obj/machinery/requests_console/sender = source
		linkedSender = "<a href='?src=[UID()];write=[ckey(sender.department)]'[sender.department]</a>"
	else
		capitalize(source)
		linkedSender = source
	capitalize(title)
	if(src.newmessagepriority < priority)
		src.newmessagepriority = priority
		update_icon()
	if(!src.silent)
		playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
		atom_say(title)

	switch(priority)
		if(2) // High
			src.message_log += "<span class='bad'>High Priority</span><BR><b>From:</b> [linkedSender]<BR>[message]"
		else // Normal
			src.message_log += "<b>From:</b> [linkedSender]<BR>[message]"
	set_light(2)

/obj/machinery/requests_console/proc/print_label(tag_name, tag_index)
	var/obj/item/shippingPackage/sp = new /obj/item/shippingPackage(get_turf(src))
	sp.sortTag = tag_index
	sp.update_desc()
	print_cooldown = world.time + 600	//1 minute cooldown before you can print another label, but you can still configure the next one during this time
