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
	/// Holder for the gateway configuration datum
	var/datum/configuration_section/gateway_configuration/gateway
	/// Holder for the general configuration datum
	var/datum/configuration_section/general_configuration/general
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
	/// Holder for the ruins configuration datum
	var/datum/configuration_section/ruin_configuration/ruins
	/// Holder for the system configuration datum
	var/datum/configuration_section/system_configuration/system
	/// Holder for the URL configuration datum
	var/datum/configuration_section/url_configuration/url
	/// Holder for the voting configuration datum
	var/datum/configuration_section/vote_configuration/vote


/datum/server_configuration/Destroy(force)
	SHOULD_CALL_PARENT(FALSE)
	// This is going to stay existing. I dont care.
	return QDEL_HINT_LETMELIVE

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
	gateway = new()
	general = new()
	ipintel = new()
	jobs = new()
	logging = new()
	mc = new()
	metrics = new()
	movement = new()
	overflow = new()
	ruins = new()
	system = new()
	url = new()
	vote = new()

	// Load our stuff up
	var/config_file = "config/config.toml"
	if(!fexists(config_file))
		config_file = "config/example/config.toml" // Fallback to example if user hasnt setup config properly
	var/raw_json = rustg_toml2json(config_file)
	var/list/raw_config_data = json_decode(raw_json)

	// Now pass through all our stuff
	admin.load_data(raw_config_data["admin_configuration"])
	afk.load_data(raw_config_data["afk_configuration"])
	custom_sprites.load_data(raw_config_data["custom_sprites_configuration"])
	database.load_data(raw_config_data["database_configuration"])
	discord.load_data(raw_config_data["discord_configuration"])
	event.load_data(raw_config_data["event_configuration"])
	gamemode.load_data(raw_config_data["gamemode_configuration"])
	gateway.load_data(raw_config_data["gateway_configuration"])
	general.load_data(raw_config_data["general_configuration"])
	ipintel.load_data(raw_config_data["ipintel_configuration"])
	jobs.load_data(raw_config_data["job_configuration"])
	logging.load_data(raw_config_data["logging_configuration"])
	mc.load_data(raw_config_data["mc_configuration"])
	metrics.load_data(raw_config_data["metrics_configuration"])
	movement.load_data(raw_config_data["movement_configuration"])
	overflow.load_data(raw_config_data["overflow_configuration"])
	ruins.load_data(raw_config_data["ruin_configuration"])
	system.load_data(raw_config_data["system_configuration"])
	url.load_data(raw_config_data["url_configuration"])
	vote.load_data(raw_config_data["voting_configuration"])

	// And report the load
	DIRECT_OUTPUT(world.log, "Config loaded in [stop_watch(start)]s")


/datum/configuration_section
	/// See __config_defines.dm
	var/protection_state = PROTECTION_NONE

/datum/configuration_section/proc/load_data(list/data)
	CRASH("load() not overriden for [type]!")

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
