/datum/computer_file/program/comm
	filename = "comm"
	filedesc = "Command and communications"
	program_icon_state = "comm"
	extended_desc = "Used to command and control the station. Can relay long-range communications. This program can not be run on tablet computers."
	required_access = access_heads
	requires_ntnet = 1
	size = 12
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP
	network_destination = "station long-range communication array"

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

/datum/computer_file/program/comm/New()
	GLOB.shuttle_caller_list += src
	..()
	crew_announcement.newscast = 0

/datum/computer_file/program/comm/Destroy()
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	return ..()

/datum/computer_file/program/comm/proc/is_authenticated(mob/user, loud = 1)
	if(authenticated == COMM_AUTHENTICATION_MAX)
		return COMM_AUTHENTICATION_MAX
	else if(user.can_admin_interact())
		return COMM_AUTHENTICATION_MAX
	else if(authenticated)
		return COMM_AUTHENTICATION_MIN
	else
		if(loud)
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return COMM_AUTHENTICATION_NONE

/datum/computer_file/program/comm/proc/change_security_level(mob/user, new_level)
	tmp_alertlevel = new_level
	var/old_level = security_level
	if(!tmp_alertlevel)
		tmp_alertlevel = SEC_LEVEL_GREEN
	if(tmp_alertlevel < SEC_LEVEL_GREEN)
		tmp_alertlevel = SEC_LEVEL_GREEN
	if(tmp_alertlevel > SEC_LEVEL_BLUE)
		tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
	set_security_level(tmp_alertlevel)
	if(security_level != old_level)
		log_game("[key_name(user)] has changed the security level to [get_security_level()].")
		message_admins("[key_name_admin(user)] has changed the security level to [get_security_level()].")
		switch(security_level)
			if(SEC_LEVEL_GREEN)
				feedback_inc("alert_comms_green", 1)
			if(SEC_LEVEL_BLUE)
				feedback_inc("alert_comms_blue", 1)
	tmp_alertlevel = 0

/datum/computer_file/program/comm/proc/setCurrentMessage(mob/user, value)
	if(isAI(user) || isrobot(user))
		aicurrmsg = value
	else
		currmsg = value

/datum/computer_file/program/comm/proc/getCurrentMessage(mob/user)
	if(isAI(user) || isrobot(user))
		return aicurrmsg
	else
		return currmsg

/datum/computer_file/program/comm/proc/setMenuState(mob/user, value)
	if(isAI(user) || isrobot(user))
		ai_menu_state=value
	else
		menu_state=value

/datum/computer_file/program/comm/proc/getMenuState(mob/user)
	if(isAI(user) || isrobot(user))
		return ai_menu_state
	else
		return menu_state

/datum/computer_file/program/comm/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/headers)
		assets.send(user)
		ui = new(user, src, ui_key, "comm_program.tmpl", "Command and communications program", 575, 500)
		ui.set_layout_key("program")
		ui.open()

/datum/computer_file/program/comm/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/list/data = get_header_data()
	data["is_ai"]         = isAI(user) || isrobot(user)
	data["menu_state"]    = data["is_ai"] ? ai_menu_state : menu_state
	data["emagged"]       = computer ? computer.emagged : null
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

	data["security_level"] =     security_level
	data["str_security_level"] = capitalize(get_security_level())
	data["levels"] = list(
		list("id" = SEC_LEVEL_GREEN, "name" = "Green"),
		list("id" = SEC_LEVEL_BLUE,  "name" = "Blue"),
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

	return data

/datum/computer_file/program/comm/Topic(href, href_list)
	if(..())
		return 1

	var/turf/T = get_turf(computer)
	if(!is_secure_level(T.z))
		to_chat(usr, "<span class='warning'>Unable to establish a connection: You're too far away from the station!</span>")
		return 1

	if(href_list["PRG_login"])
		if(!ishuman(usr))
			to_chat(usr, "<span class='warning'>Access denied.</span>")
			return

		var/list/access = usr.get_access()
		if(access_heads in access)
			authenticated = COMM_AUTHENTICATION_MIN

		if(access_captain in access)
			authenticated = COMM_AUTHENTICATION_MAX
			var/mob/living/carbon/human/H = usr
			var/obj/item/card/id = H.get_idcard(TRUE)
			if(istype(id))
				crew_announcement.announcer = GetNameAndAssignmentFromId(id)

		SSnanoui.update_uis(src)
		return 1

	if(href_list["PRG_logout"])
		authenticated = COMM_AUTHENTICATION_NONE
		crew_announcement.announcer = ""
		setMenuState(usr, COMM_SCREEN_MAIN)
		SSnanoui.update_uis(src)
		return 1

	if(is_authenticated(usr))
		switch(href_list["PRG_operation"])
			if("main")
				setMenuState(usr, COMM_SCREEN_MAIN)

			if("changeseclevel")
				setMenuState(usr,COMM_SCREEN_SECLEVEL)

			if("newalertlevel")
				if(isAI(usr) || isrobot(usr))
					to_chat(usr, "<span class='warning'>Firewalls prevent you from changing the alert level.</span>")
					return 1
				else if(usr.can_admin_interact())
					change_security_level(usr, text2num(href_list["level"]))
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
					if(access_captain in I.access)
						change_security_level(usr, text2num(href_list["level"]))
					else
						to_chat(usr, "<span class='warning'>You are not authorized to do this.</span>")
					setMenuState(usr, COMM_SCREEN_MAIN)
				else
					to_chat(usr, "<span class='warning'>You need to swipe your ID.</span>")

			if("announce")
				if(is_authenticated(usr) == COMM_AUTHENTICATION_MAX)
					if(message_cooldown)
						to_chat(usr, "<span class='warning'>Please allow at least one minute to pass between announcements.</span>")
						SSnanoui.update_uis(src)
						return 1
					var/input = input(usr, "Please write a message to announce to the station crew.", "Priority Announcement")
					if(!input || message_cooldown || ..() || !(is_authenticated(usr) == COMM_AUTHENTICATION_MAX))
						SSnanoui.update_uis(src)
						return 1
					crew_announcement.Announce(input)
					message_cooldown = 1
					spawn(600)//One minute cooldown
						message_cooldown = 0

			if("callshuttle")
				var/input = input(usr, "Please enter the reason for calling the shuttle.", "Shuttle Call Reason.","") as text|null
				if(!input || ..() || !is_authenticated(usr))
					SSnanoui.update_uis(src)
					return 1

				call_shuttle_proc(usr, input)
				if(SSshuttle.emergency.timer)
					post_status("shuttle")
				setMenuState(usr, COMM_SCREEN_MAIN)

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
				setMenuState(usr, COMM_SCREEN_MAIN)

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
				setMenuState(usr, COMM_SCREEN_STAT)

			if("setmsg1")
				stat_msg1 = input("Line 1", "Enter Message Text", stat_msg1) as text|null
				setMenuState(usr, COMM_SCREEN_STAT)

			if("setmsg2")
				stat_msg2 = input("Line 2", "Enter Message Text", stat_msg2) as text|null
				setMenuState(usr, COMM_SCREEN_STAT)

			if("nukerequest")
				if(is_authenticated(usr) == COMM_AUTHENTICATION_MAX)
					if(centcomm_message_cooldown)
						to_chat(usr, "<span class='warning'>Arrays recycling. Please stand by.</span>")
						SSnanoui.update_uis(src)
						return 1
					var/input = stripped_input(usr, "Please enter the reason for requesting the nuclear self-destruct codes. Misuse of the nuclear request system will not be tolerated under any circumstances.  Transmission does not guarantee a response.", "Self Destruct Code Request.","")
					if(!input || ..() || !(is_authenticated(usr) == COMM_AUTHENTICATION_MAX))
						SSnanoui.update_uis(src)
						return 1
					Nuke_request(input, usr)
					to_chat(usr, "<span class='notice'>Request sent.</span>")
					log_game("[key_name(usr)] has requested the nuclear codes from Centcomm")
					priority_announcement.Announce("The codes for the on-station nuclear self-destruct have been requested by [usr]. Confirmation or denial of this request will be sent shortly.", "Nuclear Self Destruct Codes Requested",'sound/AI/commandreport.ogg')
					centcomm_message_cooldown = 1
					spawn(6000)//10 minute cooldown
						centcomm_message_cooldown = 0
				setMenuState(usr,COMM_SCREEN_MAIN)

			if("MessageCentcomm")
				if(is_authenticated(usr) == COMM_AUTHENTICATION_MAX)
					if(centcomm_message_cooldown)
						to_chat(usr, "<span class='warning'>Arrays recycling. Please stand by.</span>")
						SSnanoui.update_uis(src)
						return 1
					var/input = stripped_input(usr, "Please choose a message to transmit to Centcomm via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response.", "To abort, send an empty message.", "")
					if(!input || ..() || !(is_authenticated(usr) == COMM_AUTHENTICATION_MAX))
						SSnanoui.update_uis(src)
						return 1
					Centcomm_announce(input, usr)
					to_chat(usr, "Message transmitted.")
					log_game("[key_name(usr)] has made a Centcomm announcement: [input]")
					centcomm_message_cooldown = 1
					spawn(6000)//10 minute cooldown
						centcomm_message_cooldown = 0
				setMenuState(usr,COMM_SCREEN_MAIN)

			// OMG SYNDICATE ...LETTERHEAD
			if("MessageSyndicate")
				if((is_authenticated(usr) == COMM_AUTHENTICATION_MAX) && (computer && computer.emagged))
					if(centcomm_message_cooldown)
						to_chat(usr, "Arrays recycling.  Please stand by.")
						SSnanoui.update_uis(src)
						return 1
					var/input = stripped_input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING CORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "To abort, send an empty message.", "")
					if(!input || ..() || !(is_authenticated(usr) == COMM_AUTHENTICATION_MAX))
						SSnanoui.update_uis(src)
						return 1
					Syndicate_announce(input, usr)
					to_chat(usr, "Message transmitted.")
					log_game("[key_name(usr)] has made a Syndicate announcement: [input]")
					centcomm_message_cooldown = 1
					spawn(6000)//10 minute cooldown
						centcomm_message_cooldown = 0
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

	SSnanoui.update_uis(src)
	return 1