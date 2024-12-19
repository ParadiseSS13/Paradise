/// Config holder for all redis related things
/datum/configuration_section/redis_configuration
	protection_state = PROTECTION_PRIVATE // NO! BAD!
	/// Redis enabled or not
	var/enabled = FALSE
	/// Redis connection string. Includes passphrase if needed.
	var/connstring = "redis://127.0.0.1/"

/datum/configuration_section/redis_configuration/load_data(list/data)
	// UNIT TESTS ARE DEFINED - USE CUSTOM CI VALUES
	#ifdef GAME_TESTS

	// enabled = TRUE

	#else
	// Load the normal config. Were not in CI mode
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(enabled, data["redis_enabled"])
	CONFIG_LOAD_STR(connstring, data["redis_connstring"])
	#endif
