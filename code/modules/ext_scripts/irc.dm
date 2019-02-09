/proc/send2irc(var/channel, var/msg, var/lesser_sanitize = FALSE)
	if(config.use_irc_bot && config.irc_bot_host.len)
		for(var/IP in config.irc_bot_host)
			spawn(0)
				if(lesser_sanitize == 7355608) // Super random number because this could be bad if done accidentally
					// Runs sanitization but allows <> and // (Needed for discord)
					ext_python("ircbot_message.py", "[config.comms_password] [IP] [channel] [not_as_paranoid_sanitize(msg)]")
				else
					// I have no means of trusting you, cmd
					ext_python("ircbot_message.py", "[config.comms_password] [IP] [channel] [paranoid_sanitize(msg)]")
	return

/proc/send2mainirc(var/msg, var/lesser_sanitize = FALSE)
	if(config.main_irc)
		send2irc(config.main_irc, msg, lesser_sanitize)
	return

/proc/send2adminirc(var/msg)
	if(config.admin_irc)
		send2irc(config.admin_irc, msg)
	return

/hook/startup/proc/ircNotify()
	var/people_to_ping = ""
	var/DBQuery/pull_notify = dbcon.NewQuery("SELECT discord_id FROM [format_table_name("discord")] WHERE notify = 1")
	if(!pull_notify.Execute())
		var/err = pull_notify.ErrorMsg()
		log_game("SQL ERROR while pulling notify people. Error : \[[err]\]\n")
	else
		while(pull_notify.NextRow())
			people_to_ping += "<@" + pull_notify.item[1] + "> "
	send2mainirc("Server starting up on [station_name()]. Connect to: <byond://[config.server? "[config.server]" : "[world.address]:[world.port]"]> "+people_to_ping, 7355608)
	// Set notify to 0 so people arent pinged round after round
	var/DBQuery/reset_notify = dbcon.NewQuery("UPDATE [format_table_name("discord")] SET notify = 0 WHERE notify = 1")
	if(!reset_notify.Execute())
		var/err = reset_notify.ErrorMsg()
		log_game("SQL ERROR while resetting notify status. Error : \[[err]\]\n")
	return 1
