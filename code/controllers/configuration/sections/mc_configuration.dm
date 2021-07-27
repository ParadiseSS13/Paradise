/// Config holder for all things regarding the MC
/datum/configuration_section/mc_configuration
	/// Server ticklag
	var/ticklag = 0.5
	/// Tick limit % during world Init
	var/world_init_tick_limit = TICK_LIMIT_MC_INIT_DEFAULT
	/// Base MC tick rate
	var/base_tickrate = 1
	/// Highpop MC tickrate
	var/highpop_tickrate = 1.1
	/// MC Highpop enable threshold
	var/highpop_enable_threshold = 65
	/// MC Highpop disable threshold
	var/highpop_disable_threshold = 60

/datum/configuration_section/mc_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_NUM(ticklag, data["ticklag"])
	CONFIG_LOAD_NUM(world_init_tick_limit, data["world_init_mc_tick_limit"])
	CONFIG_LOAD_NUM(base_tickrate, data["base_mc_tick_rate"])
	CONFIG_LOAD_NUM(highpop_tickrate, data["highpop_mc_tick_rate"])
	CONFIG_LOAD_NUM(highpop_enable_threshold, data["mc_highpop_threshold_enable"])
	CONFIG_LOAD_NUM(highpop_disable_threshold, data["mc_highpop_threshold_disable"])
