/proc/send2irc(var/channel, var/msg)
	if(config.use_irc_bot && config.irc_bot_host)
		spawn(0)
			ext_python("ircbot_message.py", "[config.comms_password] [config.irc_bot_host] [channel] [msg]")
	return

/proc/send2mainirc(var/msg)
	if(config.main_irc)
		send2irc(config.main_irc, msg)
	return

/proc/send2adminirc(var/msg)
	if(config.admin_irc)
		send2irc(config.admin_irc, msg)
	return

/hook/startup/proc/ircNotify()
	send2mainirc("Server starting up on [config.server? "byond://[config.server]" : "byond://[world.address]:[world.port]"]")
	return 1
