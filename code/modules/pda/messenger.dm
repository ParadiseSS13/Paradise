/datum/data/pda/app/messenger
	name = "Messenger"
	icon = "comments-o"
	notify_icon = "comments"
	title = "SpaceMessenger V4.1.0"
	template = "pda_messenger"

	var/toff = 0 //If 1, messenger disabled
	var/list/tnote = list()  //Current Texts
	var/last_text //No text spamming

	var/m_hidden = 0 // Is the PDA hidden from the PDA list?
	var/active_conversation = null // New variable that allows us to only view a single conversation.
	var/list/conversations = list()    // For keeping up with who we have PDA messsages from.

/datum/data/pda/app/messenger/start()
	. = ..()
	unnotify()

/datum/data/pda/app/messenger/update_ui(mob/user as mob, list/data)
	data["silent"] = pda.silent						// does the pda make noise when it receives a message?
	data["toff"] = toff									// is the messenger function turned off?
	// Yes I know convo is awful, but it lets me stay inside the 80 char TGUI line limit
	data["active_convo"] = active_conversation	// Which conversation are we following right now?

	has_back = active_conversation
	if(active_conversation)
		data["messages"] = tnote
		for(var/c in tnote)
			if(c["target"] == active_conversation)
				data["convo_name"] = c["owner"]
				data["convo_job"] = c["job"]
				break
	else
		var/list/convopdas = list()
		var/list/pdas = list()
		for(var/A in GLOB.PDAs)
			var/obj/item/pda/P = A
			var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

			if(!P.owner || PM.toff || P == pda || PM.m_hidden)
				continue
			if(conversations.Find("[P.UID()]"))
				convopdas.Add(list(list("Name" = "[P]", "uid" = "[P.UID()]", "Detonate" = "[P.detonate]", "inconvo" = "1")))
			else
				pdas.Add(list(list("Name" = "[P]", "uid" = "[P.UID()]", "Detonate" = "[P.detonate]", "inconvo" = "0")))

		data["convopdas"] = convopdas
		data["pdas"] = pdas

		var/list/plugins = list()
		if(pda.cartridge)
			for(var/A in pda.cartridge.messenger_plugins)
				var/datum/data/pda/messenger_plugin/P = A
				plugins += list(list(name = P.name, icon = P.icon, uid = "[P.UID()]"))
		data["plugins"] = plugins

		if(pda.cartridge)
			data["charges"] = pda.cartridge.charges ? pda.cartridge.charges : 0

/datum/data/pda/app/messenger/ui_act(action, list/params)
	if(..())
		return

	unnotify()

	var/play_beep = TRUE

	. = TRUE


	switch(action)
		if("Toggle Messenger")
			toff = !toff
		if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
			pda.silent = !pda.silent
		if("Clear")//Clears messages
			if(params["option"] == "All")
				tnote.Cut()
				conversations.Cut()
			if(params["option"] == "Convo")
				var/list/new_tnote = list()
				for(var/i in tnote)
					if(i["target"] != active_conversation)
						new_tnote[++new_tnote.len] = i
				tnote = new_tnote
				conversations.Remove(active_conversation)

			active_conversation = null
		if("Message")
			play_beep = FALSE
			var/obj/item/pda/P = locateUID(params["target"])
			create_message(usr, P)
			if(params["target"] in conversations)            // Need to make sure the message went through, if not welp.
				active_conversation = params["target"]
		if("Select Conversation")
			var/P = params["target"]
			for(var/n in conversations)
				if(P == n)
					active_conversation = P
		if("Messenger Plugin")
			if(!params["target"] || !params["plugin"])
				return

			var/obj/item/pda/P = locateUID(params["target"])
			if(!P)
				to_chat(usr, "PDA not found.")

			var/datum/data/pda/messenger_plugin/plugin = locateUID(params["plugin"])
			if(plugin && (plugin in pda.cartridge.messenger_plugins))
				plugin.messenger = src
				plugin.user_act(usr, P)
		if("Back")
			active_conversation = null

	if(play_beep && !pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)


/datum/data/pda/app/messenger/proc/create_message(mob/living/U, obj/item/pda/P)
	var/t = input(U, "Please enter message", name, null) as text|null
	if(!t)
		return
	t = sanitize(copytext_char(t, 1, MAX_MESSAGE_LEN))		// SS220 EDIT - ORIGINAL: copytext
	if(!t || !istype(P))
		return
	if(!in_range(pda, U) && pda.loc != U)
		return

	var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

	if(!PM || PM.toff || toff)
		return

	if(last_text && world.time < last_text + 5)
		return

	if(!pda.can_use())
		return

	last_text = world.time
	// check if telecomms I/O route 1459 is stable
	//var/telecomms_intact = telecomms_process(P.owner, owner, t)
	var/obj/machinery/message_server/useMS = null
	if(GLOB.message_servers)
		for(var/A in GLOB.message_servers)
			var/obj/machinery/message_server/MS = A
		//PDAs are now dependent on the Message Server.
			if(MS.active)
				useMS = MS
				break

	var/turf/sender_pos = get_turf(U)
	var/turf/recipient_pos = get_turf(P)

	// Can the message be sent
	var/sendable = FALSE
	// Can the message be received?
	var/receivable = FALSE

	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		if(C.zlevel_reachable(sender_pos.z))
			sendable = TRUE
		if(C.zlevel_reachable(recipient_pos.z))
			receivable = TRUE
		// Once both are done, exit the loop
		if(sendable && receivable)
			break

	if(!sendable) // Are we in the range of a reciever?
		to_chat(U, "<span class='warning'>ERROR: No connection to server.</span>")
		if(!pda.silent)
			playsound(pda, 'sound/machines/terminal_error.ogg', 15, TRUE)
		return

	if(!receivable) // Is our recipient in the range of a reciever?
		to_chat(U, "<span class='warning'>ERROR: No connection to recipient.</span>")
		if(!pda.silent)
			playsound(pda, 'sound/machines/terminal_error.ogg', 15, TRUE)
		return

	if(useMS && sendable && receivable) // only send the message if its going to work


		useMS.send_pda_message("[P.owner]","[pda.owner]","[t]")
		tnote.Add(list(list("sent" = 1, "owner" = "[P.owner]", "job" = "[P.ownjob]", "message" = "[html_decode(t)]", "target" = "[P.UID()]")))
		PM.tnote.Add(list(list("sent" = 0, "owner" = "[pda.owner]", "job" = "[pda.ownjob]", "message" = "[html_decode(t)]", "target" = "[pda.UID()]")))
		pda.investigate_log("<span class='game say'>PDA Message - <span class='name'>[pda.owner] ([U.key] [ADMIN_PP(U, "PP")])</span> -> <span class='name'>[P.owner]</span> ([ADMIN_VV(P, "VV")]), Message: <span class='message'>\"[t]\"</span></span>", "pda")

		// Show it to ghosts
		for(var/mob/M in GLOB.dead_mob_list)
			if(isobserver(M) && M.client && (M.client.prefs.toggles & PREFTOGGLE_CHAT_GHOSTPDA))
				var/ghost_message = "<span class='name'>[pda.owner]</span> ([ghost_follow_link(pda, ghost=M)]) <span class='game say'>PDA Message</span> --> <span class='name'>[P.owner]</span> ([ghost_follow_link(P, ghost=M)]): <span class='message'>[t]</span>"
				to_chat(M, "[ghost_message]")

		if(!conversations.Find("[P.UID()]"))
			conversations.Add("[P.UID()]")
		if(!PM.conversations.Find("[pda.UID()]"))
			PM.conversations.Add("[pda.UID()]")

		SStgui.update_uis(src)
		PM.notify("<b>Message from [pda.owner] ([pda.ownjob]), </b>\"[t]\" (<a href='?src=[PM.UID()];choice=Message;target=[pda.UID()]'>Reply</a>)")
		log_pda("(PDA: [src.name]) sent \"[t]\" to [P.name]", U)
		var/log_message = "sent PDA message \"[t]\" using [pda]"
		var/receiver
		if(ishuman(P.loc))
			receiver = P.loc
			log_message = "[log_message] to [P]"
		else
			receiver = P
			log_message = "[log_message] (no holder)"
		U.create_log(MISC_LOG, log_message, receiver)
		if(!pda.silent)
			playsound(pda, 'sound/machines/terminal_success.ogg', 15, TRUE)
	else
		to_chat(U, "<span class='notice'>ERROR: Messaging server is not responding.</span>")
		if(!pda.silent)
			playsound(pda, 'sound/machines/terminal_error.ogg', 15, TRUE)

/datum/data/pda/app/messenger/proc/available_pdas()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if(toff)
		to_chat(usr, "Turn on your receiver in order to send messages.")
		return

	for(var/A in GLOB.PDAs)
		var/obj/item/pda/P = A
		var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

		if(!P.owner || !PM || PM.hidden || P == pda || PM.toff)
			continue

		var/name = P.owner
		if(name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P
	return plist

/datum/data/pda/app/messenger/proc/can_receive()
	return pda.owner && !toff && !hidden

// Handler for the in-chat reply button
/datum/data/pda/app/messenger/Topic(href, href_list)
	if(!pda.can_use())
		return
	unnotify()
	switch(href_list["choice"])
		if("Message")
			var/obj/item/pda/P = locateUID(href_list["target"])
			create_message(usr, P)
			if(href_list["target"] in conversations)            // Need to make sure the message went through, if not welp.
				active_conversation = href_list["target"]
