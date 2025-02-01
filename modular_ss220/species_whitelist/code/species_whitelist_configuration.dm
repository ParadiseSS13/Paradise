/datum/server_configuration
	/// Holder for the gateway configuration datum
	var/datum/configuration_section/species_whitelist_configuration/species_whitelist

/datum/server_configuration/load_all_sections()
	. = ..()
	species_whitelist = new()
	safe_load(species_whitelist, "species_whitelist_configuration")

/datum/configuration_section/species_whitelist_configuration
	var/species_whitelist_enabled = FALSE

/datum/configuration_section/species_whitelist_configuration/load_data(list/data)
	CONFIG_LOAD_BOOL(species_whitelist_enabled, data["species_whitelist_enabled"])
