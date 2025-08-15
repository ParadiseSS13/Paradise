/// Config holder for all admin related things
/datum/configuration_section/admin_configuration
	protection_state = PROTECTION_READONLY // Dont even think about it
	/// Do we want to load admins from the database?
	var/use_database_admins = FALSE
	/// Do we want to auto enable admin rights if you connect from localhost?
	var/enable_localhost_autoadmin = TRUE
	/// Do we want to allow admins to set their own OOC colour?
	var/allow_admin_ooc_colour = TRUE
	/// Assoc list of admin ranks and their stuff. key: rank name string | value: list of rights
	var/list/rank_rights_map = list()
	/// Assoc list of admin ckeys and their ranks. key: ckey | value: rank name
	var/list/ckey_rank_map = list()
	/// Assoc list of admin ranks and their colours. key: rank | value: rank colour
	var/list/rank_colour_map = list()
	/// Assoc list of CIDs which shouldnt be banned due to mass collisions
	var/list/common_cid_map = list()

/datum/configuration_section/admin_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(use_database_admins, data["use_database_admins"])
	CONFIG_LOAD_BOOL(enable_localhost_autoadmin, data["enable_localhost_autoadmin"])
	CONFIG_LOAD_BOOL(allow_admin_ooc_colour, data["allow_admin_ooc_colour"])

	// Load admin rank tokens
	if(islist(data["admin_ranks"]))
		rank_rights_map.Cut()
		for(var/list/kvset in data["admin_ranks"])
			rank_rights_map[kvset["name"]] = kvset["rights"]

	// Load admin assignments
	if(islist(data["admin_assignments"]))
		ckey_rank_map.Cut()
		for(var/list/kvset in data["admin_assignments"])
			ckey_rank_map[ckey(kvset["ckey"])] = kvset["rank"]

	// Load admin colours
	if(islist(data["admin_rank_colour_map"]))
		rank_colour_map.Cut()
		for(var/list/kvset in data["admin_rank_colour_map"])
			rank_colour_map[kvset["name"]] = kvset["colour"]

	// Load common CIDs
	if(islist(data["common_cid_map"]))
		common_cid_map.Cut()
		for(var/list/kvset in data["common_cid_map"])
			common_cid_map[kvset["cid"]] = kvset["reason"]

	// For the person who asks "Why not put admin datum generation in this step?", well I will tell you why
	// Admins can be reloaded at runtime when DB edits are made and such, and I dont want an entire config reload to be part of this
	// Separation makes sense. That and in prod we use the DB anyways.
