//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M as mob in GLOB.mob_list)
	set category = null
	set name = "Admin PM Mob"
	if(!holder)
		to_chat(src, "<span class='danger'>Error: Admin-PM-Context: Only administrators may use this command.</span>")
		return
	if( !ismob(M) || !M.client )	return
	cmd_admin_pm(M.client,null)
	feedback_add_details("admin_verb","APMM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM Name"
	if(!holder)
		to_chat(src, "<span class='danger'>Error: Admin-PM-Panel: Only administrators may use this command.</span>")
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(istype(T.mob, /mob/new_player))
				targets["(New Player) - [T]"] = T
			else if(istype(T.mob, /mob/dead/observer))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) in sorted|null
	cmd_admin_pm(targets[target],null)
	feedback_add_details("admin_verb","APM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_by_key_panel()
	set category = "Admin"
	set name = "Admin PM Key"
	if(!holder)
		to_chat(src, "<span class='danger'>Error: Admin-PM-Panel: Only administrators may use this command.</span>")
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(istype(T.mob, /mob/new_player))
				targets["[T] - (New Player)"] = T
			else if(istype(T.mob, /mob/dead/observer))
				targets["[T] - [T.mob.name](Ghost)"] = T
			else
				targets["[T] - [T.mob.real_name](as [T.mob.name])"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) in sorted|null
	cmd_admin_pm(targets[target],null)
	feedback_add_details("admin_verb","APM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client
/client/proc/cmd_admin_pm(whom, msg, type = "PM")
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<span class='danger'>Error: Private-Message: You are unable to use PM-s (muted).</span>")
		return

	var/client/C
	if(istext(whom))
		if(cmptext(copytext(whom,1,2),"@"))
			whom = findStealthKey(whom)
		C = GLOB.directory[whom]
	else if(istype(whom,/client))
		C = whom

	if(!C)
		if(holder)
			to_chat(src, "<span class='danger'>Error: Private-Message: Client not found.</span>")
		else
			adminhelp(msg)	//admin we are replying to left. adminhelp instead
		return

	/*if(C && C.last_pm_recieved + config.simultaneous_pm_warning_timeout > world.time && holder)
		//send a warning to admins, but have a delay popup for mods
		if(holder.rights & R_ADMIN)
			to_chat(src, "<span class='danger'>Simultaneous PMs warning:</span> that player has been PM'd in the last [config.simultaneous_pm_warning_timeout / 10] seconds by: [C.ckey_last_pm]")
		else
			if(alert("That player has been PM'd in the last [config.simultaneous_pm_warning_timeout / 10] seconds by: [C.ckey_last_pm]","Simultaneous PMs warning","Continue","Cancel") == "Cancel")
				return*/

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		set_typing(C, TRUE)
		msg = clean_input("Message:", "Private message to [holder ? key_name(C, FALSE) : key_name_hidden(C, FALSE)]", , src)
		set_typing(C, FALSE)

		if(!msg)
			return
		if(!C)
			if(holder)
				to_chat(src, "<span class='danger'>Error: Admin-PM: Client not found.</span>")
			else
				adminhelp(msg)	//admin we are replying to has vanished, adminhelp instead
			return

	if(handle_spam_prevention(msg, MUTE_ADMINHELP, OOC_COOLDOWN))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG,0))
		msg = sanitize_simple(copytext(msg,1,MAX_MESSAGE_LEN))
		if(!msg)
			return
	else
		msg = admin_pencode_to_html(msg)

	var/recieve_span = "playerreply"
	var/send_pm_type = " "
	var/recieve_pm_type = "Player"


	if(holder)
		//mod PMs are maroon
		//PMs sent from admins and mods display their rank
		if(holder)
			if(check_rights(R_MOD|R_MENTOR,0) && !check_rights(R_ADMIN,0))
				recieve_span = "mentorhelp"
			else
				recieve_span = "adminhelp"
			send_pm_type = holder.rank + " "
			recieve_pm_type = holder.rank

	else if(!C.holder)
		to_chat(src, "<span class='danger'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</span>")
		return

	var/recieve_message = ""

	pm_tracker.add_message(C, src, msg, mob)
	C.pm_tracker.add_message(src, src, msg, C.mob)

	if(holder && !C.holder)
		recieve_message = "<span class='[recieve_span]' size='3'>-- Click the [recieve_pm_type]'s name to reply --</span>\n"
		if(C.adminhelped)
			window_flash(C)
			to_chat(C, recieve_message)
			C.adminhelped = 0

		//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
		if(config.popup_admin_pm)
			spawn(0)	//so we don't hold the caller proc up
				var/sender = src
				var/sendername = key
				var/reply = clean_input(msg,"[recieve_pm_type] [type] from-[sendername]", "", C)		//show message and await a reply
				if(C && reply)
					if(sender)
						C.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
					else
						adminhelp(reply)													//sender has left, adminhelp instead
				return


	var/emoji_msg = "<span class='emoji_enabled'>[msg]</span>"
	recieve_message = "<span class='[recieve_span]'>[type] from-<b>[recieve_pm_type][C.holder ? key_name(src, TRUE, type) : key_name_hidden(src, TRUE, type)]</b>: [emoji_msg]</span>"
	to_chat(C, recieve_message)
	var/ping_link = check_rights(R_ADMIN, 0, mob) ? "(<a href='?src=[pm_tracker.UID()];ping=[C.key]'>PING</a>)" : ""
	var/window_link = "(<a href='?src=[pm_tracker.UID()];newtitle=[C.key]'>WINDOW</a>)"
	to_chat(src, "<span class='pmsend'>[send_pm_type][type] to-<b>[holder ? key_name(C, TRUE, type) : key_name_hidden(C, TRUE, type)]</b>: [emoji_msg]</span> [ping_link] [window_link]")

	/*if(holder && !C.holder)
		C.last_pm_recieved = world.time
		C.ckey_last_pm = ckey*/

	//play the recieving admin the adminhelp sound (if they have them enabled)
	//non-admins always hear the sound, as they cannot toggle it
	if((!C.holder) || (C.prefs.sound & SOUND_ADMINHELP))
		C << 'sound/effects/adminhelp.ogg'

	log_admin("PM: [key_name(src)]->[key_name(C)]: [msg]")
	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/X in GLOB.admins)
		//check client/X is an admin and isn't the sender or recipient
		if(X == C || X == src)
			continue
		if(X.key != key && X.key != C.key)
			switch(type)
				if("Mentorhelp")
					if(check_rights(R_ADMIN|R_MOD|R_MENTOR, 0, X.mob))
						to_chat(X, "<span class='mentorhelp'>[type]: [key_name(src, TRUE, type)]-&gt;[key_name(C, TRUE, type)]: [emoji_msg]</span>")
				if("Adminhelp")
					if(check_rights(R_ADMIN|R_MOD, 0, X.mob))
						to_chat(X, "<span class='adminhelp'>[type]: [key_name(src, TRUE, type)]-&gt;[key_name(C, TRUE, type)]: [emoji_msg]</span>")
				else
					if(check_rights(R_ADMIN|R_MOD, 0, X.mob))
						to_chat(X, "<span class='boldnotice'>[type]: [key_name(src, TRUE, type)]-&gt;[key_name(C, TRUE, type)]: [emoji_msg]</span>")

	//Check if the mob being PM'd has any open admin tickets.
	var/tickets = list()
	if(type == "Mentorhelp")
		tickets = SSmentor_tickets.checkForTicket(C)
	else
		tickets = SStickets.checkForTicket(C)
	if(tickets)
		for(var/datum/ticket/i in tickets)
			i.addResponse(src, msg) // Add this response to their open tickets.
		return
	if(type == "Mentorhelp")
		if(check_rights(R_ADMIN|R_MOD|R_MENTOR, 0, C.mob)) //Is the person being pm'd an admin? If so we check if the pm'er has open tickets
			tickets = SSmentor_tickets.checkForTicket(src)
	else // Ahelp
		if(check_rights(R_ADMIN|R_MOD, 0, C.mob)) //Is the person being pm'd an admin? If so we check if the pm'er has open tickets
			tickets = SStickets.checkForTicket(src)

	if(tickets)
		for(var/datum/ticket/i in tickets)
			i.addResponse(src, msg)
		return


/client/proc/cmd_admin_irc_pm()
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<span class='danger'>Error: Private-Message: You are unable to use PM-s (muted).</span>")
		return

	var/msg = clean_input("Message:", "Private message to admins on IRC / 400 character limit", , src)

	if(!msg)
		return

	sanitize(msg)

	if(length(msg) > 400) // TODO: if message length is over 400, divide it up into seperate messages, the message length restriction is based on IRC limitations.  Probably easier to do this on the bots ends.
		to_chat(src, "<span class='warning'>Your message was not sent because it was more then 400 characters find your message below for ease of copy/pasting</span>")
		to_chat(src, "<span class='notice'>[msg]</span>")
		return

	send2adminirc("PlayerPM from [key_name(src)]: [html_decode(msg)]")

	to_chat(src, "<span class='pmsend'>IRC PM to-<b>IRC-Admins</b>: [msg]</span>")

	log_admin("PM: [key_name(src)]->IRC: [msg]")
	for(var/client/X in GLOB.admins)
		if(X == src)
			continue
		if(check_rights(R_ADMIN|R_MOD|R_MENTOR, 0, X.mob))
			to_chat(X, "<B><span class='pmsend'>PM: [key_name(src, TRUE, 0)]-&gt;IRC-Admins:</B> <span class='notice'>[msg]</span></span>")

/client/verb/open_pms_ui()
	set name = "My PMs"
	set category = "OOC"
	pm_tracker.show_ui(usr)

/client/proc/set_typing(client/target, value)
	if(!target)
		return
	var/datum/pm_convo/convo = target.pm_tracker.pms[key]
	if(!convo)
		return
	convo.typing = value
	if(target.pm_tracker.open && target.pm_tracker.current_title == key)
		target.pm_tracker.show_ui(target.mob)

/datum/pm_tracker
	var/current_title = ""
	var/open = FALSE
	var/list/pms = list()
	var/show_archived = FALSE
	var/window_id = "pms_window"

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
	var/dat = ""

	dat += "<a href='?src=[UID()];refresh=1'>Refresh</a>"
	dat += "<a href='?src=[UID()];showarchived=1'>[show_archived ? "Hide" : "Show"] Archived</a>"
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
		dat += "<a class='[class]' href='?src=[UID()];newtitle=[title]'>[label]</a>"

	var/datum/pm_convo/convo = pms[current_title]
	var/datum/browser/popup = new(user, window_id, "Messages", 1000, 600, src)
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
		dat += "<a href='?src=[UID()];reply=[current_title]'>Reply</a>"
		dat += "<a href='?src=[UID()];archive=[current_title]'>[convo.archived ? "Unarchive" : "Archive"]</a>"
		if(check_rights(R_ADMIN, FALSE, user))
			dat += "<a href='?src=[UID()];ping=[current_title]'>Ping</a>"

	popup.set_content(dat)
	popup.open()
	open = TRUE

/datum/pm_tracker/proc/fancy_title(title)
	var/client/C = pms[title].client || update_client(title)
	if(!C)
		return "[title] (Disconnected)"
	return "[key_name(C, FALSE)] ([ADMIN_QUE(C.mob,"?")]) ([ADMIN_PP(C.mob,"PP")]) ([ADMIN_VV(C.mob,"VV")]) ([ADMIN_TP(C.mob,"TP")]) ([ADMIN_SM(C.mob,"SM")]) ([admin_jump_link(C.mob)])"

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

	if(href_list["newtitle"])
		current_title = href_list["newtitle"]
		show_ui(usr)
		return

	if(href_list["ping"])
		var/client/C = pms[href_list["ping"]].client
		if(C)
			C.pm_tracker.current_title = usr.key
			window_flash(C)
			C.pm_tracker.show_ui(C.mob)
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
