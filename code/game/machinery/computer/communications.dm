#define COMM_SCREEN_MAIN		1
#define COMM_SCREEN_STAT		2
#define COMM_SCREEN_MESSAGES	3
#define COMM_SCREEN_ANNOUNCER	4

#define COMM_AUTHENTICATION_NONE	0
#define COMM_AUTHENTICATION_HEAD	1
#define COMM_AUTHENTICATION_CAPT	2
#define COMM_AUTHENTICATION_CENTCOM	3 // Admin-only access
#define COMM_AUTHENTICATION_AGHOST	4

#define COMM_MSGLEN_MINIMUM 6
#define COMM_CCMSGLEN_MINIMUM 20

#define ADMIN_CHECK(user) (check_rights(R_ADMIN|R_EVENT, FALSE, user, all = TRUE) && (authenticated >= COMM_AUTHENTICATION_CENTCOM || user.can_admin_interact()))

// The communications computer
/obj/machinery/computer/communications
	name = "communications console"
	desc = "This allows the Captain to contact Central Command, or change the alert level. It also allows the command staff to call the Escape Shuttle."
	icon_keyboard = "tech_key"
	icon_screen = "comm"
	req_access = list(ACCESS_HEADS)
	circuit = /obj/item/circuitboard/communications
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg

	var/authenticated = COMM_AUTHENTICATION_NONE
	var/menu_state = COMM_SCREEN_MAIN
	var/ai_menu_state = COMM_SCREEN_MAIN
	var/aicurrmsg

	var/message_cooldown
	var/centcomm_message_cooldown
	var/alert_level_cooldown = 0

	var/stat_msg1
	var/stat_msg2
	var/display_type = STATUS_DISPLAY_TIME
	var/display_icon

	var/datum/announcer/announcer = new(config_type = /datum/announcement_configuration/comms_console)

	light_color = LIGHT_COLOR_LIGHTBLUE

	var/list/cc_announcement_sounds = list("Beep" = 'sound/misc/notice2.ogg',
		"Enemy Communications Intercepted" = 'sound/AI/intercept.ogg',
		"New Command Report Created" = 'sound/AI/commandreport.ogg')

/obj/machinery/computer/communications/New()
	GLOB.shuttle_caller_list += src
	..()

/obj/machinery/computer/communications/Initialize(mapload)
	. = ..()

/obj/machinery/computer/communications/proc/is_authenticated(mob/user, message = 1)
	if(check_rights(R_ADMIN|R_EVENT, FALSE, user, all = TRUE))
		if(user.can_admin_interact())
			return COMM_AUTHENTICATION_AGHOST
		if(authenticated == COMM_AUTHENTICATION_CENTCOM)
			return COMM_AUTHENTICATION_CENTCOM
	if(authenticated == COMM_AUTHENTICATION_CAPT)
		return COMM_AUTHENTICATION_CAPT
	if(authenticated)
		return COMM_AUTHENTICATION_HEAD
	if(message)
		to_chat(user, "<span class='warning'>Access denied.</span>")
	return COMM_AUTHENTICATION_NONE

/obj/machinery/computer/communications/proc/change_security_level(new_level, force)
	var/old_level = SSsecurity_level.get_current_level_as_number()
	if(!force)
		new_level = clamp(new_level, SEC_LEVEL_GREEN, SEC_LEVEL_BLUE)
	SSsecurity_level.set_level(new_level)
	if(SSsecurity_level.get_current_level_as_number() != old_level)
		//Only notify the admins if an actual change happened
		log_game("[key_name(usr)] has changed the security level to [SSsecurity_level.get_current_level_as_text()].")
		message_admins("[key_name_admin(usr)] has changed the security level to [SSsecurity_level.get_current_level_as_text()].")
	if(new_level == SEC_LEVEL_EPSILON)
		// episilon is delayed... but we still want to log it
		log_game("[key_name(usr)] has changed the security level to epsilon.")
		message_admins("[key_name_admin(usr)] has changed the security level to epsilon.")

/obj/machinery/computer/communications/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!is_secure_level(z))
		to_chat(ui.user, "<span class='warning'>Unable to establish a connection: You're too far away from the station!</span>")
		return

	. = TRUE

	if(action == "auth")
		if(!ishuman(ui.user))
			to_chat(ui.user, "<span class='warning'>Access denied, no humanoid lifesign detected.</span>")
			return FALSE
		// Logout function.
		if(authenticated != COMM_AUTHENTICATION_NONE)
			authenticated = COMM_AUTHENTICATION_NONE
			announcer.author = null
			setMenuState(ui.user, COMM_SCREEN_MAIN)
			return
		// Login function.
		var/list/access = ui.user.get_access()
		if(allowed(ui.user))
			authenticated = COMM_AUTHENTICATION_HEAD
		if(ACCESS_CAPTAIN in access)
			authenticated = COMM_AUTHENTICATION_CAPT
		if(ACCESS_CENT_COMMANDER in access)
			if(!check_rights(R_ADMIN|R_EVENT, FALSE, ui.user, all = TRUE))
				to_chat(ui.user, "<span class='warning'>[src] buzzes, invalid central command clearance.</span>")
				return
			authenticated = COMM_AUTHENTICATION_CENTCOM

		if(authenticated >= COMM_AUTHENTICATION_CAPT)
			var/mob/living/carbon/human/H = ui.user
			if(!istype(H))
				return
			var/obj/item/card/id = H.get_idcard(TRUE)
			if(istype(id))
				announcer.author = GetNameAndAssignmentFromId(id)
		if(authenticated == COMM_AUTHENTICATION_NONE)
			to_chat(ui.user, "<span class='warning'>You need to wear a command or Captain-level ID.</span>")
		return

	// All functions below this point require authentication.
	if(!is_authenticated(ui.user))
		return FALSE

	switch(action)
		if("main")
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("newalertlevel")
			if(is_ai(ui.user) || isrobot(ui.user))
				to_chat(ui.user, "<span class='warning'>Firewalls prevent you from changing the alert level.</span>")
				return
			else if(ADMIN_CHECK(ui.user))
				change_security_level(text2num(params["level"]), force = TRUE)
				return
			else if(!ishuman(ui.user))
				to_chat(ui.user, "<span class='warning'>Security measures prevent you from changing the alert level.</span>")
				return
			else if(alert_level_cooldown > world.time)
				to_chat(ui.user, "<span class='warning'>Please allow at least one minute between manual changes to the alert level.</span>")
				return

			alert_level_cooldown = world.time + 60 SECONDS
			var/mob/living/carbon/human/H = ui.user
			var/obj/item/card/id/I = H.get_idcard(TRUE)
			if(istype(I))
				// You must have captain access and it must be red alert or lower (no getting off delta/epsilon)
				if((ACCESS_CAPTAIN in I.access) && SSsecurity_level.get_current_level_as_number() <= SEC_LEVEL_RED)
					change_security_level(text2num(params["level"]))
				else
					to_chat(ui.user, "<span class='warning'>You are not authorized to do this.</span>")
				setMenuState(ui.user, COMM_SCREEN_MAIN)
			else
				to_chat(ui.user, "<span class='warning'>You need to wear your ID.</span>")

		if("announce")
			if(is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT)
				if(message_cooldown > world.time)
					to_chat(ui.user, "<span class='warning'>Please allow at least one minute to pass between announcements.</span>")
					return
				var/input = input(ui.user, "Please write a message to announce to the station crew.", "Priority Announcement") as null|message
				if(!input || message_cooldown > world.time || ..() || !(is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT))
					return
				if(length(input) < COMM_MSGLEN_MINIMUM)
					to_chat(ui.user, "<span class='warning'>Message '[input]' is too short. [COMM_MSGLEN_MINIMUM] character minimum.</span>")
					return
				announcer.Announce(input)
				message_cooldown = world.time + 600 //One minute

		if("callshuttle")
			var/input = input("Please enter the reason for calling the shuttle.", "Shuttle Call Reason.") as null|message
			if(!input || ..() || !is_authenticated(ui.user))
				return
			call_shuttle_proc(ui.user, input)
			if(SSshuttle.emergency.timer)
				post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("cancelshuttle")
			if(is_ai(ui.user) || isrobot(ui.user))
				to_chat(ui.user, "<span class='warning'>Firewalls prevent you from recalling the shuttle.</span>")
				return
			var/response = tgui_alert(usr, "Are you sure you wish to recall the shuttle?", "Confirm", list("Yes", "No"))
			if(response == "Yes")
				cancel_call_proc(ui.user)
				if(SSshuttle.emergency.timer)
					post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("messagelist")
			currmsg = null
			aicurrmsg = null
			if(params["msgid"])
				setCurrentMessage(ui.user, text2num(params["msgid"]))
			setMenuState(ui.user, COMM_SCREEN_MESSAGES)

		if("delmessage")
			if(params["msgid"])
				currmsg = text2num(params["msgid"])
			if(currmsg)
				var/id = getCurrentMessage()
				var/title = messagetitle[id]
				var/text  = messagetext[id]
				messagetitle.Remove(title)
				messagetext.Remove(text)
				if(currmsg == id)
					currmsg = null
				if(aicurrmsg == id)
					aicurrmsg = null
			setMenuState(ui.user, COMM_SCREEN_MESSAGES)

		if("status")
			setMenuState(ui.user, COMM_SCREEN_STAT)

		// Status display stuff
		if("setstat")
			display_type = text2num(params["statdisp"])
			switch(display_type)
				if(STATUS_DISPLAY_MESSAGE)
					display_icon = null
					post_status(STATUS_DISPLAY_MESSAGE, stat_msg1, stat_msg2)
				if(STATUS_DISPLAY_ALERT)
					display_icon = params["alert"]
					post_status(STATUS_DISPLAY_ALERT, params["alert"])
				else
					display_icon = null
					post_status(display_type)
			setMenuState(ui.user, COMM_SCREEN_STAT)

		if("setmsg1")
			stat_msg1 = tgui_input_text(ui.user, "Line 1", stat_msg1, "Enter Message Text", encode = FALSE)
			setMenuState(ui.user, COMM_SCREEN_STAT)

		if("setmsg2")
			stat_msg2 = tgui_input_text(ui.user, "Line 2", stat_msg2, "Enter Message Text", encode = FALSE)
			setMenuState(ui.user, COMM_SCREEN_STAT)

		if("nukerequest")
			if(is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT)
				if(centcomm_message_cooldown > world.time)
					to_chat(ui.user, "<span class='warning'>Arrays recycling. Please stand by.</span>")
					return
				var/input = tgui_input_text(ui.user, "Please enter the reason for requesting the nuclear self-destruct codes. Misuse of the nuclear request system will not be tolerated under any circumstances. Transmission does not guarantee a response.", "Self Destruct Code Request.", encode = FALSE)
				if(isnull(input) || ..() || !(is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(ui.user, "<span class='warning'>Message '[input]' is too short. [COMM_CCMSGLEN_MINIMUM] character minimum.</span>")
					return
				Nuke_request(input, ui.user)
				to_chat(ui.user, "<span class='notice'>Request sent.</span>")
				log_game("[key_name(ui.user)] has requested the nuclear codes from Centcomm")
				GLOB.major_announcement.Announce("The codes for the on-station nuclear self-destruction device have been requested by [ui.user]. Confirmation or denial of this request will be sent shortly.", "Nuclear Self Destruct Codes Requested", 'sound/AI/nuke_codes.ogg')
				centcomm_message_cooldown = world.time + 6000 // 10 minutes
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("MessageCentcomm")
			if(is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT)
				if(centcomm_message_cooldown > world.time)
					to_chat(ui.user, "<span class='warning'>Arrays recycling. Please stand by.</span>")
					return
				var/input = tgui_input_text(ui.user, "Please choose a message to transmit to Centcomm via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "CentComm Message", encode = FALSE)
				if(!input || ..() || !(is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(ui.user, "<span class='warning'>Message '[input]' is too short. [COMM_CCMSGLEN_MINIMUM] character minimum.</span>")
					return
				Centcomm_announce(input, ui.user)
				print_centcom_report(input, station_time_timestamp() + " Captain's Message")
				to_chat(ui.user, "Message transmitted.")
				log_game("[key_name(ui.user)] has made a Centcomm announcement: [input]")
				centcomm_message_cooldown = world.time + 6000 // 10 minutes
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT) && (src.emagged))
				if(centcomm_message_cooldown > world.time)
					to_chat(ui.user, "Arrays recycling.  Please stand by.")
					return
				var/input = tgui_input_text(ui.user, "Please choose a message to transmit to \[ABNORMAL ROUTING CORDINATES\] via quantum entanglement. Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "Send Message", encode = FALSE)
				if(!input || ..() || !(is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(ui.user, "<span class='warning'>Message '[input]' is too short. [COMM_CCMSGLEN_MINIMUM] character minimum.</span>")
					return
				Syndicate_announce(input, ui.user)
				to_chat(ui.user, "Message transmitted.")
				log_game("[key_name(ui.user)] has made a Syndicate announcement: [input]")
				centcomm_message_cooldown = world.time + 6000 // 10 minutes
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("RestoreBackup")
			to_chat(ui.user, "Backup routing data restored!")
			emagged = FALSE
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		// ADMIN CENTCOMM ONLY STUFF
		if("send_to_cc_announcement_page")
			if(!ADMIN_CHECK(ui.user))
				return
			setMenuState(ui.user, COMM_SCREEN_ANNOUNCER)

		if("make_other_announcement")
			if(!ADMIN_CHECK(ui.user))
				return
			ui.user.client.cmd_admin_create_centcom_report()

		if("dispatch_ert")
			if(!ADMIN_CHECK(ui.user))
				return
			ui.user.client.response_team() // check_rights is handled on the other side, if someone does get ahold of this

		if("send_nuke_codes")
			if(!ADMIN_CHECK(ui.user))
				return
			print_nuke_codes()

		if("move_gamma_armory")
			if(!ADMIN_CHECK(ui.user))
				return
			SSblackbox.record_feedback("tally", "admin_comms_console", 1, "Send Gamma Armory")
			log_and_message_admins("moved the gamma armory")
			move_gamma_ship()

		if("test_sound")
			if(!ADMIN_CHECK(ui.user))
				return
			SEND_SOUND(ui.user, sound(cc_announcement_sounds[params["sound"]]))

		if("toggle_ert_allowed")
			if(!ADMIN_CHECK(ui.user))
				return
			ui.user.client.toggle_ert_calling()

		if("view_econ")
			if(!ADMIN_CHECK(ui.user))
				return
			ui.user.client.economy_manager()

		if("view_fax")
			if(!ADMIN_CHECK(ui.user))
				return
			ui.user.client.fax_panel()

		if("make_cc_announcement")
			if(!ADMIN_CHECK(ui.user))
				return
			if(params["classified"] != 1) // this uses 1/0 on the js side instead of "true" or "false"
				GLOB.major_announcement.Announce(
					params["text"],
					new_title = "Central Command Report",
					new_subtitle = params["subtitle"],
					new_sound = cc_announcement_sounds[params["beepsound"]]
				)
				print_command_report(params["text"], params["subtitle"])
			else
				GLOB.command_announcer.autosay("A classified message has been printed out at all communication consoles.")
				print_command_report(params["text"], "Classified: [params["subtitle"]]")

			log_and_message_admins("has created a communications report: [params["text"]]")
			// Okay but this is just an IC way of accessing the same verb
			SSblackbox.record_feedback("tally", "admin_comms_console", 1, "Create CC Report") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/machinery/computer/communications/proc/print_nuke_codes()
	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
	var/obj/item/paper/P = new /obj/item/paper(get_turf(src))
	P.name = "'CONFIDENTIAL' - [station_name()] Nuclear Codes"
	P.info = "<center>&ZeroWidthSpace;<img src='ntlogo.png'><br><b>CONFIDENTIAL</b></center><br><hr>"

	P.info += "The nuclear codes to [station_name()]'s nuclear device are [get_nuke_code()].<br>"
	switch(get_nuke_status())
		if(NUKE_MISSING)
			P.info += "Long-range scanners cannot detect the nuclear device on-station."
		if(NUKE_CORE_MISSING)
			P.info += "Long-range scanners detect no radioactive signatures from inside the device."

	P.info += "<br><hr><font size=\"1\">Failure to comply with company regulatory confidential guidelines may result in immediate termination, at the jurisdiction of Central Command staff.</font>"


/obj/machinery/computer/communications/emag_act(user as mob)
	if(!emagged)
		emagged = TRUE
		to_chat(user, "<span class='notice'>You scramble the communication routing circuits!</span>")
		SStgui.update_uis(src)
		return TRUE

/obj/machinery/computer/communications/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/communications/attack_hand(mob/user as mob)
	if(..(user))
		return

	if(stat & (NOPOWER|BROKEN))
		return

	if(!is_secure_level(src.z))
		to_chat(user, "<span class='warning'>Unable to establish a connection: You're too far away from the station!</span>")
		return

	ui_interact(user)

/obj/machinery/computer/communications/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/communications/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CommunicationsComputer",  name)
		ui.open()

/obj/machinery/computer/communications/ui_data(mob/user)
	var/list/data = list()
	data["is_ai"]         = is_ai(user) || isrobot(user)
	data["noauthbutton"]  = !ishuman(user)
	data["menu_state"]    = data["is_ai"] ? ai_menu_state : menu_state
	data["emagged"]       = emagged
	data["authenticated"] = is_authenticated(user, 0)
	data["authhead"] = data["authenticated"] >= COMM_AUTHENTICATION_HEAD && (data["authenticated"] == COMM_AUTHENTICATION_AGHOST || !isobserver(user))
	data["authcapt"] = data["authenticated"] >= COMM_AUTHENTICATION_CAPT && (data["authenticated"] == COMM_AUTHENTICATION_AGHOST || !isobserver(user))
	data["is_admin"] = data["authenticated"] >= COMM_AUTHENTICATION_CENTCOM && (data["authenticated"] == COMM_AUTHENTICATION_AGHOST || !isobserver(user))

	data["gamma_armory_location"] = GLOB.gamma_ship_location
	data["ert_allowed"] = !SSticker.mode.ert_disabled

	data["stat_display"] =  list(
		"type"   = display_type,
		"icon"   = display_icon,
		"line_1" = (stat_msg1 ? stat_msg1 : "-----"),
		"line_2" = (stat_msg2 ? stat_msg2 : "-----"),

		"presets" = list(
			list("name" = STATUS_DISPLAY_BLANK,    "label" = "Clear",       "desc" = "Blank slate"),
			list("name" = STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME,  "label" = "Shuttle ETA", "desc" = "Display how much time is left."),
			list("name" = STATUS_DISPLAY_MESSAGE,  "label" = "Message",     "desc" = "A custom message.")
		),

		"alerts"=list(
			list("alert" = "default",   "label" = "Nanotrasen",  "desc" = "Oh god."),
			list("alert" = "redalert",  "label" = "Red Alert",   "desc" = "Nothing to do with communists."),
			list("alert" = "lockdown",  "label" = "Lockdown",    "desc" = "Let everyone know they're on lockdown."),
			list("alert" = "biohazard", "label" = "Biohazard",   "desc" = "Great for virus outbreaks and parties."),
		)
	)

	data["security_level"] = SSsecurity_level.get_current_level_as_number()
	switch(SSsecurity_level.get_current_level_as_number())
		if(SEC_LEVEL_GREEN)
			data["security_level_color"] = "green";
		if(SEC_LEVEL_BLUE)
			data["security_level_color"] = "blue";
		if(SEC_LEVEL_RED)
			data["security_level_color"] = "red";
		else
			data["security_level_color"] = "purple";
	data["str_security_level"] = capitalize(SSsecurity_level.get_current_level_as_text())

	var/list/msg_data = list()
	for(var/i = 1; i <= length(messagetext); i++)
		msg_data.Add(list(list("title" = messagetitle[i], "body" = messagetext[i], "id" = i)))

	data["messages"]        = msg_data

	data["current_message"] = null
	data["current_message_title"] = null
	if((data["is_ai"] && aicurrmsg) || (!data["is_ai"] && currmsg))
		data["current_message"] = data["is_ai"] ? messagetext[aicurrmsg] : messagetext[currmsg]
		data["current_message_title"] = data["is_ai"] ? messagetitle[aicurrmsg] : messagetitle[currmsg]

	data["lastCallLoc"]     = SSshuttle.emergencyLastCallLoc ? format_text(SSshuttle.emergencyLastCallLoc.name) : null
	data["msg_cooldown"] = message_cooldown ? (round((message_cooldown - world.time) / 10)) : 0
	data["cc_cooldown"] = centcomm_message_cooldown ? (round((centcomm_message_cooldown - world.time) / 10)) : 0

	var/secondsToRefuel = SSshuttle.secondsToRefuel()
	data["esc_callable"] = SSshuttle.emergency.mode == SHUTTLE_IDLE && !secondsToRefuel ? TRUE : FALSE
	data["esc_recallable"] = SSshuttle.emergency.mode == SHUTTLE_CALL ? TRUE : FALSE
	data["esc_status"] = FALSE
	if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
		var/timeleft = SSshuttle.emergency.timeLeft()
		data["esc_status"] = SSshuttle.emergency.mode == SHUTTLE_CALL ? "ETA:" : "RECALLING:"
		data["esc_status"] += " [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]"
	else if(secondsToRefuel)
		data["esc_status"] = "Refueling: [secondsToRefuel / 60 % 60]:[add_zero(num2text(secondsToRefuel % 60), 2)]"
	data["esc_section"] = data["esc_status"] || data["esc_callable"] || data["esc_recallable"] || data["lastCallLoc"]
	return data

/obj/machinery/computer/communications/ui_static_data(mob/user)
	var/list/data = list()

	data["levels"] = list(
		list("id" = SEC_LEVEL_GREEN, "name" = "Green", "icon" = "dove"),
		list("id" = SEC_LEVEL_BLUE,  "name" = "Blue", "icon" = "eye"),
	)

	data["admin_levels"] = list(
		list("id" = SEC_LEVEL_RED, "name" = "Red", "icon" = "exclamation"),
		list("id" = SEC_LEVEL_GAMMA,  "name" = "Gamma", "icon" = "biohazard"),
		list("id" = SEC_LEVEL_EPSILON, "name" = "Epsilon", "icon" = "skull", "tooltip" = "Epsilon Alert will only activate after 15 or so seconds."),
		list("id" = SEC_LEVEL_DELTA,  "name" = "Delta", "icon" = "bomb"),
	)

	var/list/keys = list()
	for(var/sound_name in cc_announcement_sounds)
		keys += sound_name

	data["possible_cc_sounds"] = keys

	return data

/obj/machinery/computer/communications/proc/setCurrentMessage(mob/user, value)
	if(is_ai(user) || isrobot(user))
		aicurrmsg = value
	else
		currmsg = value

/obj/machinery/computer/communications/proc/getCurrentMessage(mob/user)
	if(is_ai(user) || isrobot(user))
		return aicurrmsg
	else
		return currmsg

/obj/machinery/computer/communications/proc/setMenuState(mob/user, value)
	if(is_ai(user) || isrobot(user))
		ai_menu_state=value
	else
		menu_state=value

/proc/call_shuttle_proc(mob/user, reason, sanitized = FALSE)
	if(GLOB.deathsquad_sent)
		to_chat(user, "<span class='warning'>Central Command does not allow the shuttle to be called at this time. Please stand by.</span>") //This may show up before Epsilon Alert/Before DS arrives
		return

	if(length(SSshuttle.hostile_environments))
		to_chat(user, "<span class='warning'>The emergency shuttle may not be sent at this time. Please try again later.</span>")
		return

	if(SSshuttle.emergency.mode > SHUTTLE_ESCAPE)
		to_chat(user, "<span class='warning'>The emergency shuttle may not be called while returning to Central Command.</span>")
		return

	if(SSticker.mode.name == "blob")
		to_chat(user, "<span class='warning'>Under directive 7-10, [station_name()] is quarantined until further notice.</span>")
		return

	if(!sanitized)
		reason = trim_strip_html_tags(reason, allow_lines = TRUE)

	SSshuttle.requestEvac(user, reason)
	log_game("[key_name(user)] has called the shuttle.")
	message_admins("[key_name_admin(user)] has called the shuttle.", 1)

	return

/proc/init_shift_change(mob/user, force = 0)
	// if force is 0, some things may stop the shuttle call
	if(!force)
		if(length(SSshuttle.hostile_environments))
			to_chat(user, "Central Command does not currently have a shuttle available in your sector. Please try again later.")
			return

		if(GLOB.deathsquad_sent)
			to_chat(user, "<span class='warning'>Central Command does not allow the shuttle to be called at this time. Please stand by.</span>") //This may show up before Epsilon Alert/Before DS arrives
			return

		// AA 2022-08-18 - Why is this not a round time offset??
		if(world.time < 54000) // 30 minute grace period to let the game get going
			to_chat(user, "The shuttle is refueling. Please wait another [round((54000-world.time)/600)] minutes before trying again.")
			return

		if(SSticker.mode.name == "epidemic")
			to_chat(user, "Under directive 7-10, [station_name()] is quarantined until further notice.")
			return

	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED) // There is a serious threat we gotta move no time to give them five minutes.
		SSshuttle.emergency.canRecall = FALSE
		SSshuttle.emergency.request(null, 0.5, null, " Automatic Crew Transfer", 1)
	else
		SSshuttle.emergency.canRecall = FALSE
		SSshuttle.emergency.request(null, 1, null, " Automatic Crew Transfer", 0)
	if(user)
		log_game("[key_name(user)] has called the shuttle.")
		message_admins("[key_name_admin(user)] has called the shuttle - [formatJumpTo(user)].", 1)
	return

// Why the hell are all these procs global?
/proc/cancel_call_proc(mob/user)
	if(SSshuttle.cancelEvac(user))
		log_game("[key_name(user)] has recalled the shuttle.")
		message_admins("[key_name_admin(user)] has recalled the shuttle - ([ADMIN_FLW(user,"FLW")]).", 1)
	else
		to_chat(user, "<span class='warning'>Central Command has refused the recall request!</span>")
		log_game("[key_name(user)] has tried and failed to recall the shuttle.")
		message_admins("[key_name_admin(user)] has tried and failed to recall the shuttle - ([ADMIN_FLW(user,"FLW")]).", 1)


/obj/machinery/computer/communications/Destroy()
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	return ..()

/obj/item/circuitboard/communications/New()
	GLOB.shuttle_caller_list += src
	..()

/obj/item/circuitboard/communications/Destroy()
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	return ..()

/proc/print_command_report(text = "", title = "Central Command Update", add_to_records = TRUE)
	for(var/obj/machinery/computer/communications/C in GLOB.shuttle_caller_list)
		if(!(C.stat & (BROKEN|NOPOWER)) && is_station_contact(C.z))
			var/obj/item/paper/P = new /obj/item/paper(C.loc)
			P.name = "paper- '[title]'"
			P.info = text
			P.update_icon()
			if(add_to_records)
				C.messagetitle.Add("[title]")
				C.messagetext.Add(text)

/proc/print_centcom_report(text = "", title = "Incoming Message")
	for(var/obj/machinery/computer/communications/C in GLOB.shuttle_caller_list)
		if(!(C.stat & (BROKEN|NOPOWER)) && is_admin_level(C.z))
			var/obj/item/paper/P = new /obj/item/paper(C.loc)
			P.name = "paper- '[title]'"
			P.info = text
			P.update_icon()
			C.messagetitle.Add("[title]")
			C.messagetext.Add(text)

#undef ADMIN_CHECK

#undef COMM_SCREEN_MAIN
#undef COMM_SCREEN_STAT
#undef COMM_SCREEN_MESSAGES
#undef COMM_SCREEN_ANNOUNCER
#undef COMM_AUTHENTICATION_NONE
#undef COMM_AUTHENTICATION_HEAD
#undef COMM_AUTHENTICATION_CAPT
#undef COMM_AUTHENTICATION_CENTCOM
#undef COMM_AUTHENTICATION_AGHOST
#undef COMM_MSGLEN_MINIMUM
#undef COMM_CCMSGLEN_MINIMUM
