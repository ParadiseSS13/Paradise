/// Config holder for all things regarding logging
/datum/configuration_section/logging_configuration
	/// Log OOC messages
	var/ooc_logging = TRUE
	/// Log ingame say messages
	var/say_logging = TRUE
	/// Log admin actions
	var/admin_logging = TRUE
	/// Log client access (login/logout)
	var/access_logging = TRUE
	/// Log game events (roundstart, results, a lot of other things)
	var/game_logging = TRUE
	/// Enable logging of votes and their results
	var/vote_logging = TRUE
	/// Enable logging of whipers
	var/whisper_logging = TRUE
	/// Enable logging of emotes
	var/emote_logging = TRUE
	/// Enable logging of attacks between players
	var/attack_logging = TRUE
	/// Enable logging of PDA messages
	var/pda_logging = TRUE
	/// Enable runtime logging
	var/runtime_logging = TRUE
	/// Enable world.log output logging
	var/world_logging = TRUE
	/// Log hrefs
	var/href_logging = TRUE
	/// Log admin warning messages
	var/admin_warning_logging = TRUE
	/// Log asay messages
	var/adminchat_logging = TRUE
	/// Log debug messages
	var/debug_logging = TRUE

/datum/configuration_section/logging_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(ooc_logging, data["enable_ooc_logging"])
	CONFIG_LOAD_BOOL(say_logging, data["enable_say_logging"])
	CONFIG_LOAD_BOOL(admin_logging, data["enable_admin_logging"])
	CONFIG_LOAD_BOOL(access_logging, data["enable_access_logging"])
	CONFIG_LOAD_BOOL(game_logging, data["enable_game_logging"])
	CONFIG_LOAD_BOOL(vote_logging, data["enable_vote_logging"])
	CONFIG_LOAD_BOOL(whisper_logging, data["enable_whisper_logging"])
	CONFIG_LOAD_BOOL(emote_logging, data["enable_emote_logging"])
	CONFIG_LOAD_BOOL(attack_logging, data["enable_attack_logging"])
	CONFIG_LOAD_BOOL(pda_logging, data["enable_pda_logging"])
	CONFIG_LOAD_BOOL(runtime_logging, data["enable_runtime_logging"])
	CONFIG_LOAD_BOOL(world_logging, data["enable_world_logging"])
	CONFIG_LOAD_BOOL(href_logging, data["enable_href_logging"])
	CONFIG_LOAD_BOOL(admin_warning_logging, data["enable_admin_warning_logging"])
	CONFIG_LOAD_BOOL(adminchat_logging, data["enable_adminchat_logging"])
	CONFIG_LOAD_BOOL(debug_logging, data["enable_debug_logging"])
