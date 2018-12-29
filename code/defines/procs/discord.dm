/proc/discordbot(var/url, var/slash, var/route)
	if(config.ryzorbot)
		world.Export("[url]/[slash]/[route]")
		return
	return