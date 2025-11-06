//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M as mob in GLOB.mob_list)
	set name = "\[Admin\] Admin PM Mob"
	if(!check_rights(R_ADMIN|R_MENTOR))
		return
	if(!ismob(M) || !M.client)
		return
	cmd_admin_pm(M.client,null)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin PM Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM Name"
	if(!check_rights(R_ADMIN|R_MENTOR))
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(isnewplayer(T.mob))
				targets["(New Player) - [T]"] = T
			else if(isobserver(T.mob))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) as null|anything in sorted
	if(!target)
		return
	cmd_admin_pm(targets[target],null)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin PM Name") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_by_key_panel()
	set category = "Admin"
	set name = "Admin PM Key"
	if(!check_rights(R_ADMIN|R_MENTOR))
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T?.holder?.big_brother && !check_rights(R_PERMISSIONS, FALSE))		// normal admins can't see BB
			continue
		if(T.mob)
			if(isnewplayer(T.mob))
				targets["[T] - (New Player)"] = T
			else if(isobserver(T.mob))
				targets["[T] - [T.mob.name](Ghost)"] = T
			else
				targets["[T] - [T.mob.real_name](as [T.mob.name])"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) as null|anything in sorted
	if(!target)
		return
	cmd_admin_pm(targets[target],null)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin PM Key") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client
/client/proc/cmd_admin_pm(whom, msg, type = "PM", ticket_id = -1)
	if(check_mute(ckey, MUTE_ADMINHELP))
		to_chat(src, "<span class='danger'>Error: Private-Message: You are unable to use PM-s (muted).</span>")
		return

	var/client/C
	if(istext(whom))
		C = get_client_by_ckey(whom)
	else if(isclient(whom))
		C = whom

	if(!C)
		if(holder)
			to_chat(src, "<span class='danger'>Error: Private-Message: Client not found.</span>")
		else
			adminhelp(msg)	//admin we are replying to left. adminhelp instead
		return

	/*if(C && C.last_pm_received + config.simultaneous_pm_warning_timeout > world.time && holder)
		//send a warning to admins, but have a delay popup for mods
		if(holder.rights & R_ADMIN)
			to_chat(src, "<span class='danger'>Simultaneous PMs warning:</span> that player has been PM'd in the last [config.simultaneous_pm_warning_timeout / 10] seconds by: [C.ckey_last_pm]")
		else
			if(alert("That player has been PM'd in the last [config.simultaneous_pm_warning_timeout / 10] seconds by: [C.ckey_last_pm]","Simultaneous PMs warning","Continue","Cancel") == "Cancel")
				return*/

	var/send_span
	var/receive_span
	var/send_pm_type = " "
	var/receive_pm_type = "Player"
	var/message_type
	var/datum/controller/subsystem/tickets/tickets_system
	// We treat PMs as mentorhelps if we were explicitly so, or if neither
	// party is an admin.
	if(type == "Mentorhelp" || !(check_rights(R_ADMIN|R_MOD, 0, C.mob) || check_rights(R_ADMIN|R_MOD, 0, mob)))
		send_span = "mentorhelp"
		receive_span = "mentorhelp"
		message_type = MESSAGE_TYPE_MENTORPM
		tickets_system = SSmentor_tickets
	else
		send_span = "adminhelp"
		receive_span = "adminhelp"
		message_type = MESSAGE_TYPE_ADMINPM
		tickets_system = SStickets

	//Check if the mob being PM'd has any open tickets.
	var/list/tickets = tickets_system.checkForTicket(C, ticket_id)
	if(!length(tickets))
		// If we didn't find a specific ticket by the target mob, we check for
		// tickets by the source mob.
		if(message_type == MESSAGE_TYPE_MENTORPM)
			if(check_rights(R_ADMIN|R_MOD|R_MENTOR, 0, C.mob))
				tickets = SSmentor_tickets.checkForTicket(src)
		else
			if(check_rights(R_ADMIN|R_MOD, 0, C.mob))
				tickets = SStickets.checkForTicket(src)

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		set_typing(C, TRUE)
		tickets_system.refresh_tickets(tickets)
		msg = clean_input("Message:", "Private message to [holder ? key_name(C, FALSE) : key_name_hidden(C, FALSE)]", null, src)
		set_typing(C, FALSE)

		if(!msg)
			tickets_system.refresh_tickets(tickets)
			return
		if(!C)
			if(holder)
				to_chat(src, "<span class='danger'>Error: Admin-PM: Client not found.</span>")
			else
				adminhelp(msg)	//admin we are replying to has vanished, adminhelp instead
			return

	if(handle_spam_prevention(msg, MUTE_ADMINHELP, OOC_COOLDOWN))
		return

	// Limit msg length
	if(!check_rights(R_ADMIN, FALSE))
		msg = copytext_char(msg, 1, 2048)

	// Let high-rank admins use advanced pencode.
	if(check_rights(R_SERVER|R_DEBUG, 0))
		msg = admin_pencode_to_html(msg)

	if(holder)
		//PMs sent from admins and mods display their rank
		send_pm_type = holder.rank + " "
		receive_pm_type = holder.rank

	else if(!C.holder)
		to_chat(src, "<span class='danger'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</span>")
		return

	var/receive_message = ""

	persistent.pm_tracker.add_message(C, src, msg, mob)
	C.persistent.pm_tracker.add_message(src, src, msg, C.mob)

	if(holder && !C.holder)
		receive_message = "<span class='[receive_span]' size='3'>-- Click the [receive_pm_type]'s name to reply --</span>\n"
		to_chat(C, receive_message)
		if(message_type == MESSAGE_TYPE_ADMINPM)
			// Try to get their attention if they're alt-tabbed.
			window_flash(C)

		//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
		if(GLOB.configuration.general.popup_admin_pm)
			spawn(0)	//so we don't hold the caller proc up
				var/sender = src
				var/sendername = key
				var/reply = clean_input(msg,"[receive_pm_type] [type] from-[sendername]", "", C)		//show message and await a reply
				if(C && reply)
					if(sender)
						C.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
					else
						adminhelp(reply)													//sender has left, adminhelp instead
				return

	var/ping_link = check_rights(R_ADMIN, 0, mob) ? "(<a href='byond://?src=[persistent.pm_tracker.UID()];ping=[C.key]'>PING</a>)" : ""
	var/ticket_link
	var/alert_link = check_rights(R_ADMIN, FALSE, mob) ? "(<a href='byond://?src=[persistent.pm_tracker.UID()];adminalert=[C.mob.UID()]'>ALERT</a>)" : ""
	var/observe_link = check_rights(R_MENTOR, FALSE, mob) ? "([ADMIN_OBS(C, "OBS")])" : ""
	if(ticket_id != -1)
		if(message_type == MESSAGE_TYPE_MENTORPM)
			ticket_link = "(<a href='byond://?_src_=holder;openticket=[ticket_id];is_mhelp=1'>TICKET</a>)"
		else
			ticket_link = "(<a href='byond://?_src_=holder;openticket=[ticket_id]'>TICKET</a>)"

	var/emoji_msg = "<span class='emoji_enabled'>[msg]</span>"
	var/receive_window_link = "(<a href='byond://?src=[C.persistent.pm_tracker.UID()];newtitle=[key]'>WINDOW</a>)"
	if(message_type == MESSAGE_TYPE_MENTORPM && check_rights(R_ADMIN|R_MENTOR, 0, C.mob))
		receive_window_link = ticket_link
	else if(message_type == MESSAGE_TYPE_ADMINPM && check_rights(R_ADMIN, 0, C.mob))
		receive_window_link = ticket_link
	receive_message = "<span class='[receive_span]'>[type] from-<b>[receive_pm_type] [C.holder ? key_name(src, TRUE, type, ticket_id = ticket_id) : key_name_hidden(src, TRUE, type, ticket_id = ticket_id)]</b>:<br><br>[emoji_msg][C.holder ? "<br>[ping_link] [receive_window_link] [alert_link] [observe_link]" : ""]</span>"
	if(message_type == MESSAGE_TYPE_MENTORPM)
		receive_message = chat_box_mhelp(receive_message)
	else
		receive_message = chat_box_ahelp(receive_message)
	to_chat(C, receive_message)
	if(C != src)
		var/send_window_link = "(<a href='byond://?src=[persistent.pm_tracker.UID()];newtitle=[C.key]'>WINDOW</a>)"
		if(message_type == MESSAGE_TYPE_MENTORPM && check_rights(R_ADMIN|R_MENTOR, 0, mob))
			send_window_link = ticket_link
		else if(message_type == MESSAGE_TYPE_ADMINPM && check_rights(R_ADMIN, 0, mob))
			send_window_link = ticket_link
		var/send_message = "<span class='[send_span]'>[send_pm_type][type] to-<b>[holder ? key_name(C, TRUE, type, ticket_id = ticket_id) : key_name_hidden(C, TRUE, type, ticket_id = ticket_id)]</b>:<br><br>[emoji_msg]</span><br>[ping_link] [send_window_link] [alert_link] [observe_link]"
		if(message_type == MESSAGE_TYPE_MENTORPM)
			send_message = chat_box_mhelp(send_message)
		else
			send_message = chat_box_ahelp(send_message)
		to_chat(src, send_message)

	var/third_party_message
	if(message_type == MESSAGE_TYPE_MENTORPM)
		third_party_message = chat_box_mhelp("<span class='mentorhelp'>[type]: [key_name(src, TRUE, type, ticket_id = ticket_id)]-&gt;[key_name(C, TRUE, type, ticket_id = ticket_id)]:<br><br>[emoji_msg]<br>[ping_link] [ticket_link] [alert_link] [observe_link]</span>")
	else
		third_party_message = chat_box_ahelp("<span class='adminhelp'>[type]: [key_name(src, TRUE, type, ticket_id = ticket_id)]-&gt;[key_name(C, TRUE, type, ticket_id = ticket_id)]:<br><br>[emoji_msg]<br>[ping_link] [ticket_link] [alert_link] [observe_link]</span>")

	//play the recieving admin the adminhelp sound (if they have them enabled)
	//non-admins always hear the sound, as they cannot toggle it
	if((!C.holder) || (C.prefs.sound & SOUND_ADMINHELP))
		if(message_type == MESSAGE_TYPE_MENTORPM)
			SEND_SOUND(C, sound('sound/machines/notif1.ogg'))
		else
			SEND_SOUND(C, sound('sound/effects/adminhelp.ogg'))

	log_admin("PM: [key_name(src)]->[key_name(C)]: [msg]")
	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/X in GLOB.admins)
		//check client/X is an admin and isn't the sender or recipient
		if(X == C || X == src)
			continue
		if(X.key != key && X.key != C.key)
			if(message_type == MESSAGE_TYPE_MENTORPM)
				if(check_rights(R_ADMIN|R_MOD|R_MENTOR, 0, X.mob))
					to_chat(X, third_party_message, MESSAGE_TYPE_MENTORPM)
			else
				if(check_rights(R_ADMIN|R_MOD, 0, X.mob))
					to_chat(X, third_party_message, MESSAGE_TYPE_ADMINPM)

	if(length(tickets))
		tickets_system.addResponse(tickets, src, msg)

/client/proc/cmd_admin_discord_pm()
	if(check_mute(ckey, MUTE_ADMINHELP))
		to_chat(src, "<span class='danger'>Error: Private-Message: You are unable to use PMs (muted).</span>")
		return

	if(last_discord_pm_time > world.time)
		to_chat(usr, "<span class='warning'>Please wait [(last_discord_pm_time - world.time)/10] seconds, or for a reply, before sending another PM to Discord.</span>")
		return

	// We only allow PMs once every 10 seconds, othewrise the channel can get spammed very quickly
	last_discord_pm_time = world.time + 10 SECONDS

	var/msg = clean_input("Message:", "Private message to admins on Discord / 400 character limit", null, src)

	if(!msg)
		return

	sanitize(msg)

	if(length(msg) > 400) // Dont want them super spamming
		to_chat(src, "<span class='warning'>Your message was not sent because it was more then 400 characters find your message below for ease of copy/pasting</span>")
		to_chat(src, "<span class='notice'>[msg]</span>")
		return

	GLOB.discord_manager.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "PM from [key_name(src)]: [html_decode(msg)]")

	to_chat(src, "<span class='discordpm'>PM to-<b>Discord Admins</b>: [msg]</span>", MESSAGE_TYPE_ADMINPM, confidential = TRUE)

	log_admin("PM: [key_name(src)]->Discord: [msg]")
	for(var/client/X in GLOB.admins)
		if(X == src)
			continue
		if(check_rights(R_ADMIN, 0, X.mob))
			to_chat(X, "<span class='discordpm'><b>PM: [key_name_admin(src)]-&gt;Discord Admins:</b> <span class='notice'>[msg]</span></span>")

/client/verb/open_pms_ui()
	set name = "My PMs"
	set category = "OOC"
	persistent.pm_tracker.show_ui(usr)

/client/proc/set_typing(client/target, value)
	if(!target)
		return
	var/datum/pm_convo/convo = target.persistent.pm_tracker.pms[key]
	if(!convo)
		convo = new /datum/pm_convo(src)
		target.persistent.pm_tracker.pms[key] = convo
	convo.typing = value
	if(target.persistent.pm_tracker.open && target.persistent.pm_tracker.current_title == key)
		target.persistent.pm_tracker.show_ui(target.mob)

/datum/pm_tracker
	var/ckey
	var/current_title = ""
	var/open = FALSE
	var/list/datum/pm_convo/pms = list()
	var/show_archived = FALSE
	var/window_id = "pms_window"
	var/forced = FALSE

/datum/pm_tracker/New(ckey_in)
	ckey = ckey_in

/datum/pm_convo
	var/list/messages = list()
	var/archived = FALSE
	var/client/client
	var/read = FALSE
	var/typing = FALSE

/datum/pm_convo/New(client/C)
	client = C

/datum/pm_convo/proc/add(client/sender, message)
	messages.Add("[sender]: [message]")
	archived = FALSE
	read = FALSE

/datum/pm_tracker/proc/add_message(client/title, client/sender, message, mob/user)
	if(!pms[title.key])
		pms[title.key] = new /datum/pm_convo(title)
	else if(!pms[title.key].client)
		// If they DCed earlier, we need to add the client reference back
		pms[title.key].client = title
	pms[title.key].add(sender, message)

	if(!open)
		// The next time the window's opened, it'll be open to the most recent message
		current_title = title.key
		return

	// If it's already opened, it'll refresh
	show_ui(user)

/datum/pm_tracker/proc/show_ui(mob/user)
	// Please do not open someone else's PMs, that makes them not very private.
	if(user.ckey != ckey)
		return

	var/dat = ""

	// If it was forced open, make them use a special close button that alerts admins to closure
	if(forced)
		dat += "<div style='float: right'><big><a href='byond://?src=[UID()];altclose=1'>Close</a></big></div>"

	dat += "<a href='byond://?src=[UID()];refresh=1'>Refresh</a>"
	dat += "<a href='byond://?src=[UID()];showarchived=1'>[show_archived ? "Hide" : "Show"] Archived</a>"
	dat += "<br>"
	for(var/title in pms)
		if(pms[title].archived && !show_archived)
			continue
		var/label = "[title]"
		var/class = ""
		if(title == current_title)
			label = "<b>[label]</b>"
			class = "linkOn"
		else if(!pms[title].read)
			label = "<i>*[label]</i>"
		dat += "<a class='[class]' href='byond://?src=[UID()];newtitle=[title]'>[label]</a>"

	var/datum/pm_convo/convo = pms[current_title]
	var/datum/browser/popup = new(user, window_id, "Messages", 1000, 600, src)

	if(forced) // Lockout the normal close button, force the UI one
		popup.set_window_options("can_close=0")

	if(convo)
		popup.add_head_content(@{"<script type='text/javascript'>
			window.onload = function () {
				var msgs = document.getElementById('msgs');
				msgs.scrollTop = msgs.scrollHeight;
			}
			</script>"})
		convo.read = TRUE
		dat += "<h2>[check_rights(R_ADMIN, FALSE, user) ? fancy_title(current_title) : current_title]</h2>"
		dat += "<h4>"
		dat += "<div id='msgs' style='width:950px; border: 3px solid; overflow-y: scroll; height: 350px;'>"
		dat += "<table>"

		for(var/message in convo.messages)
			dat += "<tr><td>[message]</td></tr>"

		dat += "</table>"
		dat += "</div>"
		if(convo.typing)
			dat += "<i><span class='typing'>[current_title] is typing</span></i>"
		dat += "<br>"
		dat += "</h4>"
		dat += "<a href='byond://?src=[UID()];reply=[current_title]'>Reply</a>"
		dat += "<a href='byond://?src=[UID()];archive=[current_title]'>[convo.archived ? "Unarchive" : "Archive"]</a>"
		if(check_rights(R_ADMIN, FALSE, user))
			dat += "<a href='byond://?src=[UID()];ping=[current_title]'>Ping</a>"

	popup.set_content(dat)
	popup.open()
	open = TRUE

/datum/pm_tracker/proc/fancy_title(title)
	var/client/C = pms[title].client || update_client(title)
	if(!C)
		return "[title] (Disconnected)"
	return "[key_name(C, FALSE)] ([ADMIN_QUE(C.mob,"?")]) ([ADMIN_PP(C.mob,"PP")]) ([ADMIN_VV(C.mob,"VV")]) ([ADMIN_TP(C.mob,"TP")]) ([ADMIN_SM(C.mob,"SM")]) ([admin_jump_link(C.mob)]) ([ADMIN_ALERT(C.mob,"SEND ALERT")])"

/datum/pm_tracker/proc/update_client(title)
	var/client/C = GLOB.directory[ckey(title)]
	if(C)
		pms[title].client = C
		return C
	return null

/datum/pm_tracker/Topic(href, href_list)
	if(href_list["archive"])
		pms[href_list["archive"]].archived = !pms[href_list["archive"]].archived
		show_ui(usr)
		return

	if(href_list["refresh"])
		show_ui(usr)
		return

	if(href_list["altclose"])
		message_admins("[key_name_admin(usr)] closed a force-opened PM window")
		usr << browse(null, "window=[window_id]")
		open = FALSE
		forced = FALSE
		return

	if(href_list["newtitle"])
		current_title = href_list["newtitle"]
		show_ui(usr)
		return

	if(href_list["adminalert"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/about_to_be_banned = locateUID(href_list["adminalert"])
		usr.client.cmd_admin_alert_message(about_to_be_banned)

	if(href_list["ping"])
		var/client/C = pms[href_list["ping"]].client
		if(C)
			C.persistent.pm_tracker.current_title = usr.key
			C.persistent.pm_tracker.forced = TRUE // We forced it open
			window_flash(C)
			C.persistent.pm_tracker.show_ui(C.mob)
			to_chat(usr, "<span class='notice'>Forced open [C]'s messages window.</span>")
		return

	if(href_list["reply"])
		usr.client.cmd_admin_pm(ckey(href_list["reply"]), null)
		show_ui(usr)
		return

	if(href_list["showarchived"])
		show_archived = !show_archived
		show_ui(usr)
		return

	if(href_list["close"])
		open = FALSE
		return
