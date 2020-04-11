#define COMM_SCREEN_MAIN		1
#define COMM_SCREEN_STAT		2
#define COMM_SCREEN_MESSAGES	3
#define COMM_SCREEN_SECLEVEL	4

#define COMM_AUTHENTICATION_NONE	0
#define COMM_AUTHENTICATION_MIN		1
#define COMM_AUTHENTICATION_MAX		2

// The communications computer
/obj/machinery/computer/communications
	name = "communications console"
	desc = "This can be used for various important functions. Still under developement."
	icon_keyboard = "tech_key"
	icon_screen = "comm"
	req_access = list(ACCESS_HEADS)
	circuit = /obj/item/circuitboard/communications
	var/prints_intercept = 1
	var/authenticated = COMM_AUTHENTICATION_NONE
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg = 0
	var/aicurrmsg = 0
	var/menu_state = COMM_SCREEN_MAIN
	var/ai_menu_state = COMM_SCREEN_MAIN
	var/message_cooldown = 0
	var/centcomm_message_cooldown = 0
	var/tmp_alertlevel = 0

	var/stat_msg1
	var/stat_msg2
	var/display_type="blank"

	var/datum/announcement/priority/crew_announcement = new

	light_color = LIGHT_COLOR_LIGHTBLUE

/obj/machinery/computer/communications/New()
	GLOB.shuttle_caller_list += src
	..()
	crew_announcement.newscast = 0

/obj/machinery/computer/communications/proc/is_authenticated(var/mob/user, var/message = 1)
	if(authenticated == COMM_AUTHENTICATION_MAX)
		return COMM_AUTHENTICATION_MAX
	else if(user.can_admin_interact())
		return COMM_AUTHENTICATION_MAX
	else if(authenticated)
		return COMM_AUTHENTICATION_MIN
	else
		if(message)
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return COMM_AUTHENTICATION_NONE

/obj/machinery/computer/communications/proc/change_security_level(var/new_level)
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
		switch(GLOB.security_level)
			if(SEC_LEVEL_GREEN)
				feedback_inc("alert_comms_green",1)
			if(SEC_LEVEL_BLUE)
				feedback_inc("alert_comms_blue",1)
	tmp_alertlevel = 0

/obj/machinery/computer/communications/Topic(href, href_list)
	if(..(href, href_list))
		return 1

	if(!is_secure_level(src.z))
		to_chat(usr, "<span class='warning'>Unable to establish a connection: You're too far away from the station!</span>")
		return 1

	if(href_list["login"])
		if(!ishuman(usr))
			to_chat(usr, "<span class='warning'>Access denied.</span>")
			return

		var/list/access = usr.get_access()
		if(allowed(usr))
			authenticated = COMM_AUTHENTICATION_MIN

		if(ACCESS_CAPTAIN in access)
			authenticated = COMM_AUTHENTICATION_MAX
			var/mob/living/carbon/human/H = usr
			var/obj/item/card/id = H.get_idcard(TRUE)
			if(istype(id))
				crew_announcement.announcer = GetNameAndAssignmentFromId(id)

		SSnanoui.update_uis(src)
		return

	if(href_list["logout"])
		authenticated = COMM_AUTHENTICATION_NONE
		crew_announcement.announcer = ""
		setMenuState(usr,COMM_SCREEN_MAIN)
		SSnanoui.update_uis(src)
		return

	if(!is_authenticated(usr))
		return 1

	switch(href_list["operation"])
		if("main")
			setMenuState(usr,COMM_SCREEN_MAIN)

		if("changeseclevel")
			setMenuState(usr,COMM_SCREEN_SECLEVEL)

		if("newalertlevel")
			if(isAI(usr) || isrobot(usr))
				to_chat(usr, "<span class='warning'>Firewalls prevent you from changing the alert level.</span>")
				return 1
			else if(usr.can_admin_interact())
				change_security_level(text2num(href_list["level"]))
				return 1
			else if(!ishuman(usr))
				to_chat(usr, "<span class='warning'>Security measures prevent you from changing the alert level.</span>")
				return 1

			var/mob/living/carbon/human/L = usr
			var/obj/item/card = L.get_active_hand()
			var/obj/item/card/id/I = (card && card.GetID()) || L.wear_id || L.wear_pda
			if(istype(I, /obj/item/pda))
				var/obj/item/pda/pda = I
				I = pda.id
			if(I && istype(I))
				if(ACCESS_CAPTAIN in I.access)
					change_security_level(text2num(href_list["level"]))
				else
					to_chat(usr, "<span class='warning'>You are not authorized to do this.</span>")
				setMenuState(usr,COMM_SCREEN_MAIN)
			else
				to_chat(usr, "<span class='warning'>You need to swipe your ID.</span>")

		if("announce")
			if(is_authenticated(usr) == COMM_AUTHENTICATION_MAX)
				if(message_cooldown)
					to_chat(usr, "<span class='warning'>Please allow at least one minute to pass between announcements.</span>")
					SSnanoui.update_uis(src)
					return
				var/input = input(usr, "Please write a message to announce to the station crew.", "Priority Announcement")
				if(!input || message_cooldown || ..() || !(is_authenticated(usr) == COMM_AUTHENTICATION_MAX))
					SSnanoui.update_uis(src)
					return
				crew_announcement.Announce(input)
				message_cooldown = 1
				spawn(600)//One minute cooldown
					message_cooldown = 0

		if("callshuttle")
			var/input = clean_input("Please enter the reason for calling the shuttle.", "Shuttle Call Reason.","")
			if(!input || ..() || !is_authenticated(usr))
				SSnanoui.update_uis(src)
				return

			call_shuttle_proc(usr, input)
			if(SSshuttle.emergency.timer)
				post_status("shuttle")
			setMenuState(usr,COMM_SCREEN_MAIN)

		if("cancelshuttle")
			if(isAI(usr) || isrobot(usr))
				to_chat(usr, "<span class='warning'>Firewalls prevent you from recalling the shuttle.</span>")
				SSnanoui.update_uis(src)
				return 1
			var/response = alert("Are you sure you wish to recall the shuttle?", "Confirm", "Yes", "No")
			if(response == "Yes")
				cancel_call_proc(usr)
				if(SSshuttle.emergency.timer)
					post_status("shuttle")
			setMenuState(usr,COMM_SCREEN_MAIN)

		if("messagelist")
			currmsg = 0
			if(href_list["msgid"])
				setCurrentMessage(usr, text2num(href_list["msgid"]))
			setMenuState(usr,COMM_SCREEN_MESSAGES)

		if("delmessage")
			if(href_list["msgid"])
				currmsg = text2num(href_list["msgid"])
			var/response = alert("Are you sure you wish to delete this message?", "Confirm", "Yes", "No")
			if(response == "Yes")
				if(currmsg)
					var/id = getCurrentMessage()
					var/title = messagetitle[id]
					var/text  = messagetext[id]
					messagetitle.Remove(title)
					messagetext.Remove(text)
					if(currmsg == id)
						currmsg = 0
					if(aicurrmsg == id)
						aicurrmsg = 0
			setMenuState(usr,COMM_SCREEN_MESSAGES)

		if("status")
			setMenuState(usr,COMM_SCREEN_STAT)

		// Status display stuff
		if("setstat")
			display_type=href_list["statdisp"]
			switch(display_type)
				if("message")
					post_status("message", stat_msg1, stat_msg2, usr)
				if("alert")
					post_status("alert", href_list["alert"], user = usr)
				else
					post_status(href_list["statdisp"], user = usr)
			setMenuState(usr,COMM_SCREEN_STAT)

		if("setmsg1")
			stat_msg1 = clean_input("Line 1", "Enter Message Text", stat_msg1)
			setMenuState(usr,COMM_SCREEN_STAT)

		if("setmsg2")
			stat_msg2 = clean_input("Line 2", "Enter Message Text", stat_msg2)
			setMenuState(usr,COMM_SCREEN_STAT)

		if("nukerequest")
			if(is_authenticated(usr) == COMM_AUTHENTICATION_MAX)
				if(centcomm_message_cooldown)
					to_chat(usr, "<span class='warning'>Arrays recycling. Please stand by.</span>")
					SSnanoui.update_uis(src)
					return
				var/input = stripped_input(usr, "Please enter the reason for requesting the nuclear self-destruct codes. Misuse of the nuclear request system will not be tolerated under any circumstances.  Transmission does not guarantee a response.", "Self Destruct Code Request.","")
				if(!input || ..() || !(is_authenticated(usr) == COMM_AUTHENTICATION_MAX))
					SSnanoui.update_uis(src)
					return
				Nuke_request(input, usr)
				to_chat(usr, "<span class='notice'>Request sent.</span>")
				log_game("[key_name(usr)] has requested the nuclear codes from Centcomm")
				GLOB.priority_announcement.Announce("The codes for the on-station nuclear self-destruct have been requested by [usr]. Confirmation or denial of this request will be sent shortly.", "Nuclear Self Destruct Codes Requested",'sound/AI/commandreport.ogg')
				centcomm_message_cooldown = 1
				spawn(6000)//10 minute cooldown
					centcomm_message_cooldown = 0
			setMenuState(usr,COMM_SCREEN_MAIN)

		if("MessageCentcomm")
			if(is_authenticated(usr) == COMM_AUTHENTICATION_MAX)
				if(centcomm_message_cooldown)
					to_chat(usr, "<span class='warning'>Arrays recycling. Please stand by.</span>")
					SSnanoui.update_uis(src)
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to Centcomm via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response.", "To abort, send an empty message.", "")
				if(!input || ..() || !(is_authenticated(usr) == COMM_AUTHENTICATION_MAX))
					SSnanoui.update_uis(src)
					return
				Centcomm_announce(input, usr)
				print_centcom_report(input, station_time_timestamp() + " Captain's Message")
				to_chat(usr, "Message transmitted.")
				log_game("[key_name(usr)] has made a Centcomm announcement: [input]")
				centcomm_message_cooldown = 1
				spawn(6000)//10 minute cooldown
					centcomm_message_cooldown = 0
			setMenuState(usr,COMM_SCREEN_MAIN)

		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((is_authenticated(usr) == COMM_AUTHENTICATION_MAX) && (src.emagged))
				if(centcomm_message_cooldown)
					to_chat(usr, "Arrays recycling.  Please stand by.")
					SSnanoui.update_uis(src)
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING CORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "To abort, send an empty message.", "")
				if(!input || ..() || !(is_authenticated(usr) == COMM_AUTHENTICATION_MAX))
					SSnanoui.update_uis(src)
					return
				Syndicate_announce(input, usr)
				to_chat(usr, "Message transmitted.")
				log_game("[key_name(usr)] has made a Syndicate announcement: [input]")
				centcomm_message_cooldown = 1
				spawn(6000)//10 minute cooldown
					centcomm_message_cooldown = 0
			setMenuState(usr,COMM_SCREEN_MAIN)

		if("RestoreBackup")
			to_chat(usr, "Backup routing data restored!")
			src.emagged = 0
			setMenuState(usr,COMM_SCREEN_MAIN)

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

		if("ToggleATC")
			GLOB.atc.squelched = !GLOB.atc.squelched
			to_chat(usr, "<span class='notice'>ATC traffic is now: [GLOB.atc.squelched ? "Disabled" : "Enabled"].</span>")

	SSnanoui.update_uis(src)
	return 1

/obj/machinery/computer/communications/emag_act(user as mob)
	if(!emagged)
		src.emagged = 1
		to_chat(user, "<span class='notice'>You scramble the communication routing circuits!</span>")
		SSnanoui.update_uis(src)

/obj/machinery/computer/communications/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/communications/attack_hand(var/mob/user as mob)
	if(..(user))
		return

	if(stat & (NOPOWER|BROKEN))
		return

	if(!is_secure_level(src.z))
		to_chat(user, "<span class='warning'>Unable to establish a connection: You're too far away from the station!</span>")
		return

	ui_interact(user)

/obj/machinery/computer/communications/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "comm_console.tmpl", "Communications Console", 400, 500)
		// open the new ui window
		ui.open()

/obj/machinery/computer/communications/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
	data["is_ai"]         = isAI(user) || isrobot(user)
	data["menu_state"]    = data["is_ai"] ? ai_menu_state : menu_state
	data["emagged"]       = emagged
	data["authenticated"] = is_authenticated(user, 0)
	data["screen"]        = getMenuState(usr)

	data["stat_display"] =  list(
		"type"   = display_type,
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

	data["security_level"] =     GLOB.security_level
	data["str_security_level"] = capitalize(get_security_level())
	data["levels"] = list(
		list("id" = SEC_LEVEL_GREEN, "name" = "Green"),
		list("id" = SEC_LEVEL_BLUE,  "name" = "Blue"),
		//SEC_LEVEL_RED = list("name"="Red"),
	)

	var/list/msg_data = list()
	for(var/i = 1; i <= messagetext.len; i++)
		msg_data.Add(list(list("title" = messagetitle[i], "body" = messagetext[i], "id" = i)))

	data["messages"]        = msg_data
	if((data["is_ai"] && aicurrmsg) || (!data["is_ai"] && currmsg))
		data["current_message"] = data["is_ai"] ? messagetext[aicurrmsg] : messagetext[currmsg]
		data["current_message_title"] = data["is_ai"] ? messagetitle[aicurrmsg] : messagetitle[currmsg]

	data["lastCallLoc"]     = SSshuttle.emergencyLastCallLoc ? format_text(SSshuttle.emergencyLastCallLoc.name) : null

	var/shuttle[0]
	switch(SSshuttle.emergency.mode)
		if(SHUTTLE_IDLE, SHUTTLE_RECALL)
			shuttle["callStatus"] = 2 //#define
		else
			shuttle["callStatus"] = 1
	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/timeleft = SSshuttle.emergency.timeLeft()
		shuttle["eta"] = "[timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]"

	data["shuttle"] = shuttle

	data["atcSquelched"] = GLOB.atc.squelched

	return data


/obj/machinery/computer/communications/proc/setCurrentMessage(var/mob/user,var/value)
	if(isAI(user) || isrobot(user))
		aicurrmsg = value
	else
		currmsg = value

/obj/machinery/computer/communications/proc/getCurrentMessage(var/mob/user)
	if(isAI(user) || isrobot(user))
		return aicurrmsg
	else
		return currmsg

/obj/machinery/computer/communications/proc/setMenuState(var/mob/user,var/value)
	if(isAI(user) || isrobot(user))
		ai_menu_state=value
	else
		menu_state=value

/obj/machinery/computer/communications/proc/getMenuState(var/mob/user)
	if(isAI(user) || isrobot(user))
		return ai_menu_state
	else
		return menu_state

/proc/enable_prison_shuttle(var/mob/user);

/proc/call_shuttle_proc(var/mob/user, var/reason)
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

/proc/init_shift_change(var/mob/user, var/force = 0)
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


/proc/cancel_call_proc(var/mob/user)
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
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
			log_admin("STATUS: [user] set status screen message with [src]: [data1] [data2]")
			//message_admins("STATUS: [user] set status screen with [PDA]. Message: [data1] [data2]")
		if("alert")
			status_signal.data["picture_state"] = data1

	spawn(0)
		frequency.post_signal(src, status_signal)


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

/proc/print_command_report(text = "", title = "Central Command Update")
	for(var/obj/machinery/computer/communications/C in GLOB.shuttle_caller_list)
		if(!(C.stat & (BROKEN|NOPOWER)) && is_station_contact(C.z))
			var/obj/item/paper/P = new /obj/item/paper(C.loc)
			P.name = "paper- '[title]'"
			P.info = text
			P.update_icon()
			C.messagetitle.Add("[title]")
			C.messagetext.Add(text)
	for(var/datum/computer_file/program/comm/P in GLOB.shuttle_caller_list)
		var/turf/T = get_turf(P.computer)
		if(T && P.program_state != PROGRAM_STATE_KILLED && is_station_contact(T.z))
			if(P.computer)
				var/obj/item/computer_hardware/printer/printer = P.computer.all_components[MC_PRINT]
				if(printer)
					printer.print_text(text, "paper- '[title]'")
			P.messagetitle.Add("[title]")
			P.messagetext.Add(text)

/proc/print_centcom_report(text = "", title = "Incoming Message")
	for(var/obj/machinery/computer/communications/C in GLOB.shuttle_caller_list)
		if(!(C.stat & (BROKEN|NOPOWER)) && is_admin_level(C.z))
			var/obj/item/paper/P = new /obj/item/paper(C.loc)
			P.name = "paper- '[title]'"
			P.info = text
			P.update_icon()
			C.messagetitle.Add("[title]")
			C.messagetext.Add(text)
	for(var/datum/computer_file/program/comm/P in GLOB.shuttle_caller_list)
		var/turf/T = get_turf(P.computer)
		if(T && P.program_state != PROGRAM_STATE_KILLED && is_admin_level(T.z))
			if(P.computer)
				var/obj/item/computer_hardware/printer/printer = P.computer.all_components[MC_PRINT]
				if(printer)
					printer.print_text(text, "paper- '[title]'")
			P.messagetitle.Add("[title]")
			P.messagetext.Add(text)
