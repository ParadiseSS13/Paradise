/// Config holder for all things regarding space ruins and lavaland ruins
/datum/configuration_section/ruin_configuration
	/// Enable or disable space ruins
	var/enable_space_ruins = TRUE
	/// Minimum number of extra zlevels to fill with ruins
	var/extra_levels_min = 2
	/// Maximum number of extra zlevels to fill with ruins
	var/extra_levels_max = 4
	/// List of all active space ruins
	var/list/active_space_ruins = list()
	/// List of all active lavaland ruins
	var/list/active_lava_ruins = list()
	/// Budget for lavaland ruins
	var/lavaland_ruin_budget = 60

/datum/configuration_section/ruin_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(enable_space_ruins, data["enable_space_ruins"])
	CONFIG_LOAD_NUM(extra_levels_min, data["minimum_zlevels"])
	CONFIG_LOAD_NUM(extra_levels_max, data["maximum_zlevels"])
	CONFIG_LOAD_LIST(active_space_ruins, data["active_space_ruins"])
	CONFIG_LOAD_LIST(active_lava_ruins, data["active_lava_ruins"])
	CONFIG_LOAD_NUM(lavaland_ruin_budget, data["lavaland_ruin_budget"])
