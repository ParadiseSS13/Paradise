// Paradise SS13 Configuration System
// Refactored to use config sections as part of a single TOML file, since thats much better to deal with

/// Global configuration datum holder for all the config sections
GLOBAL_DATUM_INIT(configuration, /datum/server_configuration, new())

/// Represents a base configuration datum. Has everything else bundled into it
/datum/server_configuration
	/// Holder for the admin configuration datum
	var/datum/configuration_section/admin_configuration/admin
	/// Holder for the AFK configuration datum
	var/datum/configuration_section/afk_configuration/afk
	/// Holder for the custom sprites configuration datum
	var/datum/configuration_section/custom_sprites_configuration/custom_sprites
	/// Holder for the DB configuration datum
	var/datum/configuration_section/database_configuration/database
	/// Holder for the Discord configuration datum
	var/datum/configuration_section/discord_configuration/discord
	/// Holder for the Event configuration datum
	var/datum/configuration_section/event_configuration/event
	/// Holder for the gamemode configuration datum
	var/datum/configuration_section/gamemode_configuration/gamemode
	/// Holder for the general configuration datum
	var/datum/configuration_section/general_configuration/general
	/// Holder for the lighting effects configuration datum
	var/datum/configuration_section/lighting_effects_configuration/lighting_effects
	/// Holder for the IPIntel configuration datum
	var/datum/configuration_section/ipintel_configuration/ipintel
	/// Holder for the job configuration datum
	var/datum/configuration_section/job_configuration/jobs
	/// Holder for the logging configuration datum
	var/datum/configuration_section/logging_configuration/logging
	/// Holder for the MC configuration datum
	var/datum/configuration_section/mc_configuration/mc
	/// Holder for the metrics configuration datum
	var/datum/configuration_section/metrics_configuration/metrics
	/// Holder for the movement configuration datum
	var/datum/configuration_section/movement_configuration/movement
	/// Holder for the overflow configuration datum
	var/datum/configuration_section/overflow_configuration/overflow
	/// Holder for the redis configuration datum
	var/datum/configuration_section/redis_configuration/redis
	/// Holder for the ruins configuration datum
	var/datum/configuration_section/ruin_configuration/ruins
	/// Holder for the system configuration datum
	var/datum/configuration_section/system_configuration/system
	/// Holder for the URL configuration datum
	var/datum/configuration_section/url_configuration/url
	/// Holder for the voting configuration datum
	var/datum/configuration_section/vote_configuration/vote
	/// Holder for the asset cache configuration datum
	var/datum/configuration_section/asset_cache_configuration/asset_cache
	/// Holder for the tgui configuration datum
	var/datum/configuration_section/tgui_configuration/tgui
	/// Raw data. Stored here to avoid passing data between procs constantly
	var/list/raw_data = list()


/datum/server_configuration/Destroy(force)
	SHOULD_CALL_PARENT(FALSE)
	// This is going to stay existing. I dont care.
	return QDEL_HINT_LETMELIVE

/datum/server_configuration/vv_get_var(var_name)
	if(var_name == "raw_data") // NO!
		return FALSE
	. = ..()

/datum/server_configuration/vv_edit_var(var_name, var_value)
	if(var_name == "raw_data") // NO!
		return FALSE
	. = ..()

/datum/server_configuration/CanProcCall(procname)
	return FALSE // No thanks

/datum/server_configuration/proc/load_configuration()
	var/start = start_watch() // Time tracking

	// Initialize all our holders
	admin = new()
	afk = new()
	custom_sprites = new()
	database = new()
	discord = new()
	event = new()
	gamemode = new()
	general = new()
	lighting_effects = new()
	ipintel = new()
	jobs = new()
	logging = new()
	mc = new()
	metrics = new()
	movement = new()
	overflow = new()
	redis = new()
	ruins = new()
	system = new()
	url = new()
	vote = new()
	asset_cache = new()
	tgui = new()

	// Load our stuff up
	var/config_file = "config/config.toml"
	if(!fexists(config_file))
		config_file = "config/example/config.toml" // Fallback to example if user hasnt setup config properly
	raw_data = rustlibs_read_toml_file(config_file)

	// Now pass through all our stuff
	load_all_sections()

	// Clear our list to save RAM
	raw_data = list()

	// And report the load
	DIRECT_OUTPUT(world.log, "Config loaded in [stop_watch(start)]s")

/datum/server_configuration/proc/load_all_sections()
	safe_load(admin, "admin_configuration")
	safe_load(afk, "afk_configuration")
	safe_load(custom_sprites, "custom_sprites_configuration")
	safe_load(database, "database_configuration")
	safe_load(discord, "discord_configuration")
	safe_load(event, "event_configuration")
	safe_load(gamemode, "gamemode_configuration")
	safe_load(general, "general_configuration")
	safe_load(lighting_effects, "lighting_effects_configuration")
	safe_load(ipintel, "ipintel_configuration")
	safe_load(jobs, "job_configuration")
	safe_load(logging, "logging_configuration")
	safe_load(mc, "mc_configuration")
	safe_load(metrics, "metrics_configuration")
	safe_load(movement, "movement_configuration")
	safe_load(overflow, "overflow_configuration")
	safe_load(redis, "redis_configuration")
	safe_load(ruins, "ruin_configuration")
	safe_load(system, "system_configuration")
	safe_load(url, "url_configuration")
	safe_load(vote, "voting_configuration")
	safe_load(asset_cache, "asset_cache_configuration")
	safe_load(tgui, "tgui_configuration")

// Proc to load up instance-specific overrides
/datum/server_configuration/proc/load_overrides(override_file)
	if(!fexists(override_file))
		DIRECT_OUTPUT(world.log, "Override file [override_file] not found for this instance.")
		return

	DIRECT_OUTPUT(world.log, "Override file [override_file] found. Loading.")
	var/start = start_watch() // Time tracking

	raw_data = rustlibs_read_toml_file(override_file)

	// Now safely load our overrides.
	// Due to the nature of config wrappers, only vars that exist in the config file are applied to the config datums.
	// This means that an override missing a key doesnt null it out from the main server
	load_all_sections()

	// Clear our list to save RAM
	raw_data = list()

	// And report the load
	DIRECT_OUTPUT(world.log, "Config overrides loaded in [stop_watch(start)]s")

// Only loads the data for a config section if that key exists in the JSON
/datum/server_configuration/proc/safe_load(datum/configuration_section/CS, section)
	if(!isnull(raw_data[section]))
		CS.load_data(raw_data[section])

/datum/configuration_section
	/// See __config_defines.dm
	var/protection_state = PROTECTION_NONE

/datum/configuration_section/proc/load_data(list/data)
	CRASH("load() not overridden for [type]!")

// Maximum protection
/datum/configuration_section/can_vv_get(var_name)
	if(protection_state == PROTECTION_PRIVATE)
		return FALSE
	return ..()

/datum/configuration_section/vv_edit_var(var_name, var_value)
	if(protection_state in list(PROTECTION_PRIVATE, PROTECTION_READONLY))
		return FALSE
	return ..()

/datum/configuration_section/vv_get_var(var_name)
	if(protection_state == PROTECTION_PRIVATE)
		return FALSE
	return ..()

/datum/configuration_section/Destroy(force)
	SHOULD_CALL_PARENT(FALSE)
	// This is going to stay existing. I dont care.
	return QDEL_HINT_LETMELIVE

/datum/configuration_section/CanProcCall(procname)
	return FALSE // No thanks
