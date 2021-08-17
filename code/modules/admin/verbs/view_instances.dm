/client/proc/view_instances()
	set name = "View Server Instances"
	set desc = "View the running server instances"
	set category = "Server"

	if(!check_rights(R_ADMIN))
		return

	to_chat(usr, "<b>Server instances info</b>")
	for(var/datum/peer_server/PS in GLOB.configuration.instancing.peers)
		// We havnt even been discovered, so we cant even be online
		if(!PS.discovered)
			to_chat(usr, "#[PS.server_port] (Undiscovered) - <font color='red'><b>OFFLINE</b></font>")
			continue

		// We exist but arent online at the moment
		if(!PS.online)
			to_chat(usr, "ID [PS.server_id] - <font color='red'><b>OFFLINE</b></font>")
			continue

		// If we are here, we are online, so we can do a rich report
		to_chat(usr, "ID [PS.server_id] - <font color='green'><b>ONLINE</b></font> (Players: [PS.playercount])")

/client/proc/refresh_instances()
	set name = "Force Refresh Server Instances"
	set desc = "Force refresh the local cache of server instances"
	set category = "Server"

	if(!check_rights(R_SERVER))
		return

	SSinstancing.check_peers(TRUE) // Force check
