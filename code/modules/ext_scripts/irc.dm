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
