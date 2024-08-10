/datum/configuration_section/ss220_misc_configuration
	/// Server list. Name + IP
	var/list/cross_server_list = list()

/datum/configuration_section/ss220_misc_configuration/load_data(list/data)
	. = ..()
	// Load server list data
	if(islist(data["cross_server_list"]))
		cross_server_list.Cut()
		for(var/list/server as anything in data["cross_server_list"])
			cross_server_list["[server["name"]]"] = server["ip"]
