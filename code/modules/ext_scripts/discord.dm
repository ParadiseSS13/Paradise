/proc/send2discord(command, channel, message)
    if (config.use_discord_bot && config.discord_host)
		spawn(1)
        	world.Export("http://[config.discord_host]/?command=[command]&channel=[channel]&message=[paranoid_sanitize(message)]")

/proc/send2maindiscord(message)
	if(config.discord_channel_main)
		send2discord("message", config.discord_channel_main, message)
	return

/proc/send2admindiscord(message)
	if(config.discord_channel_admin)
		send2discord("message", config.discord_channel_admin, message)
	return

/proc/send2mentordiscord(message)
	if(config.discord_channel_mentor)
		send2discord("message", config.discord_channel_mentor, message)
	return

/hook/startup/proc/discordNotify()
    if(config.discord_channel_main)
        send2discord("startup", config.discord_channel_main, "Server starting up on [station_name()]. Connect to: [config.server? "[config.server]" : "[world.address]:[world.port]"]")
    return 1