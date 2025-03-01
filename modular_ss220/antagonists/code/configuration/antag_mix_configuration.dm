/datum/server_configuration
	var/datum/configuration_section/antag_mix_gamemode_configuration/antag_mix_gamemode

/datum/configuration_section/antag_mix_gamemode_configuration
	protection_state = PROTECTION_READONLY
	/// Antag mix budget multiplied. By default it's 1 - so budged is calculated without any modifications
	var/budget_multiplier = 1
	/// Max antag fraction defines the percent of antags relatively to ready players. Must be value between 0 and 1.
	/// 0 means that no antags can be present, 1 - all players can be antags.
	var/max_antag_fraction = 0.1
	/// Assoc list of antag scenario config tag -> list of parameters of this scenarios
	var/list/params_by_scenario = list()

/datum/server_configuration/load_all_sections()
	. = ..()
	antag_mix_gamemode = new()
	safe_load(antag_mix_gamemode, "antag_mix_gamemode_configuration")

/datum/configuration_section/antag_mix_gamemode_configuration/load_data(list/data)
	CONFIG_LOAD_NUM(budget_multiplier, data["budget_multiplier"])
	CONFIG_LOAD_NUM(max_antag_fraction, data["max_antag_fraction"])

	for(var/list/scenario_params in data["antag_scenarios_configuration"])
		var/tag = scenario_params["tag"]
		if(!tag)
			error("`tag` missing in `antag_scenarios_configuration`.")
			continue

		params_by_scenario[tag] = scenario_params["params"]
