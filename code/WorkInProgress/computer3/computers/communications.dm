/obj/machinery/computer3/communications
	default_prog		= /datum/file/program/communications
	spawn_parts			= list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/radio/subspace)

/obj/machinery/computer3/communications/captain
	default_prog		= /datum/file/program/communications
	spawn_parts			= list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/radio/subspace,/obj/item/part/computer/cardslot/dual)
	spawn_files			= list(/datum/file/program/card_comp, /datum/file/program/security, /datum/file/program/crew, /datum/file/program/arcade,
							/datum/file/camnet_key, /datum/file/camnet_key/entertainment, /datum/file/camnet_key/singulo)


/datum/file/program/communications
	var/const/STATE_DEFAULT = 1
	var/const/STATE_CALLSHUTTLE = 2
	var/const/STATE_CANCELSHUTTLE = 3
	var/const/STATE_MESSAGELIST = 4
	var/const/STATE_VIEWMESSAGE = 5
	var/const/STATE_DELMESSAGE = 6
	var/const/STATE_STATUSDISPLAY = 7
	var/const/STATE_ALERT_LEVEL = 8
	var/const/STATE_CONFIRM_LEVEL = 9


/datum/file/program/communications
	name = "Centcom communications relay"
	desc = "Used to connect to Centcom."
	active_state = "comm"
	req_access = list(access_heads)

	var/prints_intercept = 1
	var/authenticated = 0
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg = 0
	var/aicurrmsg = 0
	var/state = STATE_DEFAULT
	var/aistate = STATE_DEFAULT
	var/message_cooldown = 0
	var/centcomm_message_cooldown = 0
	var/tmp_alertlevel = 0

	var/status_display_freq = "1435"
	var/stat_msg1
	var/stat_msg2

	Reset()
		..()
		authenticated = 0
		state = STATE_DEFAULT
		aistate = STATE_DEFAULT


	Topic(var/href, var/list/href_list)
		if(!interactable() || !computer.radio || ..(href,href_list) )
			return
		if (computer.z > 1)
			usr << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
			return

		if("main" in href_list)
			state = STATE_DEFAULT
		if("login" in href_list)
			var/mob/M = usr
			var/obj/item/I = M.get_active_hand()
			if(I)
				I = I.GetID()
			if(istype(I,/obj/item/weapon/card/id) && check_access(I))
				authenticated = 1
				if(access_captain in I.GetAccess())
					authenticated = 2
			if(istype(I,/obj/item/weapon/card/emag))
				authenticated = 2
				computer.emagged = 1
		if("logout" in href_list)
			authenticated = 0

		if("swipeidseclevel" in href_list)
			var/mob/M = usr
			var/obj/item/I = M.get_active_hand()
			I = I.GetID()

			if (istype(I,/obj/item/weapon/card/id))
				if(access_captain in I.GetAccess())
					var/old_level = security_level
					if(!tmp_alertlevel) tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel < SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel > SEC_LEVEL_BLUE) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
					set_security_level(tmp_alertlevel)
					if(security_level != old_level)
						//Only notify the admins if an actual change happened
						log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
						message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
						switch(security_level)
							if(SEC_LEVEL_GREEN)
								feedback_inc("alert_comms_green",1)
							if(SEC_LEVEL_BLUE)
								feedback_inc("alert_comms_blue",1)
					tmp_alertlevel = 0
				else:
					usr << "You are not authorized to do this."
					tmp_alertlevel = 0
				state = STATE_DEFAULT
			else
				usr << "You need to swipe your ID."
		if("announce" in href_list)
			if(authenticated==2)
				if(message_cooldown)	return
				var/input = stripped_input(usr, "Please choose a message to announce to the station crew.", "What?")
				if(!input || !interactable())
					return
				captain_announce(input)//This should really tell who is, IE HoP, CE, HoS, RD, Captain
				log_say("[key_name(usr)] has made a captain announcement: [input]")
				message_admins("[key_name_admin(usr)] has made a captain announcement.", 1)
				message_cooldown = 1
				spawn(600)//One minute cooldown
					message_cooldown = 0

		if("callshuttle" in href_list)
			state = STATE_DEFAULT
			if(authenticated)
				state = STATE_CALLSHUTTLE
		if("callshuttle2" in href_list)
			if(!computer.radio.subspace)
				return
			if(authenticated)
				call_shuttle_proc(usr)
				if(emergency_shuttle.online())
					post_status("shuttle")
			state = STATE_DEFAULT
		if("cancelshuttle" in href_list)
			state = STATE_DEFAULT
			if(authenticated)
				state = STATE_CANCELSHUTTLE
		if("messagelist" in href_list)
			currmsg = 0
			state = STATE_MESSAGELIST
		if("viewmessage" in href_list)
			state = STATE_VIEWMESSAGE
			if (!currmsg)
				if(href_list["message-num"])
					currmsg = text2num(href_list["message-num"])
				else
					state = STATE_MESSAGELIST
		if("delmessage" in href_list)
			state = (currmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("delmessage2" in href_list)
			if(authenticated)
				if(currmsg)
					var/title = messagetitle[currmsg]
					var/text  = messagetext[currmsg]
					messagetitle.Remove(title)
					messagetext.Remove(text)
					if(currmsg == aicurrmsg)
						aicurrmsg = 0
					currmsg = 0
				state = STATE_MESSAGELIST
			else
				state = STATE_VIEWMESSAGE
		if("status" in href_list)
			state = STATE_STATUSDISPLAY

		// Status display stuff
		if("setstat" in href_list)
			switch(href_list["statdisp"])
				if("message")
					post_status("message", stat_msg1, stat_msg2)
				if("alert")
					post_status("alert", href_list["alert"])
				else
					post_status(href_list["statdisp"])

		if("setmsg1" in href_list)
			stat_msg1 = reject_bad_text(input("Line 1", "Enter Message Text", stat_msg1) as text|null, 40)
			computer.updateDialog()
		if("setmsg2" in href_list)
			stat_msg2 = reject_bad_text(input("Line 2", "Enter Message Text", stat_msg2) as text|null, 40)
			computer.updateDialog()

		// OMG CENTCOMM LETTERHEAD
		if("MessageCentcomm" in href_list)
			if(!computer.radio.subspace)
				return
			if(authenticated==2)
				if(centcomm_message_cooldown)
					usr << "Arrays recycling.  Please stand by."
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to Centcomm via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response.", "To abort, send an empty message.", "")
				if(!input || !interactable())
					return
				Centcomm_announce(input, usr)
				usr << "Message transmitted."
				log_say("[key_name(usr)] has made a Centcomm announcement: [input]")
				centcomm_message_cooldown = 1
				spawn(600)//10 minute cooldown
					centcomm_message_cooldown = 0


		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate" in href_list)
			if((authenticated==2) && (computer.emagged))
				if(centcomm_message_cooldown)
					usr << "Arrays recycling.  Please stand by."
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING CORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "To abort, send an empty message.", "")
				if(!input || !interactable())
					return
				Syndicate_announce(input, usr)
				usr << "Message transmitted."
				log_say("[key_name(usr)] has made a Syndicate announcement: [input]")
				centcomm_message_cooldown = 1
				spawn(600)//10 minute cooldown
					centcomm_message_cooldown = 0

		if("RestoreBackup" in href_list)
			usr << "Backup routing data restored!"
			computer.emagged = 0
			computer.updateDialog()



		// AI interface
		if("ai-main" in href_list)
			aicurrmsg = 0
			aistate = STATE_DEFAULT
		if("ai-callshuttle" in href_list)
			aistate = STATE_CALLSHUTTLE
		if("ai-callshuttle2" in href_list)
			if(!computer.radio.subspace)
				return
			call_shuttle_proc(usr)
			aistate = STATE_DEFAULT
		if("ai-messagelist" in href_list)
			aicurrmsg = 0
			aistate = STATE_MESSAGELIST
		if("ai-viewmessage" in href_list)
			aistate = STATE_VIEWMESSAGE
			if (!aicurrmsg)
				if(href_list["message-num"])
					aicurrmsg = text2num(href_list["message-num"])
				else
					aistate = STATE_MESSAGELIST
		if("ai-delmessage" in href_list)
			aistate = (aicurrmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("ai-delmessage2" in href_list)
			if(aicurrmsg)
				var/title = messagetitle[aicurrmsg]
				var/text  = messagetext[aicurrmsg]
				messagetitle.Remove(title)
				messagetext.Remove(text)
				if(currmsg == aicurrmsg)
					currmsg = 0
				aicurrmsg = 0
			aistate = STATE_MESSAGELIST
		if("ai-status" in href_list)
			aistate = STATE_STATUSDISPLAY

		if("securitylevel" in href_list)
			tmp_alertlevel = text2num( href_list["newalertlevel"] )
			if(!tmp_alertlevel) tmp_alertlevel = 0
			state = STATE_CONFIRM_LEVEL

		if("changeseclevel" in href_list)
			state = STATE_ALERT_LEVEL

		computer.updateUsrDialog()



	proc/main_menu()
		var/dat = ""
		if (computer.radio.subspace)
			if(emergency_shuttle.online() && emergency_shuttle.location())
				var/timeleft = emergency_shuttle.estimate_arrival_time()
				dat += "<B>Emergency shuttle</B>\n<BR>\nETA: [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]<BR>"
				refresh = 1
			else
				refresh = 0
		if (authenticated)
			dat += "<BR>\[ <A HREF='?src=\ref[src];logout'>Log Out</A> \]"
			if (authenticated==2)
				dat += "<BR>\[ <A HREF='?src=\ref[src];announce'>Make An Announcement</A> \]"
				if(computer.emagged == 0)
					dat += "<BR>\[ <A HREF='?src=\ref[src];MessageCentcomm'>Send an emergency message to Centcomm</A> \]"
				else
					dat += "<BR>\[ <A HREF='?src=\ref[src];MessageSyndicate'>Send an emergency message to \[UNKNOWN\]</A> \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];RestoreBackup'>Restore Backup Routing Data</A> \]"

				dat += "<BR>\[ <A HREF='?src=\ref[src];changeseclevel'>Change alert level</A> \]"
			if(emergency_shuttle.location())
				if (emergency_shuttle.online())
					dat += "<BR>\[ <A HREF='?src=\ref[src];cancelshuttle'>Cancel Shuttle Call</A> \]"
				else
					dat += "<BR>\[ <A HREF='?src=\ref[src];callshuttle'>Call Emergency Shuttle</A> \]"

			dat += "<BR>\[ <A HREF='?src=\ref[src];status'>Set Status Display</A> \]"
		else
			dat += "<BR>\[ <A HREF='?src=\ref[src];login'>Log In</A> \]"
		dat += "<BR>\[ <A HREF='?src=\ref[src];messagelist'>Message List</A> \]"
		return dat

	proc/confirm_menu(var/prompt,var/yes_option)
		return "Are you sure you want to [prompt]? \[ [topic_link(src,yes_option,"OK")] | [topic_link(src,"main","Cancel")] \]"

	interact()
		if(!interactable())
			return
		if(!computer.radio)
			computer.Crash(MISSING_PERIPHERAL)
			return

		var/dat = ""
		switch(state)
			if(STATE_DEFAULT)
				dat = main_menu()
			if(STATE_CALLSHUTTLE)
				dat = confirm_menu("call the shuttle","callshuttle2")
			if(STATE_CANCELSHUTTLE)
				dat = confirm_menu("cancel the shuttle","cancelshuttle2")
			if(STATE_MESSAGELIST)
				dat += "Messages:"
				for(var/i = 1; i<=messagetitle.len; i++)
					dat += "<BR><A HREF='?src=\ref[src];viewmessage;message-num=[i]'>[messagetitle[i]]</A>"
			if(STATE_VIEWMESSAGE)
				if (currmsg)
					dat += "<B>[messagetitle[currmsg]]</B><BR><BR>[messagetext[currmsg]]"
					if (authenticated)
						dat += "<BR><BR>\[ <A HREF='?src=\ref[src];delmessage'>Delete \]"
				else
					state = STATE_MESSAGELIST
					interact()
					return
			if(STATE_DELMESSAGE)
				if (currmsg)
					dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];delmessage2'>OK</A> | <A HREF='?src=\ref[src];viewmessage'>Cancel</A> \]"
				else
					state = STATE_MESSAGELIST
					interact()
					return
			if(STATE_STATUSDISPLAY)
				dat += "\[ <A HREF='?src=\ref[src];main'>Back</A> \]<BR>"
				dat += "Set Status Displays<BR>"
				dat += "\[ <A HREF='?src=\ref[src];setstat;statdisp=blank'>Clear</A> \]<BR>"
				dat += "\[ <A HREF='?src=\ref[src];setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
				dat += "\[ <A HREF='?src=\ref[src];setstat;statdisp=message'>Message</A> \]"
				dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
				dat += "<li> Line 2: <A HREF='?src=\ref[src];setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
				dat += "\[ Alert: <A HREF='?src=\ref[src];setstat;statdisp=alert;alert=default'>None</A> |"
				dat += " <A HREF='?src=\ref[src];setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
				dat += " <A HREF='?src=\ref[src];setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
				dat += " <A HREF='?src=\ref[src];setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"
			if(STATE_ALERT_LEVEL)
				dat += "Current alert level: [get_security_level()]<BR>"
				if(security_level == SEC_LEVEL_DELTA)
					dat += "<font color='red'><b>The self-destruct mechanism is active. Find a way to deactivate the mechanism to lower the alert level or evacuate.</b></font>"
				else
					dat += "<A HREF='?src=\ref[src];securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
					dat += "<A HREF='?src=\ref[src];securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"
			if(STATE_CONFIRM_LEVEL)
				dat += "Current alert level: [get_security_level()]<BR>"
				dat += "Confirm the change to: [num2seclevel(tmp_alertlevel)]<BR>"
				dat += "<A HREF='?src=\ref[src];swipeidseclevel'>Swipe ID</A> to confirm change.<BR>"

		popup.set_content(dat)
		popup.open()


	proc/post_status(var/command, var/data1, var/data2)
		var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

		if(!frequency) return

		var/datum/signal/status_signal = new
		status_signal.source = src
		status_signal.transmission_method = 1
		status_signal.data["command"] = command

		switch(command)
			if("message")
				status_signal.data["msg1"] = data1
				status_signal.data["msg2"] = data2
			if("alert")
				status_signal.data["picture_state"] = data1

		frequency.post_signal(src, status_signal)
