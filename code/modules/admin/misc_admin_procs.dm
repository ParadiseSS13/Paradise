GLOBAL_VAR_INIT(BSACooldown, 0)
GLOBAL_VAR_INIT(nologevent, 0)

////////////////////////////////
/proc/message_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			if(C.prefs && !(C.prefs.toggles & PREFTOGGLE_CHAT_NO_ADMINLOGS))
				to_chat(C, msg)

/proc/msg_admin_attack(text, loglevel)
	if(!GLOB.nologevent)
		var/rendered = "<span class=\"admin\"><span class=\"prefix\">ATTACK:</span> <span class=\"message\">[text]</span></span>"
		for(var/client/C in GLOB.admins)
			if((C.holder.rights & R_ADMIN) && (C.prefs?.atklog <= loglevel))
				to_chat(C, rendered)

/**
 * Sends a message to the staff able to see admin tickets
 * Arguments:
 * msg - The message being send
 * important - If the message is important. If TRUE it will ignore the CHAT_NO_TICKETLOGS preferences,
 *             send a sound and flash the window. Defaults to FALSE
 */
/proc/message_adminTicket(msg, important = FALSE)
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			if(important || (C.prefs && !(C.prefs.toggles & PREFTOGGLE_CHAT_NO_TICKETLOGS)))
				to_chat(C, msg)
			if(important)
				if(C.prefs?.sound & SOUND_ADMINHELP)
					SEND_SOUND(C, sound('sound/effects/adminhelp.ogg'))
				window_flash(C)

/**
 * Sends a message to the staff able to see mentor tickets
 * Arguments:
 * msg - The message being send
 * important - If the message is important. If TRUE it will ignore the CHAT_NO_TICKETLOGS preferences,
 *             send a sound and flash the window. Defaults to FALSE
 */
/proc/message_mentorTicket(msg, important = FALSE)
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN | R_MENTOR | R_MOD, 0, C.mob))
			if(important || (C.prefs && !(C.prefs.toggles & PREFTOGGLE_CHAT_NO_TICKETLOGS)))
				to_chat(C, msg)
			if(important)
				if(C.prefs?.sound & SOUND_MENTORHELP)
					SEND_SOUND(C, sound('sound/effects/adminhelp.ogg'))
				window_flash(C)

/proc/admin_ban_mobsearch(mob/M, ckey_to_find, mob/admin_to_notify)
	if(!M || !M.ckey)
		if(ckey_to_find)
			for(var/mob/O in GLOB.mob_list)
				if(O.ckey && O.ckey == ckey_to_find)
					if(admin_to_notify)
						to_chat(admin_to_notify, "<span class='warning'>admin_ban_mobsearch: Player [ckey_to_find] is now in mob [O]. Pulling data from new mob.</span>")
						return O
			if(admin_to_notify)
				to_chat(admin_to_notify, "<span class='warning'>admin_ban_mobsearch: Player [ckey_to_find] does not seem to have any mob, anywhere. This is probably an error.</span>")
		else if(admin_to_notify)
			to_chat(admin_to_notify, "<span class='warning'>admin_ban_mobsearch: No mob or ckey detected.</span>")
	return M

///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(mob/M in GLOB.mob_list)
	set category = null
	set name = "\[Admin\] Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.")
		return

	if(!check_rights(R_ADMIN|R_MOD))
		return

	var/body = "<html><meta charset='UTF-8'><head><title>Options for [M.key]</title></head>" // SS220 EDIT - ORIGINAL: "<html><head><title>Options for [M.key]</title></head>"
	body += "<body>Options panel for <b>[M]</b>"
	if(M.client)
		body += " played by <b>[M.client]</b> "
		if(check_rights(R_PERMISSIONS, 0))
			body += "\[<A href='?_src_=holder;editrights=rank;ckey=[M.ckey]'>[M.client.holder ? M.client.holder.rank : "Player"]</A>\] "
		else
			body += "\[[M.client.holder ? M.client.holder.rank : "Player"]\] "
		body += "\[<A href='?_src_=holder;getplaytimewindow=[M.UID()]'>" + M.client.get_exp_type(EXP_TYPE_CREW) + " as [EXP_TYPE_CREW]</a>\]"
		body += "<br>BYOND account registration date: [M.client.byondacc_date || "ERROR"] [M.client.byondacc_age <= GLOB.configuration.general.byond_account_age_threshold ? "<b>" : ""]([M.client.byondacc_age] days old)[M.client.byondacc_age <= GLOB.configuration.general.byond_account_age_threshold ? "</b>" : ""]"
		body += "<br>BYOND client version: [M.client.byond_version].[M.client.byond_build]"
		body += "<br>Global Ban DB Lookup: [GLOB.configuration.url.centcom_ban_db_url ? "<a href='?_src_=holder;open_ccbdb=[M.client.ckey]'>Lookup</a>" : "<i>Disabled</i>"]"

		body += "<br>"

	if(isnewplayer(M))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<A href='?_src_=holder;revive=[M.UID()]'>Heal</A>\] "


	body += "<br><br>\[ "
	body += "<a href='?_src_=holder;open_logging_view=[M.UID()];'>LOGS</a> - "
	body += "<a href='?_src_=vars;Vars=[M.UID()]'>VV</a> - "
	body += "[ADMIN_TP(M,"TP")] - "
	if(M.client)
		body += "<a href='?src=[usr.UID()];priv_msg=[M.client.ckey]'>PM</a> - "
		body += "[ADMIN_SM(M,"SM")] - "
	if(ishuman(M) && M.mind)
		body += "<a href='?_src_=holder;HeadsetMessage=[M.UID()]'>HM</a> - "
	body += "[admin_jump_link(M)] - "
	body += "<a href='?_src_=holder;adminalert=[M.UID()]'>SEND ALERT</a>\]</b><br>"
	body += "<b>Mob type:</b> [M.type]<br>"
	if(M.client)
		if(M.client.related_accounts_cid.len)
			body += "<b>Related accounts by CID:</b> [jointext(M.client.related_accounts_cid, " - ")]<br>"
		if(M.client.related_accounts_ip.len)
			body += "<b>Related accounts by IP:</b> [jointext(M.client.related_accounts_ip, " - ")]<br><br>"

	if(M.ckey)
		body += "<A href='?_src_=holder;boot2=[M.UID()]'>Kick</A> | "
		body += "<A href='?_src_=holder;newban=[M.UID()];dbbanaddckey=[M.ckey]'>Ban</A> | "
		body += "<A href='?_src_=holder;jobban2=[M.UID()];dbbanaddckey=[M.ckey]'>Jobban</A> | "
		body += "<A href='?_src_=holder;shownoteckey=[M.ckey]'>Notes</A> | "
		if(GLOB.configuration.url.forum_playerinfo_url)
			body += "<A href='?_src_=holder;webtools=[M.ckey]'>WebInfo</A> | "
	if(M.client)
		if(M.client.watchlisted)
			body += "<A href='?_src_=holder;watchremove=[M.ckey]'>Remove from Watchlist</A> | "
			body += "<A href='?_src_=holder;watchedit=[M.ckey]'>Edit Watchlist Reason</A> "
		else
			body += "<A href='?_src_=holder;watchadd=[M.ckey]'>Add to Watchlist</A> "

		body += "| <A href='?_src_=holder;sendtoprison=[M.UID()]'>Prison</A> | "
		body += "\ <A href='?_src_=holder;sendbacktolobby=[M.UID()]'>Send back to Lobby</A> | "
		body += "\ <A href='?_src_=holder;eraseflavortext=[M.UID()]'>Erase Flavor Text</A> | "
		body += "\ <A href='?_src_=holder;userandomname=[M.UID()]'>Use Random Name</A> | "
		body += {"<br><b>Mute: </b>
			\[<A href='?_src_=holder;mute=[M.UID()];mute_type=[MUTE_IC]'><font color='[check_mute(M.client.ckey, MUTE_IC) ? "red" : "#6685f5"]'>IC</font></a> |
			<A href='?_src_=holder;mute=[M.UID()];mute_type=[MUTE_OOC]'><font color='[check_mute(M.client.ckey, MUTE_OOC) ? "red" : "#6685f5"]'>OOC</font></a> |
			<A href='?_src_=holder;mute=[M.UID()];mute_type=[MUTE_PRAY]'><font color='[check_mute(M.client.ckey, MUTE_PRAY) ? "red" : "#6685f5"]'>PRAY</font></a> |
			<A href='?_src_=holder;mute=[M.UID()];mute_type=[MUTE_ADMINHELP]'><font color='[check_mute(M.client.ckey, MUTE_ADMINHELP) ? "red" : "#6685f5"]'>ADMINHELP</font></a> |
			<A href='?_src_=holder;mute=[M.UID()];mute_type=[MUTE_DEADCHAT]'><font color='[check_mute(M.client.ckey, MUTE_DEADCHAT) ?" red" : "#6685f5"]'>DEADCHAT</font></a> |
			<A href='?_src_=holder;mute=[M.UID()];mute_type=[MUTE_EMOTE]'><font color='[check_mute(M.client.ckey, MUTE_EMOTE) ?" red" : "#6685f5"]'>EMOTE</font></a>]
			(<A href='?_src_=holder;mute=[M.UID()];mute_type=[MUTE_ALL]'><font color='[check_mute(M.client.ckey, MUTE_ALL) ? "red" : "#6685f5"]'>toggle all</font></a>)
		"}

	var/jumptoeye = ""
	if(isAI(M))
		var/mob/living/silicon/ai/A = M
		if(A.client && A.eyeobj) // No point following clientless AI eyes
			jumptoeye = " <b>(<A href='?_src_=holder;jumpto=[A.eyeobj.UID()]'>Eye</A>)</b>"
	body += {"<br><br>
		<A href='?_src_=holder;jumpto=[M.UID()]'><b>Jump to</b></A>[jumptoeye] |
		<A href='?_src_=holder;getmob=[M.UID()]'>Get</A> |
		<A href='?_src_=holder;sendmob=[M.UID()]'>Send To</A>
		<br><br>
		[check_rights(R_ADMIN,0) ? "[ADMIN_TP(M,"Traitor panel")] | " : "" ]
		<A href='?_src_=holder;narrateto=[M.UID()]'>Narrate to</A> |
		[ADMIN_SM(M,"Subtle message")]
	"}

	if(check_rights(R_EVENT, 0))
		body += {" | <A href='?_src_=holder;Bless=[M.UID()]'>Bless</A> | <A href='?_src_=holder;Smite=[M.UID()]'>Smite</A>"}

	if(isLivingSSD(M))
		if(istype(M.loc, /obj/machinery/cryopod))
			body += {" | <A href='?_src_=holder;cryossd=[M.UID()]'>De-Spawn</A> "}
		else
			body += {" | <A href='?_src_=holder;cryossd=[M.UID()]'>Cryo</A> "}

	if(M.client)
		if(!isnewplayer(M))
			body += "<br><br>"
			body += "<b>Transformation:</b>"
			body += "<br>"

			//Monkey
			if(issmall(M))
				body += "<B>Monkeyized</B> | "
			else
				body += "<A href='?_src_=holder;monkeyone=[M.UID()]'>Monkeyize</A> | "

			//Corgi
			if(iscorgi(M))
				body += "<B>Corgized</B> | "
			else
				body += "<A href='?_src_=holder;corgione=[M.UID()]'>Corgize</A> | "

			//AI / Cyborg
			if(isAI(M))
				body += "<B>Is an AI</B> "
			else if(ishuman(M))
				body += {"<A href='?_src_=holder;makeai=[M.UID()]'>Make AI</A> |
					<A href='?_src_=holder;makerobot=[M.UID()]'>Make Robot</A> |
					<A href='?_src_=holder;makealien=[M.UID()]'>Make Alien</A> |
					<A href='?_src_=holder;makeslime=[M.UID()]'>Make Slime</A> |
					<A href='?_src_=holder;makesuper=[M.UID()]'>Make Superhero</A>
				"}

			//Simple Animals
			if(isanimal(M))
				body += "<A href='?_src_=holder;makeanimal=[M.UID()]'>Re-Animalize</A> | "
			else
				body += "<A href='?_src_=holder;makeanimal=[M.UID()]'>Animalize</A> | "

			if(isobserver(M))
				body += "<A href='?_src_=holder;incarn_ghost=[M.UID()]'>Re-incarnate</a> | "

			if(ispAI(M))
				body += "<B>Is a pAI</B> "
			else
				body += "<A href='?_src_=holder;makePAI=[M.UID()]'>Make pAI</A> | "

			// DNA2 - Admin Hax
			if(M.dna && iscarbon(M))
				body += "<br><br>"
				body += "<b>DNA Blocks:</b><br><table border='0'><tr><th>&nbsp;</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>"
				var/bname
				for(var/block in 1 to DNA_SE_LENGTH)
					if(((block-1)%5)==0)
						body += "</tr><tr><th>[block-1]</th>"
					bname = GLOB.assigned_blocks[block]
					body += "<td>"
					if(bname)
						var/bstate=M.dna.GetSEState(block)
						var/bcolor="[(bstate)?"#006600":"#ff0000"]"
						body += "<A href='?_src_=holder;togmutate=[M.UID()];block=[block]' style='color:[bcolor];'>[bname]</A><sub>[block]</sub>"
					else
						body += "[block]"
					body+="</td>"
				body += "</tr></table>"

			body += {"<br><br>
				<b>Rudimentary transformation:</b><font size=2><br>These transformations only create a new mob type and copy stuff over. They do not take into account MMIs and similar mob-specific things. The buttons in 'Transformations' are preferred, when possible.</font><br>
				<A href='?_src_=holder;simplemake=observer;mob=[M.UID()]'>Observer</A> |
				\[ Alien: <A href='?_src_=holder;simplemake=drone;mob=[M.UID()]'>Drone</A>,
				<A href='?_src_=holder;simplemake=hunter;mob=[M.UID()]'>Hunter</A>,
				<A href='?_src_=holder;simplemake=queen;mob=[M.UID()]'>Queen</A>,
				<A href='?_src_=holder;simplemake=sentinel;mob=[M.UID()]'>Sentinel</A>,
				<A href='?_src_=holder;simplemake=larva;mob=[M.UID()]'>Larva</A> \]
				<A href='?_src_=holder;simplemake=human;mob=[M.UID()]'>Human</A>
				\[ slime: <A href='?_src_=holder;simplemake=slime;mob=[M.UID()]'>Baby</A>,
				<A href='?_src_=holder;simplemake=adultslime;mob=[M.UID()]'>Adult</A> \]
				<A href='?_src_=holder;simplemake=monkey;mob=[M.UID()]'>Monkey</A> |
				<A href='?_src_=holder;simplemake=robot;mob=[M.UID()]'>Cyborg</A> |
				<A href='?_src_=holder;simplemake=cat;mob=[M.UID()]'>Cat</A> |
				<A href='?_src_=holder;simplemake=runtime;mob=[M.UID()]'>Runtime</A> |
				<A href='?_src_=holder;simplemake=corgi;mob=[M.UID()]'>Corgi</A> |
				<A href='?_src_=holder;simplemake=ian;mob=[M.UID()]'>Ian</A> |
				<A href='?_src_=holder;simplemake=crab;mob=[M.UID()]'>Crab</A> |
				<A href='?_src_=holder;simplemake=coffee;mob=[M.UID()]'>Coffee</A> |
				\[ Construct: <A href='?_src_=holder;simplemake=constructarmoured;mob=[M.UID()]'>Armoured</A> ,
				<A href='?_src_=holder;simplemake=constructbuilder;mob=[M.UID()]'>Builder</A> ,
				<A href='?_src_=holder;simplemake=constructwraith;mob=[M.UID()]'>Wraith</A> \]
				<A href='?_src_=holder;simplemake=shade;mob=[M.UID()]'>Shade</A>
			"}

	if(M.client)
		body += {"<br><br>
			<b>Other actions:</b>
			<br>
			<A href='?_src_=holder;forcespeech=[M.UID()]'>Forcesay</A> |
			<A href='?_src_=holder;aroomwarp=[M.UID()]'>Admin Room</A> |
			<A href='?_src_=holder;tdome1=[M.UID()]'>Thunderdome 1</A> |
			<A href='?_src_=holder;tdome2=[M.UID()]'>Thunderdome 2</A> |
			<A href='?_src_=holder;tdomeadmin=[M.UID()]'>Thunderdome Admin</A> |
			<A href='?_src_=holder;tdomeobserve=[M.UID()]'>Thunderdome Observer</A> |
			<A href='?_src_=holder;contractor_stop=[M.UID()]'>Stop Syndicate Jail Timer</A> |
			<A href='?_src_=holder;contractor_start=[M.UID()]'>Start Syndicate Jail Timer</A> |
			<A href='?_src_=holder;contractor_release=[M.UID()]'>Release now from Syndicate Jail</A> |
		"}

	body += {"<br>
		</body></html>
	"}

	usr << browse(body, "window=adminplayeropts;size=550x615")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Player Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/player_info/var/author // admin who authored the information
/datum/player_info/var/rank //rank of admin who made the notes
/datum/player_info/var/content // text content of the information
/datum/player_info/var/timestamp // Because this is bloody annoying

#define PLAYER_NOTES_ENTRIES_PER_PAGE 50
/datum/admins/proc/PlayerNotes()
	set category = "Admin"
	set name = "Player Notes"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	show_note()

/datum/admins/proc/show_player_notes(key as text)
	set category = "Admin"
	set name = "Show Player Notes"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	show_note(key)

/datum/admins/proc/vpn_whitelist()
	set category = "Admin"
	set name = "VPN Ckey Whitelist"
	if(!check_rights(R_BAN))
		return
	var/key = stripped_input(usr, "Enter ckey to add/remove, or leave blank to cancel:", "VPN Whitelist add/remove", max_length=32)
	if(key)
		GLOB.ipintel_manager.vpn_whitelist_panel(key)

/datum/admins/proc/Game()
	if(!check_rights(R_ADMIN))
		return

	var/list/dat = list()
	var/cached_UID = UID()
	dat += "<center>"
	dat += "<p><a href='?src=[cached_UID];c_mode=1'>Change Game Mode</a><br></p>"
	if(GLOB.master_mode == "secret")
		dat += "<p><a href='?src=[cached_UID];f_secret=1'>(Force Secret Mode)</a><br></p>"
	dat += "<hr><br>"
	dat += "<p><a href='?src=[cached_UID];create_object=1'>Create Object</a><br></p>"
	dat += "<p><a href='?src=[cached_UID];quick_create_object=1'>Quick Create Object</a><br></p>"
	dat += "<p><a href='?src=[cached_UID];create_turf=1'>Create Turf</a><br></p>"
	dat += "<p><a href='?src=[cached_UID];create_mob=1'>Create Mob</a></p>"

	var/datum/browser/popup = new(usr, "game_panel", "<div align='center'>Game Panel</div>", 210, 280)
	popup.set_content(dat.Join(""))
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
	popup.open()
	onclose(usr, "game_panel")
	return

/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc = "Restarts the world."

	if(!check_rights(R_SERVER))
		return

	// Give an extra popup if they are rebooting a live server
	var/is_live_server = TRUE
	if(usr.client.is_connecting_from_localhost())
		is_live_server = FALSE

	var/list/options = list("Regular Restart", "Hard Restart")
	if(world.TgsAvailable()) // TGS lets you kill the process entirely
		options += "Terminate Process (Kill and restart DD)"

	var/result = input(usr, "Select reboot method", "World Reboot", options[1]) as null|anything in options

	if(is_live_server)
		if(alert(usr, "WARNING: THIS IS A LIVE SERVER, NOT A LOCAL TEST SERVER. DO YOU STILL WANT TO RESTART","This server is live","Restart","Cancel") != "Restart")
			return FALSE

	if(result)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Reboot World") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		var/init_by = "Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]."
		switch(result)

			if("Regular Restart")
				var/delay = input("What delay should the restart have (in seconds)?", "Restart Delay", 5) as num|null
				if(!delay)
					return FALSE


				// These are pasted each time so that they dont false send if reboot is cancelled
				message_admins("[key_name_admin(usr)] has initiated a server restart of type [result]")
				log_admin("[key_name(usr)] has initiated a server restart of type [result]")
				SSticker.delay_end = FALSE // We arent delayed anymore
				SSticker.reboot_helper(init_by, "admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]", delay * 10)

			if("Hard Restart")
				message_admins("[key_name_admin(usr)] has initiated a server restart of type [result]")
				log_admin("[key_name(usr)] has initiated a server restart of type [result]")
				world.Reboot(fast_track = TRUE)

			if("Terminate Process (Kill and restart DD)")
				message_admins("[key_name_admin(usr)] has initiated a server restart of type [result]")
				log_admin("[key_name(usr)] has initiated a server restart of type [result]")
				world.TgsEndProcess() // Just nuke the entire process if we are royally fucked

/datum/admins/proc/end_round()
	set category = "Server"
	set name = "End Round"
	set desc = "Instantly ends the round and brings up the scoreboard, in the same way that wizards dying do."
	if(!check_rights(R_SERVER))
		return
	var/input = sanitize(copytext_char(input(usr, "What text should players see announcing the round end? Input nothing to cancel.", "Specify Announcement Text", "Shift Has Ended!"), 1, MAX_MESSAGE_LEN))	// SS220 EDIT - ORIGINAL: copytext

	if(!input)
		return
	if(SSticker.force_ending)
		return
	message_admins("[key_name_admin(usr)] has admin ended the round with message: '[input]'")
	log_admin("[key_name(usr)] has admin ended the round with message: '[input]'")
	SSticker.force_ending = TRUE
	to_chat(world, "<span class='warning'><big><b>[input]</b></big></span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "End Round") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	SSticker.mode_result = "admin ended"

/datum/admins/proc/announce()
	set category = "Admin"
	set name = "Announce"
	set desc = "Announce your desires to the world"

	if(!check_rights(R_ADMIN))
		return

	var/message = input("Global message to send:", "Admin Announce", null, null) as message|null
	if(message)
		if(!check_rights(R_SERVER,0))
			message = adminscrub(message,500)
		message = replacetext(message, "\n", "<br>") // required since we're putting it in a <p> tag
		to_chat(world, chat_box_notice("<span class='notice'><b>[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:</b><br><br><p>[message]</p></span>"))
		log_admin("Announce: [key_name(usr)] : [message]")
		for(var/client/clients_to_alert in GLOB.clients)
			window_flash(clients_to_alert)
			if(clients_to_alert.prefs?.sound & SOUND_ADMINHELP)
				SEND_SOUND(clients_to_alert, sound('sound/effects/adminhelp.ogg'))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Announce") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Globally Toggles OOC"
	set name="Toggle OOC"

	if(!check_rights(R_ADMIN))
		return

	toggle_ooc()
	log_and_message_admins("toggled OOC.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle OOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/togglelooc()
	set category = "Server"
	set desc="Globally Toggles LOOC"
	set name="Toggle LOOC"

	if(!check_rights(R_ADMIN))
		return

	GLOB.looc_enabled = !(GLOB.looc_enabled)
	if(GLOB.looc_enabled)
		to_chat(world, "<B>The LOOC channel has been globally enabled!</B>")
	else
		to_chat(world, "<B>The LOOC channel has been globally disabled!</B>")
	log_and_message_admins("toggled LOOC.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle LOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggledsay()
	set category = "Server"
	set desc="Globally Toggles DSAY"
	set name="Toggle DSAY"

	if(!check_rights(R_ADMIN))
		return

	GLOB.dsay_enabled = !(GLOB.dsay_enabled)
	if(GLOB.dsay_enabled)
		to_chat(world, "<B>Deadchat has been globally enabled!</B>")
	else
		to_chat(world, "<B>Deadchat has been globally disabled!</B>")
	log_admin("[key_name(usr)] toggled deadchat.")
	message_admins("[key_name_admin(usr)] toggled deadchat.", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Deadchat") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc

/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle Dead OOC."
	set name="Toggle Dead OOC"

	if(!check_rights(R_ADMIN))
		return

	GLOB.dooc_enabled = !(GLOB.dooc_enabled)
	log_admin("[key_name(usr)] toggled Dead OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Dead OOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleemoji()
	set category = "Server"
	set desc = "Toggle OOC Emoji"
	set name = "Toggle OOC Emoji"

	if(!check_rights(R_ADMIN))
		return

	GLOB.configuration.general.enable_ooc_emoji = !(GLOB.configuration.general.enable_ooc_emoji)
	log_admin("[key_name(usr)] toggled OOC Emoji.")
	message_admins("[key_name_admin(usr)] toggled OOC Emoji.", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle OOC Emoji")

/datum/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"

	if(!check_rights(R_SERVER))
		return

	if(!SSticker)
		alert("Unable to start the game as it is not set up.")
		return

	if(GLOB.configuration.general.start_now_confirmation)
		if(alert(usr, "This is a live server. Are you sure you want to start now?", "Start game", "Yes", "No") != "Yes")
			return

	if(SSticker.current_state == GAME_STATE_PREGAME || SSticker.current_state == GAME_STATE_STARTUP)
		SSticker.force_start = TRUE
		log_admin("[usr.key] has started the game.")
		var/msg = ""
		if(SSticker.current_state == GAME_STATE_STARTUP)
			msg = " (The server is still setting up, but the round will be started as soon as possible.)"
		message_admins("<span class='darkmblue'>[usr.key] has started the game.[msg]</span>")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Start Game") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return 1
	else
		to_chat(usr, "<font color='red'>Error: Start Now: Game has already started.</font>")
		return

/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"

	if(!check_rights(R_SERVER))
		return

	GLOB.enter_allowed = !( GLOB.enter_allowed )
	if(!( GLOB.enter_allowed ))
		to_chat(world, "<B>New players may no longer enter the game.</B>")
	else
		to_chat(world, "<B>New players may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled new player game entering.")
	message_admins("[key_name_admin(usr)] toggled new player game entering.", 1)
	world.update_status()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Entering") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleAI()
	set category = "Event"
	set desc="People can't be AI"
	set name="Toggle AI"

	if(!check_rights(R_EVENT))
		return


	GLOB.configuration.jobs.allow_ai = !(GLOB.configuration.jobs.allow_ai)
	if(!GLOB.configuration.jobs.allow_ai)
		to_chat(world, "<B>The AI job is no longer chooseable.</B>")
	else
		to_chat(world, "<B>The AI job is chooseable now.</B>")
	message_admins("[key_name_admin(usr)] toggled AI allowed.")
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle AI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleaban()
	set category = "Server"
	set desc="Toggle the ability for players to respawn."
	set name="Toggle Respawn"

	if(!check_rights(R_SERVER))
		return

	GLOB.configuration.general.respawn_enabled = !(GLOB.configuration.general.respawn_enabled)
	if(GLOB.configuration.general.respawn_enabled)
		to_chat(world, "<B>You may now respawn.</B>")
	else
		to_chat(world, "<B>You may no longer respawn</B>")
	message_admins("[key_name_admin(usr)] toggled respawn to [GLOB.configuration.general.respawn_enabled ? "On" : "Off"].", 1)
	log_admin("[key_name(usr)] toggled respawn to [GLOB.configuration.general.respawn_enabled ? "On" : "Off"].")
	world.update_status()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Respawn") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay()
	set category = "Server"
	set desc="Delay the game start/end"
	set name="Delay"

	if(!check_rights(R_SERVER))
		return

	if(!SSticker || SSticker.current_state != GAME_STATE_PREGAME)
		SSticker.delay_end = !SSticker.delay_end
		log_admin("[key_name(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		message_admins("[key_name(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].", 1)
		if(SSticker.delay_end)
			SSticker.real_reboot_time = 0 // Immediately show the "Admin delayed round end" message
		return //alert("Round end delayed", null, null, null, null, null)
	if(SSticker.ticker_going)
		SSticker.ticker_going = FALSE
		SSticker.delay_end = TRUE
		to_chat(world, "<b>The game start has been delayed.</b>")
		log_admin("[key_name(usr)] delayed the game.")
	else
		SSticker.ticker_going = TRUE
		to_chat(world, "<b>The game will start soon.</b>")
		log_admin("[key_name(usr)] removed the delay.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Delay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/**
  * A proc that return whether the mob is a "Special Character" aka Antagonist
  *
  * Arguments:
  * * M - the mob you're checking
  */
/proc/is_special_character(mob/M)
	if(!SSticker.mode)
		return FALSE
	if(!istype(M))
		return FALSE
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.emagged)
			return TRUE
	if(M.mind?.special_role)//If they have a mind and special role, they are some type of traitor or antagonist.
		return TRUE
	return FALSE

/**
  * A proc that return an array of capitalized strings containing name of the antag types they are
  *
  * Arguments:
  * * M - the mob you're checking
  */
/proc/get_antag_type_strings_list(mob/M) // return an array of all the antag types they are with name
	var/list/antag_list = list()

	if(!SSticker.mode || !istype(M) || !M.mind)
		return FALSE

	if(M.mind.has_antag_datum(/datum/antagonist/rev/head))
		antag_list += "Head Rev"
	if(M.mind.has_antag_datum(/datum/antagonist/rev, FALSE))
		antag_list += "Revolutionary"
	if(M.mind in SSticker.mode.cult)
		antag_list += "Cultist"
	if(M.mind in SSticker.mode.syndicates)
		antag_list += "Nuclear Operative"
	if(M.mind in SSticker.mode.wizards)
		antag_list += "Wizard"
	if(M.mind in SSticker.mode.changelings)
		antag_list += "Changeling"
	if(M.mind in SSticker.mode.abductors)
		antag_list += "Abductor"
	if(M.mind.has_antag_datum(/datum/antagonist/vampire))
		antag_list += "Vampire"
	if(M.mind.has_antag_datum(/datum/antagonist/mindslave/thrall))
		antag_list += "Vampire Thrall"
	if(M.mind.has_antag_datum(/datum/antagonist/traitor))
		antag_list += "Traitor"
	if(M.mind.has_antag_datum(/datum/antagonist/mindslave, FALSE))
		antag_list += "Mindslave"
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.emagged)
			antag_list += "Emagged Borg"
	if(!length(antag_list) && M.mind.special_role) // Snowflake check. If none of the above but still special, then other antag. Technically not accurate.
		antag_list += "Other Antag(s)"
	return antag_list

/**
  * A proc that return a string containing all the singled out antags . Empty string if not antag
  *
  * Usually, you'd return a FALSE, but since this is consumed by javascript you're in
  * for a world of hurt if you pass a byond FALSE which get converted into a fucking string anyway and pass for TRUE in check. Fuck.
  * It always append "(May be other antag)"
  * Arguments:
  * * M - the mob you're checking
  * *
  */
/proc/get_antag_type_truncated_plaintext_string(mob/M as mob)
	var/list/antag_list = get_antag_type_strings_list(M)

	if(length(antag_list))
		return antag_list.Join(" &amp; ") + " " + "(May be other antag)"

	return ""

/datum/admins/proc/spawn_atom(object as text)
	set category = "Debug"
	set desc = "(atom path) Spawn an atom. Append a period to the text in order to exclude subtypes of paths matching the input."
	set name = "Spawn"

	if(!check_rights(R_SPAWN))
		return

	if(!object)
		return

	var/list/types = typesof(/atom)
	var/list/matches = new()

	var/include_subtypes = TRUE
	if(copytext(object, -1) == ".")
		include_subtypes = FALSE
		object = copytext(object, 1, -1)

	if(include_subtypes)
		for(var/path in types)
			if(findtext("[path]", object))
				matches += path
	else
		var/needle_length = length(object)
		for(var/path in types)
			if(copytext("[path]", -needle_length) == object)
				matches += path

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
		if(!chosen)
			return

	if(ispath(chosen,/turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		var/atom/A = new chosen(usr.loc)
		A.admin_spawned = TRUE

	log_admin("[key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z])")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Atom") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/show_traitor_panel(mob/M in GLOB.mob_list)
	set category = "Admin"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind!")
		return

	M.mind.edit_memory()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Traitor Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle Guests"

	if(!check_rights(R_SERVER))
		return

	GLOB.configuration.general.guest_ban = !(GLOB.configuration.general.guest_ban)
	if(GLOB.configuration.general.guest_ban)
		to_chat(world, "<B>Guests may no longer enter the game.</B>")
	else
		to_chat(world, "<B>Guests may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled guests game entering [GLOB.configuration?.general.guest_ban ? "dis" : ""]allowed.")
	message_admins("<span class='notice'>[key_name_admin(usr)] toggled guests game entering [GLOB.configuration?.general.guest_ban ? "dis" : ""]allowed.</span>", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Guests") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/mob/living/silicon/S in GLOB.mob_list)
		ai_number++
		if(isAI(S))
			to_chat(usr, "<b>AI [key_name(S, TRUE)]'s laws:</b>")
		else if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			to_chat(usr, "<b>CYBORG [key_name(S, TRUE)]'s [R.connected_ai?"(Slaved to: [R.connected_ai])":"(Independent)"] laws:</b>")
		else if(ispAI(S))
			var/mob/living/silicon/pai/P = S
			to_chat(usr, "<b>pAI [key_name(S, TRUE)]'s laws:</b>")
			to_chat(usr, "[P.pai_law0]")
			if(P.pai_laws)
				to_chat(usr, "[P.pai_laws]")
			continue // Skip showing normal silicon laws for pAIs - they don't have any
		else
			to_chat(usr, "<b>SILICON [key_name(S, TRUE)]'s laws:</b>")

		if(S.laws == null)
			to_chat(usr, "[key_name(S, TRUE)]'s laws are null. Contact a coder.")
		else
			S.laws.show_laws(usr)
	if(!ai_number)
		to_chat(usr, "<b>No AI's located.</b>")//Just so you know the thing is actually working and not just ignoring you.


	log_admin("[key_name(usr)] checked the AI laws")
	message_admins("[key_name_admin(usr)] checked the AI laws")

/client/proc/update_mob_sprite(mob/living/carbon/human/H as mob)
	set name = "\[Admin\] Update Mob Sprite"
	set desc = "Should fix any mob sprite update errors."
	set category = null

	if(!check_rights(R_ADMIN))
		return

	if(istype(H))
		H.regenerate_icons()

//
//
//ALL DONE
//*********************************************************************************************************

GLOBAL_VAR_INIT(gamma_ship_location, 1) // 0 = station , 1 = space

/proc/move_gamma_ship()
	var/area/fromArea
	var/area/toArea
	if(GLOB.gamma_ship_location == 1)
		fromArea = locate(/area/shuttle/gamma/space)
		toArea = locate(/area/shuttle/gamma/station)
		for(var/obj/machinery/door/poddoor/impassable/gamma/H in GLOB.airlocks)
			H.open()
		GLOB.major_announcement.Announce("Central Command has deployed the Gamma Armory shuttle.", new_sound = 'sound/AI/commandreport.ogg')
	else
		fromArea = locate(/area/shuttle/gamma/station)
		toArea = locate(/area/shuttle/gamma/space)
		for(var/obj/machinery/door/poddoor/impassable/gamma/H in GLOB.airlocks)
			H.close() //DOOR STUCK
		GLOB.major_announcement.Announce("Central Command has recalled the Gamma Armory shuttle.", new_sound = 'sound/AI/commandreport.ogg')
	fromArea.move_contents_to(toArea)

	for(var/obj/machinery/mech_bay_recharge_port/P in toArea)
		P.update_recharge_turf()

	if(GLOB.gamma_ship_location)
		GLOB.gamma_ship_location = 0
	else
		GLOB.gamma_ship_location = 1
	return

/proc/formatJumpTo(location, where="")
	var/turf/loc
	if(isturf(location))
		loc = location
	else
		loc = get_turf(location)
	if(where=="")
		where=formatLocation(loc)
	return "<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>[where]</a>"

/proc/formatLocation(location)
	var/turf/loc
	if(isturf(location))
		loc = location
	else
		loc = get_turf(location)
	var/area/A = get_area(location)
	return "[A.name] - [loc.x],[loc.y],[loc.z]"

/proc/formatPlayerPanel(mob/U, text="PP")
	return "[ADMIN_PP(U,"[text]")]"

//Kicks all the clients currently in the lobby. The second parameter (kick_only_afk) determins if an is_afk() check is ran, or if all clients are kicked
//defaults to kicking everyone (afk + non afk clients in the lobby)
//returns a list of ckeys of the kicked clients
/proc/kick_clients_in_lobby(message, kick_only_afk = 0)
	var/list/kicked_client_names = list()
	for(var/client/C in GLOB.clients)
		if(isnewplayer(C.mob))
			if(kick_only_afk && !C.is_afk())	//Ignore clients who are not afk
				continue
			if(message)
				to_chat(C, message)
			kicked_client_names.Add("[C.ckey]")
			qdel(C)
	return kicked_client_names

//returns 1 to let the dragdrop code know we are trapping this event
//returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/dead/observer/frommob, atom/tothing)
	if(!istype(frommob))
		return //extra sanity check to make sure only observers are shoved into things

	//same as assume-direct-control perm requirements.
	if(!check_rights(R_VAREDIT,0)) //no varedit, check if they have r_admin and r_debug
		if(!check_rights(R_ADMIN|R_DEBUG,0)) //if they don't have r_admin and r_debug, return
			return FALSE //otherwise, if they have no varedit, but do have r_admin and r_debug, execute the rest of the code

	if(!frommob.ckey)
		return FALSE

	if(isitem(tothing))
		var/mob/living/toitem = tothing

		var/ask = alert("Are you sure you want to allow [frommob.name]([frommob.key]) to possess [toitem.name]?", "Place ghost in control of item?", "Yes", "No")
		if(ask != "Yes")
			return TRUE

		if(!frommob || !toitem) //make sure the mobs don't go away while we waited for a response
			return TRUE

		var/mob/living/simple_animal/possessed_object/tomob = new(toitem)

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] has put [frommob.ckey] in control of [tomob.name].</span>")
		log_admin("[key_name(usr)] stuffed [frommob.ckey] into [tomob.name].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag")

		tomob.ckey = frommob.ckey
		qdel(frommob)


	if(isliving(tothing))
		var/mob/living/tomob = tothing

		var/question = ""
		if(tomob.ckey)
			question = "This mob already has a user ([tomob.key]) in control of it! "
		question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"

		var/ask = alert(question, "Place ghost in control of mob?", "Yes", "No")
		if(ask != "Yes")
			return TRUE

		if(!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
			return TRUE

		if(tomob.client) //no need to ghostize if there is no client
			tomob.ghostize(0)

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] has put [frommob.ckey] in control of [tomob.name].</span>")
		log_admin("[key_name(usr)] stuffed [frommob.ckey] into [tomob.name].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag")

		tomob.ckey = frommob.ckey
		qdel(frommob)

		return TRUE

	if(istype(tothing, /obj/structure/AIcore/deactivated))

		var/question = "Are you sure you want to place [frommob.name]([frommob.key]) in control of an empty AI core?"

		var/ask = alert(question, "Place ghost in control of an empty AI core?", "Yes", "No")
		if(ask != "Yes")
			return TRUE

		if(QDELETED(frommob) || QDELETED(tothing)) //make sure the mobs don't go away while we waited for a response
			return TRUE

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] has put [frommob.ckey] in control of an empty AI core.</span>")
		log_admin("[key_name(usr)] stuffed [frommob.ckey] into an empty AI core.")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag")

		var/transfer_key = frommob.key // frommob is qdel'd in frommob.AIize()
		var/mob/living/silicon/ai/ai_character = frommob.AIize()
		ai_character.key = transfer_key // this wont occur in mind transferring if the mind is not active, which causes some weird stuff. This fixes it.
		GLOB.empty_playable_ai_cores -= tothing

		ai_character.forceMove(get_turf(tothing))
		ai_character.view_core()

		qdel(tothing)

		return TRUE

// Returns a list of the number of admins in various categories
// result[1] is the number of staff that match the rank mask and are active
// result[2] is the number of staff that do not match the rank mask
// result[3] is the number of staff that match the rank mask and are inactive
/proc/staff_countup(rank_mask = R_BAN)
	var/list/result = list(0, 0, 0)
	for(var/client/X in GLOB.admins)
		if(rank_mask && !check_rights_for(X, rank_mask))
			result[2]++
			continue
		if(X.holder.fakekey)
			result[2]++
			continue
		if(X.is_afk())
			result[3]++
			continue
		result[1]++
	return result
