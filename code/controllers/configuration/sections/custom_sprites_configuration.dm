/// Config holder for all things regarding custom sprites
/datum/configuration_section/custom_sprites_configuration
	/// List of ckeys that have custom cyborg skins
	var/list/cyborg_ckeys = list()
	/// List of ckeys that have custom AI core skins
	var/list/ai_core_ckeys = list()
	/// List of ckeys that have custom AI hologram skins
	var/list/ai_hologram_ckeys = list()
	/// List of ckeys that have custom pAI holoforms
	var/list/pai_holoform_ckeys = list()
	/// Assoc of ckeys that have custom pAI screens. Key: ckey | value: list of icon states
	var/list/ipc_screen_map = list()

/datum/configuration_section/custom_sprites_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_LIST(cyborg_ckeys, data["cyborgs"])
	CONFIG_LOAD_LIST(ai_core_ckeys, data["ai_core"])
	CONFIG_LOAD_LIST(ai_hologram_ckeys, data["ai_hologram"])
	CONFIG_LOAD_LIST(pai_holoform_ckeys, data["pai_holoform"])

	// Load the ipc screens
	if(islist(data["ipc_screens"]))
		ipc_screen_map.Cut()
		for(var/kvp in data["ipc_screens"])
			ipc_screen_map[kvp["ckey"]] = kvp["screens"]
