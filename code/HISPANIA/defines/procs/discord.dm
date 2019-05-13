/proc/ryzorbot(var/slash, var/route)
	if(config.ryzorbot)
		world.Export("[config.ryzorbot]/[slash]/[route]")
		return
	return