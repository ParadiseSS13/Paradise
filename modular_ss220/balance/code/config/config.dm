/datum/configuration_section/ss220_misc_configuration
	/// Players needed to enable advanced communication (common channel limitations).
	/// Consider -1 as no threshold, so advanced communication is always disabled.
	var/advanced_communication_threshold = 40

/datum/configuration_section/ss220_misc_configuration/load_data(list/data)
	. = ..()
	CONFIG_LOAD_NUM(advanced_communication_threshold, data["advanced_communication_threshold"])
