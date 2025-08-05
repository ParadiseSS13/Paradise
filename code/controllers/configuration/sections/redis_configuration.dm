/// Config holder for all redis related things
/datum/configuration_section/redis_configuration
	protection_state = PROTECTION_PRIVATE // NO! BAD!
	/// Redis enabled or not
	var/enabled = FALSE
	/// Redis connection string. Includes passphrase if needed.
	var/connstring = "redis://127.0.0.1/"

/datum/configuration_section/redis_configuration/load_data(list/data)
	CONFIG_LOAD_BOOL(enabled, data["redis_enabled"])
	CONFIG_LOAD_STR(connstring, data["redis_connstring"])
