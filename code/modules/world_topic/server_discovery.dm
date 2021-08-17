/datum/world_topic_handler/server_discovery
	topic_key = "server_discovery"
	requires_commskey = TRUE

/datum/world_topic_handler/server_discovery/execute(list/input, key_valid)
	// We need to send the stuff to make a /datum/peer_server on the other side
	var/list/server_data = list()
	server_data["external_ip"] = world.internet_address
	server_data["server_id"] = GLOB.configuration.instancing.server_id
	server_data["server_name"] = GLOB.configuration.general.server_name
	server_data["playercount"] = length(GLOB.clients)
	return json_encode(server_data)
