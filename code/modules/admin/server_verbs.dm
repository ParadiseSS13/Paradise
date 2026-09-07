USER_VERB(toggle_enter, R_SERVER, "Toggle Entering", "People can't enter", VERB_CATEGORY_SERVER)
	if(!client.is_connecting_from_localhost())
		if(tgui_alert(client, "Are you sure about this?", "Confirm", list("Yes", "No")) != "Yes")
			return

	GLOB.enter_allowed = !GLOB.enter_allowed
	if(!GLOB.enter_allowed)
		to_chat(world, "<B>New players may no longer enter the game.</B>")
	else
		to_chat(world, "<B>New players may now enter the game.</B>")
	log_admin("[key_name(client)] toggled new player game entering.")
	message_admins("[key_name_admin(client)] toggled new player game entering.", 1)
	world.update_status()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Entering") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_respawn, R_SERVER, "Toggle Respawn", "Toggle the ability for players to respawn.", VERB_CATEGORY_SERVER)
	if(!client.is_connecting_from_localhost())
		if(tgui_alert(client, "Are you sure about this?", "Confirm", list("Yes", "No")) != "Yes")
			return

	GLOB.configuration.general.respawn_enabled = !(GLOB.configuration.general.respawn_enabled)
	if(GLOB.configuration.general.respawn_enabled)
		to_chat(world, "<B>You may now respawn.</B>")
	else
		to_chat(world, "<B>You may no longer respawn</B>")
	message_admins("[key_name_admin(client)] toggled respawn to [GLOB.configuration.general.respawn_enabled ? "On" : "Off"].", 1)
	log_admin("[key_name(client)] toggled respawn to [GLOB.configuration.general.respawn_enabled ? "On" : "Off"].")
	world.update_status()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Respawn") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(delay_game, R_SERVER, "Delay", "Delay the game start/end", VERB_CATEGORY_SERVER)
	if(SSticker.current_state < GAME_STATE_STARTUP)
		alert(client, "Slow down a moment, let the ticker start first!")
		return

	if(!client.is_connecting_from_localhost())
		if(tgui_alert(client, "Are you sure about this?", "Confirm", list("Yes", "No")) != "Yes")
			return

	if(SSblackbox)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(SSticker.current_state > GAME_STATE_PREGAME)
		SSticker.delay_end = !SSticker.delay_end
		log_admin("[key_name(client)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		message_admins("[key_name(client)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].", 1)
		if(SSticker.delay_end)
			SSticker.real_reboot_time = 0 // Immediately show the "Admin delayed round end" message
		return //alert("Round end delayed", null, null, null, null, null)
	if(SSticker.ticker_going)
		SSticker.ticker_going = FALSE
		SSticker.delay_end = TRUE
		to_chat(world, "<b>The game start has been delayed.</b>")
		log_admin("[key_name(client)] delayed the game.")
	else
		SSticker.ticker_going = TRUE
		SSticker.round_start_time = world.time + SSticker.pregame_timeleft
		to_chat(world, "<b>The game will start soon.</b>")
		log_admin("[key_name(client)] removed the delay.")

USER_VERB(end_round, R_SERVER, "End Round", \
		"Instantly ends the round and brings up the scoreboard, in the same way that wizards dying do.", \
		VERB_CATEGORY_SERVER)
	var/input = sanitize(copytext_char(input(client, "What text should players see announcing the round end? Input nothing to cancel.", "Specify Announcement Text", "Shift Has Ended!"), 1, MAX_MESSAGE_LEN))

	if(!input)
		return
	if(SSticker.force_ending)
		return
	message_admins("[key_name_admin(client)] has admin ended the round with message: '[input]'")
	log_admin("[key_name(client)] has admin ended the round with message: '[input]'")
	SSticker.force_ending = TRUE
	SSticker.record_biohazard_results()
	to_chat(world, SPAN_WARNING("<big><b>[input]</b></big>"))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "End Round") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	SSticker.mode_result = "admin ended"

USER_VERB(restart_server, R_SERVER, "Restart", "Restarts the world.", VERB_CATEGORY_SERVER)
	// Give an extra popup if they are rebooting a live server
	var/is_live_server = TRUE
	if(client.is_connecting_from_localhost())
		is_live_server = FALSE

	var/list/options = list("Regular Restart", "Hard Restart")
	if(world.TgsAvailable()) // TGS lets you kill the process entirely
		options += "Terminate Process (Kill and restart DD)"

	var/result = input(client, "Select reboot method", "World Reboot", options[1]) as null|anything in options

	if(result && is_live_server)
		if(alert(client, "WARNING: THIS IS A LIVE SERVER, NOT A LOCAL TEST SERVER. DO YOU STILL WANT TO RESTART","This server is live","Restart","Cancel") != "Restart")
			return FALSE

	if(result)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Reboot World") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		var/init_by = "Initiated by [client.holder.fakekey ? "Admin" : client.key]."
		switch(result)

			if("Regular Restart")
				var/delay = input(client, "What delay should the restart have (in seconds)?", "Restart Delay", 5) as num|null
				if(!delay)
					return FALSE


				// These are pasted each time so that they dont false send if reboot is cancelled
				message_admins("[key_name_admin(client)] has initiated a server restart of type [result]")
				log_admin("[key_name(client)] has initiated a server restart of type [result]")
				SSticker.delay_end = FALSE // We arent delayed anymore
				SSticker.reboot_helper(init_by, "admin reboot - by [client.key] [client.holder.fakekey ? "(stealth)" : ""]", delay * 10)

			if("Hard Restart")
				message_admins("[key_name_admin(client)] has initiated a server restart of type [result]")
				log_admin("[key_name(client)] has initiated a server restart of type [result]")
				world.Reboot(fast_track = TRUE)

			if("Terminate Process (Kill and restart DD)")
				message_admins("[key_name_admin(client)] has initiated a server restart of type [result]")
				log_admin("[key_name(client)] has initiated a server restart of type [result]")
				world.TgsEndProcess() // Just nuke the entire process if we are royally fucked

USER_VERB(toggle_log_hrefs, R_SERVER, "Toggle href logging", "Toggle href logging", VERB_CATEGORY_SERVER)
	if(!client.is_connecting_from_localhost())
		if(tgui_alert(client, "Are you sure about this?", "Confirm", list("Yes", "No")) != "Yes")
			return

	// Why would we ever turn this off?
	if(GLOB.configuration.logging.href_logging)
		GLOB.configuration.logging.href_logging = FALSE
		to_chat(client, "<b>Stopped logging hrefs</b>")
	else
		GLOB.configuration.logging.href_logging = TRUE
		to_chat(client, "<b>Started logging hrefs</b>")

USER_VERB(toggle_antaghug_restrictions, R_SERVER, "Toggle antagHUD Restrictions", \
		"Restricts players that have used antagHUD from being able to join this round.", \
		VERB_CATEGORY_SERVER)
	if(!client.is_connecting_from_localhost())
		if(tgui_alert(client, "Are you sure about this?", "Confirm", list("Yes", "No")) != "Yes")
			return

	var/action=""
	if(GLOB.configuration.general.restrict_antag_hud_rejoin)
		for(var/mob/dead/observer/g in client.get_ghosts())
			to_chat(g, SPAN_BOLDNOTICE("The administrator has lifted restrictions on joining the round if you use AntagHUD"))
		action = "lifted restrictions"
		GLOB.configuration.general.restrict_antag_hud_rejoin = FALSE
		to_chat(client, SPAN_BOLDNOTICE("AntagHUD restrictions have been lifted"))
	else
		for(var/mob/dead/observer/g in client.get_ghosts())
			to_chat(g, SPAN_DANGER("The administrator has placed restrictions on joining the round if you use AntagHUD"))
			to_chat(g, SPAN_DANGER("Your AntagHUD has been disabled, you may choose to re-enabled it but will be under restrictions."))
			g.antagHUD = FALSE
			GLOB.antag_hud_users -= g.ckey
		action = "placed restrictions"
		GLOB.configuration.general.restrict_antag_hud_rejoin = TRUE
		to_chat(client, SPAN_DANGER("AntagHUD restrictions have been enabled"))

	log_admin("[key_name(client)] has [action] on joining the round if they use AntagHUD")
	message_admins("Admin [key_name_admin(client)] has [action] on joining the round if they use AntagHUD", 1)

USER_VERB(toggle_antaghud_use, R_SERVER, "Toggle antagHUD usage", "Toggles antagHUD usage for observers", VERB_CATEGORY_SERVER)
	var/action=""
	if(GLOB.configuration.general.allow_antag_hud)
		GLOB.antag_hud_users.Cut()
		for(var/mob/dead/observer/g in client.get_ghosts())
			if(g.antagHUD)
				g.antagHUD = FALSE						// Disable it on those that have it enabled
				to_chat(g, SPAN_DANGER("The Administrators have disabled AntagHUD."))
		GLOB.configuration.general.allow_antag_hud = FALSE
		to_chat(client, SPAN_DANGER("AntagHUD usage has been disabled"))
		action = "disabled"
	else
		for(var/mob/dead/observer/g in client.get_ghosts())
			if(!g.client.holder)						// Add the verb back for all non-admin ghosts
				to_chat(g, SPAN_BOLDNOTICE("The Administrators have enabled AntagHUD."))// Notify all observers they can now use AntagHUD

		GLOB.configuration.general.allow_antag_hud = TRUE
		action = "enabled"
		to_chat(client, SPAN_BOLDNOTICE("AntagHUD usage has been enabled"))


	log_admin("[key_name(client)] has [action] antagHUD usage for observers")
	message_admins("Admin [key_name_admin(client)] has [action] antagHUD usage for observers", 1)

USER_VERB(toggle_guests, R_SERVER, "Toggle Guests", "Guests can't enter", VERB_CATEGORY_SERVER)
	if(!client.is_connecting_from_localhost())
		if(tgui_alert(client, "Are you sure about this?", "Confirm", list("Yes", "No")) != "Yes")
			return

	GLOB.configuration.general.guest_ban = !(GLOB.configuration.general.guest_ban)
	if(GLOB.configuration.general.guest_ban)
		to_chat(world, "<B>Guests may no longer enter the game.</B>")
	else
		to_chat(world, "<B>Guests may now enter the game.</B>")
	log_admin("[key_name(client)] toggled guests game entering [GLOB.configuration?.general.guest_ban ? "dis" : ""]allowed.")
	message_admins(SPAN_NOTICE("[key_name_admin(client)] toggled guests game entering [GLOB.configuration?.general.guest_ban ? "dis" : ""]allowed."), 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Guests") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
