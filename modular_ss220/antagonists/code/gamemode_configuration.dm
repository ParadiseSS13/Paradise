/datum/configuration_section/gamemode_configuration
	/// List of gamemodes that shouldn't be played for more than 1 round in a row.
	var/list/non_repeatable_gamemodes = list()

/datum/configuration_section/gamemode_configuration/load_data(list/data)
	..()
	var/list/non_repeatable_gamemodes_tags
	CONFIG_LOAD_LIST(non_repeatable_gamemodes_tags, data["non_repeatable_gamemodes"])

	for(var/config_tag in non_repeatable_gamemodes_tags)
		if(validate_config_tag(config_tag))
			non_repeatable_gamemodes += get_mode_by_tag(config_tag)

/// Crashes if none of the gamemodes has the given tag.
/datum/configuration_section/gamemode_configuration/proc/validate_config_tag(config_tag as text)
	if(!(config_tag in gamemodes))
		stack_trace("Gamemode [config_tag] is in non_repeatable_gamemodes but it doesn't exist!")
	return TRUE

/// Returns type of gamemode with the given tag.
/datum/configuration_section/gamemode_configuration/proc/get_mode_by_tag(config_tag as text)
	for(var/type in subtypesof(/datum/game_mode))
		var/datum/game_mode/mode = type
		if(mode::config_tag && mode::config_tag == config_tag)
			return mode

/// Returns type of gamemode with the given name.
/datum/configuration_section/gamemode_configuration/proc/get_mode_by_name(config_name as text)
	for(var/type in subtypesof(/datum/game_mode))
		var/datum/game_mode/mode = type
		if(mode::name && mode::name == config_name)
			return mode
