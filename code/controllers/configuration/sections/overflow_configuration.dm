/// Config holder for all overflow-server related things
/datum/configuration_section/overflow_configuration
	/// Amount of players before reroute server is used. 0 to disable.
	var/reroute_cap = 0
	/// Location of the overflow server
	var/overflow_server_location = null
	/// List of ckeys who will never be routed to the overflow server
	var/list/overflow_whitelist = list()

/datum/configuration_section/overflow_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_NUM(reroute_cap, data["player_reroute_cap"])
	CONFIG_LOAD_STR(overflow_server_location, data["overflow_server"])
	CONFIG_LOAD_LIST(overflow_whitelist, data["overflow_whitelist"])
