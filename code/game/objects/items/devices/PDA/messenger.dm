/datum/data/pda/app/messenger
	name = "Messenger"
	icon = "comments-o"
	title = "SpaceMessenger V4.0.1"
	template = "pda_messenger"

	var/silent = 0 //To beep or not to beep, that is the question
	var/toff = 0 //If 1, messenger disabled
	var/list/tnote[0]  //Current Texts
	var/last_text //No text spamming
	var/list/ttone_sound = list("beep" = 'sound/machines/twobeep.ogg',
								"boom" = 'sound/effects/explosionfar.ogg',
								"slip" = 'sound/misc/slip.ogg',
								"honk" = 'sound/items/bikehorn.ogg',
								"SKREE" = 'sound/voice/shriek1.ogg',
								"holy" = 'sound/items/PDA/ambicha4-short.ogg',
								"xeno" = 'sound/voice/hiss1.ogg')

	var/m_hidden = 0 // Is the PDA hidden from the PDA list?
	var/active_conversation = null // New variable that allows us to only view a single conversation.
	var/list/conversations = list()    // For keeping up with who we have PDA messsages from.

/datum/data/pda/app/messenger/start()
	. = ..()
	set_new(0)

/datum/data/pda/app/messenger/update_ui(mob/user as mob, list/data)
	data["silent"] = silent								// does the pda make noise when it receives a message?
	data["toff"] = toff									// is the messenger function turned off?
	data["active_conversation"] = active_conversation	// Which conversation are we following right now?

	var/convopdas[0]
	var/pdas[0]
	var/count = 0
	for(var/A in PDAs)
		var/obj/item/device/pda/P = A
		var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

		if (!P.owner || PM.toff || P == pda || PM.m_hidden)
			continue
		if(conversations.Find("\ref[P]"))
			convopdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "1")))
		else
			pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
		count++

	data["convopdas"] = convopdas
	data["pdas"] = pdas
	data["pda_count"] = count

	data["messagescount"] = tnote.len
	data["messages"] = tnote

	has_back = active_conversation
	if(active_conversation)
		for(var/c in tnote)
			if(c["target"] == active_conversation)
				data["convo_name"] = sanitize(c["owner"])
				data["convo_job"] = sanitize(c["job"])
				break

	var/list/plugins = list()
	if(pda.cartridge)
		for(var/A in pda.cartridge.messenger_plugins)
			var/datum/data/pda/messenger_plugin/P = A
			plugins += list(list(name = P.name, icon = P.icon, ref = "\ref[P]"))
	data["plugins"] = plugins

	if(pda.cartridge)
		data["charges"] = pda.cartridge.charges ? pda.cartridge.charges : 0

/datum/data/pda/app/messenger/Topic(href, list/href_list)
	set_new(0)

	switch(href_list["choice"])
		if("Toggle Messenger")
			toff = !toff
		if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
			silent = !silent
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
		if("Ringtone")
			var/t = input("Please enter new ringtone", name, pda.ttone) as text
			if (in_range(pda, usr) && pda.loc == usr)
				if (t)
					if(pda.hidden_uplink && pda.hidden_uplink.check_trigger(usr, lowertext(t), lowertext(pda.lock_code)))
						usr << "The PDA softly beeps."
						pda.close(usr)
					else
						t = sanitize(copytext(t, 1, 20))
						pda.ttone = t
			else
				pda.close(usr)
				return 0
		if("Message")
			var/obj/item/device/pda/P = locate(href_list["target"])
			create_message(usr, P)
			if(href_list["target"] in conversations)            // Need to make sure the message went through, if not welp.
				active_conversation = href_list["target"]
		if("Select Conversation")
			var/P = href_list["convo"]
			for(var/n in conversations)
				if(P == n)
					active_conversation = P
		if("Messenger Plugin")
			if(!href_list["target"] || !href_list["plugin"])
				return

			var/obj/item/device/pda/P = locate(href_list["target"])
			if(!P)
				usr << "PDA not found."

			var/datum/data/pda/messenger_plugin/plugin = locate(href_list["plugin"])
			if(plugin && plugin in pda.cartridge.messenger_plugins)
				plugin.messenger = src
				plugin.user_act(usr, P)
		if("Back")
			active_conversation = null

/datum/data/pda/app/messenger/proc/set_new(isnew)
	if(pda.newmessage == isnew)
		return

	if(pda.newmessage)
		//To clear message overlays.
		pda.overlays.Cut()
		pda.newmessage = 0

		icon = "comments"
		pda.update_shortcuts()
	else
		pda.overlays.Cut()
		pda.overlays += image('icons/obj/pda.dmi', "pda-r")
		pda.newmessage = 1

		icon = "comments-o"
		pda.update_shortcuts()

/datum/data/pda/app/messenger/proc/create_message(var/mob/living/U, var/obj/item/device/pda/P)
	var/t = input(U, "Please enter message", name, null) as text|null
	if(!t)
		return
	t = sanitize(copytext(t, 1, MAX_MESSAGE_LEN))
	t = readd_quotes(t)
	if (!t || !istype(P))
		return
	if (!in_range(pda, U) && pda.loc != U)
		return

	var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

	if (!PM || PM.toff || toff)
		return

	if (last_text && world.time < last_text + 5)
		return

	if(!pda.can_use())
		return

	last_text = world.time
	// check if telecomms I/O route 1459 is stable
	//var/telecomms_intact = telecomms_process(P.owner, owner, t)
	var/obj/machinery/message_server/useMS = null
	if(message_servers)
		for(var/A in message_servers)
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
			if(pos.z in signal.data["level"])
				useTC = 2
				//Let's make this barely readable
				if(signal.data["compression"] > 0)
					t = Gibberish(t, signal.data["compression"] + 50)

	if(useMS && useTC) // only send the message if it's stable
		if(useTC != 2) // Does our recipient have a broadcaster on their level?
			U << "ERROR: Cannot reach recipient."
			return
		useMS.send_pda_message("[P.owner]","[pda.owner]","[t]")
		tnote.Add(list(list("sent" = 1, "owner" = "[P.owner]", "job" = "[P.ownjob]", "message" = "[t]", "target" = "\ref[P]")))
		PM.tnote.Add(list(list("sent" = 0, "owner" = "[pda.owner]", "job" = "[pda.ownjob]", "message" = "[t]", "target" = "\ref[pda]")))
		pda.investigate_log("<span class='game say'>PDA Message - <span class='name'>[U.key] - [pda.owner]</span> -> <span class='name'>[P.owner]</span>: <span class='message'>[t]</span></span>", "pda")
		if(!conversations.Find("\ref[P]"))
			conversations.Add("\ref[P]")
		if(!PM.conversations.Find("\ref[pda]"))
			PM.conversations.Add("\ref[pda]")

		PM.play_ringtone()
		//Search for holder of the PDA.
		var/mob/living/L = null
		if(P.loc && isliving(P.loc))
			L = P.loc
		//Maybe they are a pAI!
		else
			L = get(P, /mob/living/silicon)


		if(L)
			L << "\icon[P] <b>Message from [pda.owner] ([pda.ownjob]), </b>\"[t]\" (<a href='byond://?src=\ref[P];choice=Message;skiprefresh=1;target=\ref[pda]'>Reply</a>)"
			nanomanager.update_user_uis(L, P) // Update the receiving user's PDA UI so that they can see the new message

		nanomanager.update_user_uis(U, P) // Update the sending user's PDA UI so that they can see the new message
		set_new(1)
		log_pda("[usr] (PDA: [src.name]) sent \"[t]\" to [P.name]")
	else
		U << "<span class='notice'>ERROR: Messaging server is not responding.</span>"

/datum/data/pda/app/messenger/proc/play_ringtone()
	if (!silent)
		var/S

		if(pda.ttone in ttone_sound)
			S = ttone_sound[pda.ttone]
		else
			S = 'sound/machines/twobeep.ogg'
		playsound(pda.loc, S, 50, 1)
	for(var/mob/O in hearers(3, pda.loc))
		if(!silent)
			O.show_message(text("\icon[pda] *[pda.ttone]*"))

/datum/data/pda/app/messenger/proc/available_pdas()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if (toff)
		usr << "Turn on your receiver in order to send messages."
		return

	for(var/A in PDAs)
		var/obj/item/device/pda/P = A
		var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

		if(!P.owner || !PM || PM.hidden || P == pda || PM.toff)
			continue

		var/name = P.owner
		if (name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P
	return plist

/datum/data/pda/app/messenger/proc/can_receive()
	return pda.owner && !toff && !hidden