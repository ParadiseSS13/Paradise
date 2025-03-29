/datum/configuration_section/ss220_misc_configuration

/datum/configuration_section/ss220_misc_configuration/load_data(list/data)
	return

/datum/server_configuration
	/// Contains all the misc configuration values
	var/datum/configuration_section/ss220_misc_configuration/ss220_misc

/datum/server_configuration/load_all_sections()
	. = ..()
	ss220_misc = new()
	safe_load(ss220_misc, "ss220_misc_configuration")
	GLOB.blocked_chems += list("serpadrone")
