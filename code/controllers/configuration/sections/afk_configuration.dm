/// Config holder for all AFK related things
/datum/configuration_section/afk_configuration
	/// Minutes before someone gets an AFK warning
	var/warning_minutes = 0
	/// Minutes before someone is auto moved to cryo
	var/auto_cryo_minutes = 0
	/// Minutes before someone is auto despawned
	var/auto_despawn_minutes = 0
	/// Time before SSD people are auto cryo'd
	var/ssd_auto_cryo_minutes = 0

/datum/configuration_section/afk_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_NUM(warning_minutes, data["afk_warning_minutes"])
	CONFIG_LOAD_NUM(auto_cryo_minutes, data["afk_auto_cryo_minutes"])
	CONFIG_LOAD_NUM(auto_despawn_minutes, data["afk_auto_despawn_minutes"])
	CONFIG_LOAD_NUM(ssd_auto_cryo_minutes, data["ssd_auto_cryo_minutes"])
