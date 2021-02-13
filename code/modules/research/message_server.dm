GLOBAL_LIST_EMPTY(message_servers)

/datum/data_pda_msg
	var/recipient = "Unspecified" //name of the person
	var/sender = "Unspecified" //name of the sender
	var/message = "Blank" //transferred message

/datum/data_pda_msg/New(var/param_rec = "",var/param_sender = "",var/param_message = "")

	if(param_rec)
		recipient = param_rec
	if(param_sender)
		sender = param_sender
	if(param_message)
		message = param_message

/datum/data_rc_msg
	var/rec_dpt = "Unspecified" //name of the person
	var/send_dpt = "Unspecified" //name of the sender
	var/message = "Blank" //transferred message
	var/stamp = "Unstamped"
	var/id_auth = "Unauthenticated"
	var/priority = "Normal"

/datum/data_rc_msg/New(var/param_rec = "",var/param_sender = "",var/param_message = "",var/param_stamp = "",var/param_id_auth = "",var/param_priority)
	if(param_rec)
		rec_dpt = param_rec
	if(param_sender)
		send_dpt = param_sender
	if(param_message)
		message = param_message
	if(param_stamp)
		stamp = param_stamp
	if(param_id_auth)
		id_auth = param_id_auth
	if(param_priority)
		switch(param_priority)
			if(1)
				priority = "Normal"
			if(2)
				priority = "High"
			if(3)
				priority = "Extreme"
			else
				priority = "Undetermined"

/obj/machinery/message_server
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	name = "Messaging Server"
	density = 1
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100

	var/list/datum/data_pda_msg/pda_msgs = list()
	var/list/datum/data_rc_msg/rc_msgs = list()
	var/active = 1
	var/decryptkey = "password"

/obj/machinery/message_server/New()
	GLOB.message_servers += src
	decryptkey = GenerateKey()
	send_pda_message("System Administrator", "system", "This is an automated message. The messaging system is functioning correctly.")
	..()
	return

/obj/machinery/message_server/Destroy()
	GLOB.message_servers -= src
	return ..()

/obj/machinery/message_server/process()
	//if(decryptkey == "password")
	//	decryptkey = generateKey()
	if(active && (stat & (BROKEN|NOPOWER)))
		active = 0
		return
	if(prob(3))
		playsound(loc, "computer_ambience", 50, 1)
	update_icon()
	return

/obj/machinery/message_server/proc/send_pda_message(var/recipient = "",var/sender = "",var/message = "")
	pda_msgs += new/datum/data_pda_msg(recipient,sender,message)

/obj/machinery/message_server/proc/send_rc_message(var/recipient = "",var/sender = "",var/message = "",var/stamp = "", var/id_auth = "", var/priority = 1)
	rc_msgs += new/datum/data_rc_msg(recipient,sender,message,stamp,id_auth)
	var/authmsg = "[message]"
	if(id_auth)
		authmsg += " - [id_auth]"
	if(stamp)
		authmsg += " - [stamp]"
	for(var/C in GLOB.allRequestConsoles)
		var/obj/machinery/requests_console/RC = C
		if(ckey(RC.department) == ckey(recipient))
			if(RC.inoperable())
				RC.message_log += "Message lost due to console failure. Please contact [station_name()]'s system administrator or AI for technical assistance."
				continue
			if(RC.newmessagepriority < priority)
				RC.newmessagepriority = priority
				RC.icon_state = "req_comp[priority]"
			switch(priority)
				if(2)
					if(!RC.silent)
						playsound(RC.loc, 'sound/machines/twobeep.ogg', 50, 1)
						RC.atom_say("PRIORITY Alert in [sender]")
					RC.message_log += "High Priority message from [sender]: [authmsg]"
				else
					if(!RC.silent)
						playsound(RC.loc, 'sound/machines/twobeep.ogg', 50, 1)
						RC.atom_say("Message from [sender]")
					RC.message_log += "Message [sender]: [authmsg]"
			RC.set_light(2)

/obj/machinery/message_server/attack_hand(user as mob)
//	to_chat(user, "<span class='notice'>There seem to be some parts missing from this server. They should arrive on the station in a few days, give or take a few CentComm delays.</span>")
	to_chat(user, "You toggle PDA message passing from [active ? "On" : "Off"] to [active ? "Off" : "On"]")
	active = !active
	update_icon()

	return

/obj/machinery/message_server/update_icon()
	if((stat & (BROKEN|NOPOWER)))
		icon_state = "server-nopower"
	else if(!active)
		icon_state = "server-off"
	else
		icon_state = "server-on"

	return
/obj/machinery/blackbox_recorder
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	name = "Blackbox Recorder"
	density = 1
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100

