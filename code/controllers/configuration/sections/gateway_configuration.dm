/// Config holder for all gateway related things
/datum/configuration_section/gateway_configuration
	/// Do we want to enable away missions or not
	var/enable_away_mission = TRUE
	/// Delay (in deciseconds) before the gateway is usable
	var/away_mission_delay = 6000
	/// List of all available away missions
	var/list/enabled_away_missions = list()

/datum/configuration_section/gateway_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(enable_away_mission, data["enable_away_mission"])
	CONFIG_LOAD_NUM(away_mission_delay, data["away_mission_delay"])
	CONFIG_LOAD_LIST(enabled_away_missions, data["enabled_away_missions"])
