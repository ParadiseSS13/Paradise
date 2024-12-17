/datum/configuration_section/ss220_misc_configuration
	/// Whether or not player speech will be filtered
	var/enable_speech_filter = FALSE
	/// Set of player ckeys that bypass speech filter
	var/list/speech_filter_bypass = list()

/datum/configuration_section/ss220_misc_configuration/load_data(list/data)
	. = ..()
	CONFIG_LOAD_BOOL(enable_speech_filter, data["enable_speech_filter"])

	var/list/filter_bypass
	CONFIG_LOAD_LIST(filter_bypass, data["speech_filter_bypass"])
	for(var/whitelisted_ckey in filter_bypass)
		speech_filter_bypass[ckey(whitelisted_ckey)] = TRUE
