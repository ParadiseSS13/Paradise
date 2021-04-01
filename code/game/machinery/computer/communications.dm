#define COMM_SCREEN_MAIN		1
#define COMM_SCREEN_STAT		2
#define COMM_SCREEN_MESSAGES	3

#define COMM_AUTHENTICATION_NONE	0
#define COMM_AUTHENTICATION_HEAD	1
#define COMM_AUTHENTICATION_CAPT	2
#define COMM_AUTHENTICATION_AGHOST	3

#define COMM_MSGLEN_MINIMUM 6
#define COMM_CCMSGLEN_MINIMUM 20

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
	var/tmp_alertlevel = 0

	var/stat_msg1
	var/stat_msg2
	var/display_type = "blank"
	var/display_icon

	var/datum/announcement/priority/crew_announcement = new

	light_color = LIGHT_COLOR_LIGHTBLUE

/obj/machinery/computer/communications/New()
	GLOB.shuttle_caller_list += src
	..()
	crew_announcement.newscast = 0

/obj/machinery/computer/communications/proc/is_authenticated(mob/user, message = 1)
	if(user.can_admin_interact())
		return COMM_AUTHENTICATION_AGHOST
	if(authenticated == COMM_AUTHENTICATION_CAPT)
		return COMM_AUTHENTICATION_CAPT
	if(authenticated)
		return COMM_AUTHENTICATION_HEAD
	if(message)
		to_chat(user, "<span class='warning'>Access denied.</span>")
	return COMM_AUTHENTICATION_NONE

/obj/machinery/computer/communications/proc/change_security_level(new_level)
	tmp_alertlevel = new_level
	var/old_level = GLOB.security_level
	if(!tmp_alertlevel) tmp_alertlevel = SEC_LEVEL_GREEN
	if(tmp_alertlevel < SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN
	if(tmp_alertlevel > SEC_LEVEL_BLUE) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
	set_security_level(tmp_alertlevel)
	if(GLOB.security_level != old_level)
		//Only notify the admins if an actual change happened
		log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
		message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
	tmp_alertlevel = 0

/obj/machinery/computer/communications/ui_act(action, params)
	if(..())
		return
	if(!is_secure_level(z))
		to_chat(usr, "<span class='warning'>Unable to establish a connection: You're too far away from the station!</span>")
		return

	. = TRUE

	if(action == "auth")
		if(!ishuman(usr))
			to_chat(usr, "<span class='warning'>Access denied, no humanoid lifesign detected.</span>")
			return FALSE
		// Logout function.
		if(authenticated != COMM_AUTHENTICATION_NONE)
			authenticated = COMM_AUTHENTICATION_NONE
			crew_announcement.announcer = null
			setMenuState(usr, COMM_SCREEN_MAIN)
			return
		// Login function.
		var/list/access = usr.get_access()
		if(allowed(usr))
			authenticated = COMM_AUTHENTICATION_HEAD
		if(ACCESS_CAPTAIN in access)
			authenticated = COMM_AUTHENTICATION_CAPT
			var/mob/living/carbon/human/H = usr
			var/obj/item/card/id = H.get_idcard(TRUE)
			if(istype(id))
				crew_announcement.announcer = GetNameAndAssignmentFromId(id)
		if(authenticated == COMM_AUTHENTICATION_NONE)
			to_chat(usr, "<span class='warning'>You need to wear a command or Captain-level ID.</span>")
		return

	// All functions below this point require authentication.
	if(!is_authenticated(usr))
		return FALSE

	switch(action)
		if("main")
			setMenuState(usr, COMM_SCREEN_MAIN)

		if("newalertlevel")
			if(isAI(usr) || isrobot(usr))
				to_chat(usr, "<span class='warning'>Firewalls prevent you from changing the alert level.</span>")
				return
			else if(usr.can_admin_interact())
				change_security_level(text2num(params["level"]))
				return
			else if(!ishuman(usr))
				to_chat(usr, "<span class='warning'>Security measures prevent you from changing the alert level.</span>")
				return

			var/mob/living/carbon/human/H = usr
			var/obj/item/card/id/I = H.get_idcard(TRUE)
			if(istype(I))
				if(ACCESS_HEADS in I.access)
					change_security_level(text2num(params["level"]))
				else
					to_chat(usr, "<span class='warning'>You are not authorized to do this.</span>")
				setMenuState(usr, COMM_SCREEN_MAIN)
			else
				to_chat(usr, "<span class='warning'>You need to wear your ID.</span>")

		if("announce")
			if(is_authenticated(usr) >= COMM_AUTHENTICATION_CAPT)
				if(message_cooldown > world.time)
					to_chat(usr, "<span class='warning'>Please allow at least one minute to pass between announcements.</span>")
					return
				var/input = input(usr, "Please write a message to announce to the station crew.", "Priority Announcement") as null|message
				if(!input || message_cooldown > world.time || ..() || !(is_authenticated(usr) >= COMM_AUTHENTICATION_CAPT))
					return
				if(length(input) < COMM_MSGLEN_MINIMUM)
					to_chat(usr, "<span class='warning'>Message '[input]' is too short. [COMM_MSGLEN_MINIMUM] character minimum.</span>")
					return
				crew_announcement.Announce(input)
				message_cooldown = world.time + 600 //One minute

		if("callshuttle")
			var/input = clean_input("Please enter the reason for calling the shuttle.", "Shuttle Call Reason.","")
			if(!input || ..() || !is_authenticated(usr))
				return
			call_shuttle_proc(usr, input)
			if(SSshuttle.emergency.timer)
				post_status("shuttle")
			setMenuState(usr, COMM_SCREEN_MAIN)

		if("cancelshuttle")
			if(isAI(usr) || isrobot(usr))
				to_chat(usr, "<span class='warning'>Firewalls prevent you from recalling the shuttle.</span>")
				return
			var/response = alert("Are you sure you wish to recall the shuttle?", "Confirm", "Yes", "No")
			if(response == "Yes")
				cancel_call_proc(usr)
				if(SSshuttle.emergency.timer)
					post_status("shuttle")
			setMenuState(usr, COMM_SCREEN_MAIN)

		if("messagelist")
			currmsg = null
			aicurrmsg = null
			if(params["msgid"])
				setCurrentMessage(usr, text2num(params["msgid"]))
			setMenuState(usr, COMM_SCREEN_MESSAGES)

		if("delmessage")
			if(params["msgid"])
				currmsg = text2num(params["msgid"])
			var/response = alert("Are you sure you wish to delete this message?", "Confirm", "Yes", "No")
			if(response == "Yes")
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
			setMenuState(usr, COMM_SCREEN_MESSAGES)

		if("status")
			setMenuState(usr, COMM_SCREEN_STAT)

		// Status display stuff
		if("setstat")
			display_type = params["statdisp"]
			switch(display_type)
				if("message")
					display_icon = null
					post_status("message", stat_msg1, stat_msg2, usr)
				if("alert")
					display_icon = params["alert"]
					post_status("alert", params["alert"], user = usr)
				else
					display_icon = null
					post_status(params["statdisp"], user = usr)
			setMenuState(usr, COMM_SCREEN_STAT)

		if("setmsg1")
			stat_msg1 = clean_input("Line 1", "Enter Message Text", stat_msg1)
			setMenuState(usr, COMM_SCREEN_STAT)

		if("setmsg2")
			stat_msg2 = clean_input("Line 2", "Enter Message Text", stat_msg2)
			setMenuState(usr, COMM_SCREEN_STAT)

		if("nukerequest")
			if(is_authenticated(usr) >= COMM_AUTHENTICATION_CAPT)
				if(centcomm_message_cooldown > world.time)
					to_chat(usr, "<span class='warning'>Arrays recycling. Please stand by.</span>")
					return
				var/input = stripped_input(usr, "Please enter the reason for requesting the nuclear self-destruct codes. Misuse of the nuclear request system will not be tolerated under any circumstances.  Transmission does not guarantee a response.", "Self Destruct Code Request.","")
				if(!input || ..() || !(is_authenticated(usr) >= COMM_AUTHENTICATION_CAPT))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(usr, "<span class='warning'>Message '[input]' is too short. [COMM_CCMSGLEN_MINIMUM] character minimum.</span>")
					return
				Nuke_request(input, usr)
				to_chat(usr, "<span class='notice'>Request sent.</span>")
				log_game("[key_name(usr)] has requested the nuclear codes from Centcomm")
				GLOB.priority_announcement.Announce("The codes for the on-station nuclear self-destruct have been requested by [usr]. Confirmation or denial of this request will be sent shortly.", "Nuclear Self Destruct Codes Requested",'sound/AI/commandreport.ogg')
				centcomm_message_cooldown = world.time + 6000 // 10 minutes
			setMenuState(usr, COMM_SCREEN_MAIN)

		if("MessageCentcomm")
			if(is_authenticated(usr) >= COMM_AUTHENTICATION_CAPT)
				if(centcomm_message_cooldown > world.time)
					to_chat(usr, "<span class='warning'>Arrays recycling. Please stand by.</span>")
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to Centcomm via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response.", "To abort, send an empty message.", "")
				if(!input || ..() || !(is_authenticated(usr) >= COMM_AUTHENTICATION_CAPT))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(usr, "<span class='warning'>Message '[input]' is too short. [COMM_CCMSGLEN_MINIMUM] character minimum.</span>")
					return
				Centcomm_announce(input, usr)
				print_centcom_report(input, station_time_timestamp() + " Captain's Message")
				to_chat(usr, "Message transmitted.")
				log_game("[key_name(usr)] has made a Centcomm announcement: [input]")
				centcomm_message_cooldown = world.time + 6000 // 10 minutes
			setMenuState(usr, COMM_SCREEN_MAIN)

		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((is_authenticated(usr) >= COMM_AUTHENTICATION_CAPT) && (src.emagged))
				if(centcomm_message_cooldown > world.time)
					to_chat(usr, "Arrays recycling.  Please stand by.")
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING CORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "To abort, send an empty message.", "")
				if(!input || ..() || !(is_authenticated(usr) >= COMM_AUTHENTICATION_CAPT))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(usr, "<span class='warning'>Message '[input]' is too short. [COMM_CCMSGLEN_MINIMUM] character minimum.</span>")
					return
				Syndicate_announce(input, usr)
				to_chat(usr, "Message transmitted.")
				log_game("[key_name(usr)] has made a Syndicate announcement: [input]")
				centcomm_message_cooldown = world.time + 6000 // 10 minutes
			setMenuState(usr, COMM_SCREEN_MAIN)

		if("RestoreBackup")
			to_chat(usr, "Backup routing data restored!")
			src.emagged = 0
			setMenuState(usr, COMM_SCREEN_MAIN)

		if("RestartNanoMob")
			if(SSmob_hunt)
				if(SSmob_hunt.manual_reboot())
					var/loading_msg = pick("Respawning spawns", "Reticulating splines", "Flipping hat",
										"Capturing all of them", "Fixing minor text issues", "Being the very best",
										"Nerfing this", "Not communicating with playerbase", "Coding a ripoff in a 2D spaceman game")
					to_chat(usr, "<span class='notice'>Restarting Nano-Mob Hunter GO! game server. [loading_msg]...</span>")
				else
					to_chat(usr, "<span class='warning'>Nano-Mob Hunter GO! game server reboot failed due to recent restart. Please wait before re-attempting.</span>")
			else
				to_chat(usr, "<span class='danger'>Nano-Mob Hunter GO! game server is offline for extended maintenance. Contact your Central Command administrators for more info if desired.</span>")



/obj/machinery/computer/communications/emag_act(user as mob)
	if(!emagged)
		src.emagged = 1
		to_chat(user, "<span class='notice'>You scramble the communication routing circuits!</span>")
		SStgui.update_uis(src)

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

/obj/machinery/computer/communications/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "CommunicationsComputer",  name, 500, 600, master_ui, state)
		ui.open()

/obj/machinery/computer/communications/ui_data(mob/user)
	var/list/data = list()
	data["is_ai"]         = isAI(user) || isrobot(user)
	data["noauthbutton"]  = !ishuman(user)
	data["menu_state"]    = data["is_ai"] ? ai_menu_state : menu_state
	data["emagged"]       = emagged
	data["authenticated"] = is_authenticated(user, 0)
	data["authhead"] = data["authenticated"] >= COMM_AUTHENTICATION_HEAD && (data["authenticated"] == COMM_AUTHENTICATION_AGHOST || !isobserver(user))
	data["authcapt"] = data["authenticated"] >= COMM_AUTHENTICATION_CAPT && (data["authenticated"] == COMM_AUTHENTICATION_AGHOST || !isobserver(user))

	data["stat_display"] =  list(
		"type"   = display_type,
		"icon"   = display_icon,
		"line_1" = (stat_msg1 ? stat_msg1 : "-----"),
		"line_2" = (stat_msg2 ? stat_msg2 : "-----"),

		"presets" = list(
			list("name" = "blank",    "label" = "Clear",       "desc" = "Blank slate"),
			list("name" = "shuttle",  "label" = "Shuttle ETA", "desc" = "Display how much time is left."),
			list("name" = "message",  "label" = "Message",     "desc" = "A custom message.")
		),

		"alerts"=list(
			list("alert" = "default",   "label" = "Nanotrasen",  "desc" = "Oh god."),
			list("alert" = "redalert",  "label" = "Red Alert",   "desc" = "Nothing to do with communists."),
			list("alert" = "lockdown",  "label" = "Lockdown",    "desc" = "Let everyone know they're on lockdown."),
			list("alert" = "biohazard", "label" = "Biohazard",   "desc" = "Great for virus outbreaks and parties."),
		)
	)

	data["security_level"] = GLOB.security_level
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			data["security_level_color"] = "green";
		if(SEC_LEVEL_BLUE)
			data["security_level_color"] = "blue";
		if(SEC_LEVEL_RED)
			data["security_level_color"] = "red";
		else
			data["security_level_color"] = "purple";
	data["str_security_level"] = capitalize(get_security_level())
	data["levels"] = list(
		list("id" = SEC_LEVEL_GREEN, "name" = "Green", "icon" = "dove"),
		list("id" = SEC_LEVEL_BLUE,  "name" = "Blue", "icon" = "eye"),
	)

	var/list/msg_data = list()
	for(var/i = 1; i <= messagetext.len; i++)
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

/obj/machinery/computer/communications/proc/setCurrentMessage(mob/user, value)
	if(isAI(user) || isrobot(user))
		aicurrmsg = value
	else
		currmsg = value

/obj/machinery/computer/communications/proc/getCurrentMessage(mob/user)
	if(isAI(user) || isrobot(user))
		return aicurrmsg
	else
		return currmsg

/obj/machinery/computer/communications/proc/setMenuState(mob/user, value)
	if(isAI(user) || isrobot(user))
		ai_menu_state=value
	else
		menu_state=value

/proc/call_shuttle_proc(mob/user, reason)
	if(GLOB.sent_strike_team == 1)
		to_chat(user, "<span class='warning'>Central Command will not allow the shuttle to be called. Consider all contracts terminated.</span>")
		return

	if(SSshuttle.emergencyNoEscape)
		to_chat(user, "<span class='warning'>The emergency shuttle may not be sent at this time. Please try again later.</span>")
		return

	if(SSshuttle.emergency.mode > SHUTTLE_ESCAPE)
		to_chat(user, "<span class='warning'>The emergency shuttle may not be called while returning to Central Command.</span>")
		return

	if(SSticker.mode.name == "blob")
		to_chat(user, "<span class='warning'>Under directive 7-10, [station_name()] is quarantined until further notice.</span>")
		return

	SSshuttle.requestEvac(user, reason)
	log_game("[key_name(user)] has called the shuttle.")
	message_admins("[key_name_admin(user)] has called the shuttle.", 1)

	return

/proc/init_shift_change(mob/user, force = 0)
	// if force is 0, some things may stop the shuttle call
	if(!force)
		if(SSshuttle.emergencyNoEscape)
			to_chat(user, "Central Command does not currently have a shuttle available in your sector. Please try again later.")
			return

		if(GLOB.sent_strike_team == 1)
			to_chat(user, "Central Command will not allow the shuttle to be called. Consider all contracts terminated.")
			return

		if(world.time < 54000) // 30 minute grace period to let the game get going
			to_chat(user, "The shuttle is refueling. Please wait another [round((54000-world.time)/600)] minutes before trying again.")
			return

		if(SSticker.mode.name == "epidemic")
			to_chat(user, "Under directive 7-10, [station_name()] is quarantined until further notice.")
			return

	if(seclevel2num(get_security_level()) >= SEC_LEVEL_RED) // There is a serious threat we gotta move no time to give them five minutes.
		SSshuttle.emergency.request(null, 0.5, null, " Automatic Crew Transfer", 1)
		SSshuttle.emergency.canRecall = FALSE
	else
		SSshuttle.emergency.request(null, 1, null, " Automatic Crew Transfer", 0)
		SSshuttle.emergency.canRecall = FALSE
	if(user)
		log_game("[key_name(user)] has called the shuttle.")
		message_admins("[key_name_admin(user)] has called the shuttle - [formatJumpTo(user)].", 1)
	return


/proc/cancel_call_proc(mob/user)
	if(SSticker.mode.name == "meteor")
		return

	if(SSshuttle.cancelEvac(user))
		log_game("[key_name(user)] has recalled the shuttle.")
		message_admins("[key_name_admin(user)] has recalled the shuttle - ([ADMIN_FLW(user,"FLW")]).", 1)
	else
		to_chat(user, "<span class='warning'>Central Command has refused the recall request!</span>")
		log_game("[key_name(user)] has tried and failed to recall the shuttle.")
		message_admins("[key_name_admin(user)] has tried and failed to recall the shuttle - ([ADMIN_FLW(user,"FLW")]).", 1)

/proc/post_status(command, data1, data2, mob/user = null)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(DISPLAY_FREQ)

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
			log_admin("STATUS: [user] set status screen message: [data1] [data2]")
			//message_admins("STATUS: [user] set status screen with [PDA]. Message: [data1] [data2]")
		if("alert")
			status_signal.data["picture_state"] = data1

	spawn(0)
		frequency.post_signal(null, status_signal)


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


