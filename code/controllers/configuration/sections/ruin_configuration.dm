/// Config holder for all things regarding space ruins and lavaland ruins
/datum/configuration_section/ruin_configuration
	/// Whether or not *all* zlevel generation besides the station and Centcomm should be skipped.
	var/enable_zlevels = TRUE
	/// Enable or disable all ruins, including lavaland ruins and lavaland tendrils.
	var/enable_space_ruins = TRUE
	/// Minimum number of extra space zlevels to generate
	var/minimum_space_zlevels = 2
	/// Maximum number of extra space zlevels to generate
	var/maximum_space_zlevels = 4
	/// Minimum number of extra lavaland zlevels to generate
	var/minimum_lavaland_zlevels = 2
	/// Maximum number of extra lavaland zlevels to generate
	var/maximum_lavaland_zlevels = 2
	/// List of all active space ruins
	var/list/active_space_ruins = list()
	/// List of all active lavaland ruins
	var/list/active_lava_ruins = list()
	/// Minimum budget for space ruins
	var/space_ruin_budget_min = 750
	/// Maximum budget for space ruins
	var/space_ruin_budget_max = 1000
	/// Minimum budget for lavaland ruins
	var/lavaland_ruin_budget_min = 175
	/// Maximum budget for lavaland ruins
	var/lavaland_ruin_budget_max = 325

/datum/configuration_section/ruin_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(enable_zlevels, data["enable_zlevels"])
	CONFIG_LOAD_BOOL(enable_space_ruins, data["enable_space_ruins"])
	CONFIG_LOAD_NUM(minimum_space_zlevels, data["minimum_space_zlevels"])
	CONFIG_LOAD_NUM(maximum_space_zlevels, data["maximum_space_zlevels"])
	CONFIG_LOAD_NUM(minimum_lavaland_zlevels, data["minimum_lavaland_zlevels"])
	CONFIG_LOAD_NUM(maximum_lavaland_zlevels, data["maximum_lavaland_zlevels"])
	CONFIG_LOAD_LIST(active_space_ruins, data["active_space_ruins"])
	CONFIG_LOAD_LIST(active_lava_ruins, data["active_lava_ruins"])
	CONFIG_LOAD_NUM(space_ruin_budget_min, data["space_ruin_budget_min"])
	CONFIG_LOAD_NUM(space_ruin_budget_max, data["space_ruin_budget_max"])
	CONFIG_LOAD_NUM(lavaland_ruin_budget_min, data["lavaland_ruin_budget_min"])
	CONFIG_LOAD_NUM(lavaland_ruin_budget_max, data["lavaland_ruin_budget_max"])

	// TODO -- TEMPORARY FOR TM -- REMOVE BEFORE MERGE
	active_lava_ruins += "_maps/map_files/RandomRuins/LavaRuins/lavaland_surface_miningbase.dmm"
	active_lava_ruins += "_maps/map_files/RandomRuins/LavaRuins/lavaland_surface_gulag.dmm"
	active_lava_ruins += "_maps/map_files/RandomRuins/LavaRuins/lavaland_surface_legiongate.dmm"
	// TODO -- TEMPORARY FOR TM -- REMOVE BEFORE MERGE
