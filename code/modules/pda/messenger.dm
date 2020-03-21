/datum/data/pda/app/messenger
	name = "Messenger"
	icon = "comments-o"
	notify_icon = "comments"
	title = "SpaceMessenger V4.1.0"
	template = "pda_messenger"

	var/toff = 0 //If 1, messenger disabled
	var/list/tnote[0]  //Current Texts
	var/last_text //No text spamming

	var/m_hidden = 0 // Is the PDA hidden from the PDA list?
	var/active_conversation = null // New variable that allows us to only view a single conversation.
	var/list/conversations = list()    // For keeping up with who we have PDA messsages from.
	var/latest_post = 0
	var/auto_scroll = 1

/datum/data/pda/app/messenger/start()
	. = ..()
	unnotify()
	latest_post = 0

/datum/data/pda/app/messenger/update_ui(mob/user as mob, list/data)
	data["silent"] = notify_silent						// does the pda make noise when it receives a message?
	data["toff"] = toff									// is the messenger function turned off?
	data["active_conversation"] = active_conversation	// Which conversation are we following right now?

	has_back = active_conversation
	if(active_conversation)
		data["messages"] = tnote
		for(var/c in tnote)
			if(c["target"] == active_conversation)
				data["convo_name"] = sanitize(c["owner"])
				data["convo_job"] = sanitize(c["job"])
				break
		data["auto_scroll"] = auto_scroll
		data["latest_post"] = latest_post
		latest_post = tnote.len
	else
		var/convopdas[0]
		var/pdas[0]
		for(var/A in GLOB.PDAs)
			var/obj/item/pda/P = A
			var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

			if(!P.owner || PM.toff || P == pda || PM.m_hidden)
				continue
			if(conversations.Find("\ref[P]"))
				convopdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "1")))
			else
				pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))

		data["convopdas"] = convopdas
		data["pdas"] = pdas

		var/list/plugins = list()
		if(pda.cartridge)
			for(var/A in pda.cartridge.messenger_plugins)
				var/datum/data/pda/messenger_plugin/P = A
				plugins += list(list(name = P.name, icon = P.icon, ref = "\ref[P]"))
		data["plugins"] = plugins

		if(pda.cartridge)
			data["charges"] = pda.cartridge.charges ? pda.cartridge.charges : 0

/datum/data/pda/app/messenger/Topic(href, list/href_list)
	if(!pda.can_use())
		return
	unnotify()

	switch(href_list["choice"])
		if("Toggle Messenger")
			toff = !toff
		if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
			notify_silent = !notify_silent
		if("Clear")//Clears messages
			if(href_list["option"] == "All")
				tnote.Cut()
				conversations.Cut()
			if(href_list["option"] == "Convo")
				var/new_tnote[0]
				for(var/i in tnote)
					if(i["target"] != active_conversation)
						new_tnote[++new_tnote.len] = i
				tnote = new_tnote
				conversations.Remove(active_conversation)

			active_conversation = null
			latest_post = 0
		if("Message")
			var/obj/item/pda/P = locate(href_list["target"])
			create_message(usr, P)
			if(href_list["target"] in conversations)            // Need to make sure the message went through, if not welp.
				active_conversation = href_list["target"]
				latest_post = 0
		if("Select Conversation")
			var/P = href_list["convo"]
			for(var/n in conversations)
				if(P == n)
					active_conversation = P
					latest_post = 0
		if("Messenger Plugin")
			if(!href_list["target"] || !href_list["plugin"])
				return

			var/obj/item/pda/P = locate(href_list["target"])
			if(!P)
				to_chat(usr, "PDA not found.")

			var/datum/data/pda/messenger_plugin/plugin = locate(href_list["plugin"])
			if(plugin && (plugin in pda.cartridge.messenger_plugins))
				plugin.messenger = src
				plugin.user_act(usr, P)
		if("Back")
			active_conversation = null
			latest_post = 0
		if("Autoscroll")
			auto_scroll = !auto_scroll

/datum/data/pda/app/messenger/proc/create_message(var/mob/living/U, var/obj/item/pda/P)
	var/t = input(U, "Please enter message", name, null) as text|null
	if(!t)
		return
	t = sanitize(copytext(t, 1, MAX_MESSAGE_LEN))
	t = readd_quotes(t)
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

	var/datum/signal/signal = pda.telecomms_process()

	var/useTC = 0
	if(signal)
		if(signal.data["done"])
			useTC = 1
			var/turf/pos = get_turf(P)
			// TODO: Make the radio system cooperate with the space manager
			if(pos.z in signal.data["level"])
				useTC = 2
				//Let's make this barely readable
				if(signal.data["compression"] > 0)
					t = Gibberish(t, signal.data["compression"] + 50)

	if(useMS && useTC) // only send the message if it's stable
		if(useTC != 2) // Does our recipient have a broadcaster on their level?
			to_chat(U, "ERROR: Cannot reach recipient.")
			return

		useMS.send_pda_message("[P.owner]","[pda.owner]","[t]")
		tnote.Add(list(list("sent" = 1, "owner" = "[P.owner]", "job" = "[P.ownjob]", "message" = "[t]", "target" = "\ref[P]")))
		PM.tnote.Add(list(list("sent" = 0, "owner" = "[pda.owner]", "job" = "[pda.ownjob]", "message" = "[t]", "target" = "\ref[pda]")))
		pda.investigate_log("<span class='game say'>PDA Message - <span class='name'>[U.key] - [pda.owner]</span> -> <span class='name'>[P.owner]</span>: <span class='message'>[t]</span></span>", "pda")

		// Show it to ghosts
		for(var/mob/M in GLOB.dead_mob_list)
			if(isobserver(M) && M.client && (M.client.prefs.toggles & CHAT_GHOSTPDA))
				var/ghost_message = "<span class='name'>[pda.owner]</span> ([ghost_follow_link(pda, ghost=M)]) <span class='game say'>PDA Message</span> --> <span class='name'>[P.owner]</span> ([ghost_follow_link(P, ghost=M)]): <span class='message'>[t]</span>"
				to_chat(M, "[ghost_message]")

		if(!conversations.Find("\ref[P]"))
			conversations.Add("\ref[P]")
		if(!PM.conversations.Find("\ref[pda]"))
			PM.conversations.Add("\ref[pda]")

		SSnanoui.update_user_uis(U, P) // Update the sending user's PDA UI so that they can see the new message
		PM.notify("<b>Message from [pda.owner] ([pda.ownjob]), </b>\"[t]\" (<a href='?src=[PM.UID()];choice=Message;target=\ref[pda]'>Reply</a>)")
		log_pda("(PDA: [src.name]) sent \"[t]\" to [P.name]", usr)
	else
		to_chat(U, "<span class='notice'>ERROR: Messaging server is not responding.</span>")

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
