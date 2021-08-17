/// Config holder for stuff relating to multi-server instances
/datum/configuration_section/instancing_configuration
	/// ID of this specific server
	var/server_id = "paradise_main"
	/// List of all peer servers
	var/list/datum/peer_server/peers = list()

/datum/configuration_section/instancing_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_STR(server_id, data["server_id"])

	if(islist(data["peer_servers"]))
		for(var/list/server in data["peer_servers"])
			if(server["server_port"] == world.port) // Skip our own instance
				continue
			var/datum/peer_server/PS = new()
			PS.internal_ip = server["internal_ip"]
			PS.server_port = server["server_port"]
			PS.commskey = server["commskey"]
			peers.Add(PS)
