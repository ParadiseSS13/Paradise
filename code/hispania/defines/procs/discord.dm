/proc/ryzorbot(slash, route, msg)
	if(config.ryzorbot)
		var/content = ""
		for (var/i = 1 to length(msg))
			content += "[text2ascii(msg[i])] "
		world.Export("[config.ryzorbot]/[slash]/[route]/[content]")
	return
